begin;
alter table public.inventory_items add column brand text not null default '',
 add column size text not null default '', add column category text not null default '';
alter table public.inventory_items add constraint inventory_description_length check(length(description)<=6000),
 add constraint inventory_condition_length check(length(condition_notes)<=3000),
 add constraint inventory_attributes_length check(length(brand)<=100 and length(size)<=100 and length(category)<=100);
grant update(brand,size,category) on public.inventory_items to authenticated;

-- Paths are business UUID / inventory UUID / random filename. No public downloads.
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
 values('garment-photos','garment-photos',false,5242880,array['image/jpeg','image/png','image/webp']);
create function private.can_access_photo(path text) returns boolean
language sql stable security definer set search_path = '' as $$
 select exists(select 1 from public.inventory_items i
 join public.business_members m on m.business_id=i.business_id
 where m.user_id=(select auth.uid()) and i.business_id::text=split_part(path,'/',1)
 and i.id::text=split_part(path,'/',2) and array_length(string_to_array(path,'/'),1)=3);
$$;
revoke all on function private.can_access_photo(text) from public,anon;
grant execute on function private.can_access_photo(text) to authenticated;
create policy garment_photo_read on storage.objects for select to authenticated
 using(bucket_id='garment-photos' and private.can_access_photo(name));
create policy garment_photo_upload on storage.objects for insert to authenticated
 with check(bucket_id='garment-photos' and private.can_access_photo(name));
-- No UPDATE or DELETE policy: existing files cannot be overwritten or purged by clients.

create table private.ai_daily_usage (
 business_id uuid not null references public.businesses(id), day date not null,
 requests integer not null default 0, primary key(business_id,day)
);
create table private.ai_user_usage (
 user_id uuid primary key references auth.users(id), last_request timestamptz not null
);
revoke all on private.ai_daily_usage,private.ai_user_usage from public,anon,authenticated;
alter table private.ai_daily_usage enable row level security;
alter table private.ai_user_usage enable row level security;
-- Only server service_role can reserve a request. It supplies the independently verified caller.
create function public.reserve_ai_request(business uuid, caller uuid) returns integer
language plpgsql security definer set search_path = '' as $$
declare total integer; previous timestamptz;
begin
 if not exists(select 1 from public.business_members where business_id=business and user_id=caller) then
  raise exception 'Business access denied' using errcode='42501';
 end if;
 insert into private.ai_user_usage(user_id,last_request) values(caller,'epoch') on conflict do nothing;
 select last_request into previous from private.ai_user_usage where user_id=caller for update;
 if previous > now()-interval '1 minute' then raise exception 'Wait one minute between AI requests'; end if;
 insert into private.ai_daily_usage(business_id,day,requests) values(business,(now() at time zone 'UTC')::date,0)
 on conflict do nothing;
 update private.ai_daily_usage set requests=requests+1
 where business_id=business and day=(now() at time zone 'UTC')::date and requests<20
 returning requests into total;
 if total is null then raise exception 'Business daily AI limit reached'; end if;
 update private.ai_user_usage set last_request=now() where user_id=caller;
 return 20-total;
end;
$$;
revoke all on function public.reserve_ai_request(uuid,uuid) from public,anon,authenticated;
grant execute on function public.reserve_ai_request(uuid,uuid) to service_role;
commit;
