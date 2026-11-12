begin;
create table private.ai_monthly_usage (
 business_id uuid not null references public.businesses(id), month date not null,
 feature text not null check(feature in ('draft','chat','research')),
 requests integer not null default 0, reserved_cents integer not null default 0,
 primary key (business_id, month, feature)
);
alter table private.ai_monthly_usage enable row level security;
revoke all on private.ai_monthly_usage from public, anon, authenticated;
create function public.reserve_ai_pilot(business uuid, caller uuid, feature text) returns jsonb
language plpgsql security definer set search_path='' as $$
declare total integer; day_count integer; reservation integer;
begin
 if feature not in ('draft','chat','research') or not exists(select 1 from public.business_members m join public.businesses b on b.id=m.business_id where m.business_id=business and m.user_id=caller and b.ai_enabled) then
  raise exception 'AI access denied' using errcode='42501';
 end if;
 -- Serialize all feature reservations for the business, including concurrent requests.
 perform pg_advisory_xact_lock(hashtextextended(business::text, 0));
 reservation := case when feature='research' then 50 else 10 end;
 select coalesce(sum(reserved_cents),0) into total from private.ai_monthly_usage where business_id=business and month=date_trunc('month',now() at time zone 'UTC')::date;
 if total+reservation>2000 then raise exception 'Monthly AI pilot allowance reached'; end if;
 insert into private.ai_daily_usage(business_id,day,requests) values(business,(now() at time zone 'UTC')::date,0) on conflict do nothing;
 update private.ai_daily_usage set requests=requests+1 where business_id=business and day=(now() at time zone 'UTC')::date and requests<100 returning requests into day_count;
 if day_count is null then raise exception 'Daily AI pilot limit reached'; end if;
 insert into private.ai_monthly_usage(business_id,month,feature,requests,reserved_cents) values(business,date_trunc('month',now() at time zone 'UTC')::date,feature,1,reservation)
 on conflict on constraint ai_monthly_usage_pkey do update set requests=private.ai_monthly_usage.requests+1,reserved_cents=private.ai_monthly_usage.reserved_cents+excluded.reserved_cents;
 return jsonb_build_object('reserved_cents',total+reservation,'remaining_cents',2000-total-reservation,'daily_remaining',100-day_count);
end; $$;
revoke all on function public.reserve_ai_pilot(uuid,uuid,text) from public,anon,authenticated;
grant execute on function public.reserve_ai_pilot(uuid,uuid,text) to service_role;
create function public.ai_pilot_usage(business uuid) returns jsonb
language plpgsql stable security definer set search_path='' as $$
begin
 if not private.is_business_member(business) then raise exception 'Business access denied' using errcode='42501'; end if;
 return jsonb_build_object('month',date_trunc('month',now() at time zone 'UTC')::date,'reserved_cents',coalesce((select sum(u.reserved_cents) from private.ai_monthly_usage u where u.business_id=business and u.month=date_trunc('month',now() at time zone 'UTC')::date),0),'limit_cents',2000,'features',coalesce((select jsonb_object_agg(u.feature,jsonb_build_object('requests',u.requests,'reserved_cents',u.reserved_cents)) from private.ai_monthly_usage u where u.business_id=business and u.month=date_trunc('month',now() at time zone 'UTC')::date),'{}'::jsonb));
end; $$;
revoke all on function public.ai_pilot_usage(uuid) from public,anon;
grant execute on function public.ai_pilot_usage(uuid) to authenticated;
commit;
