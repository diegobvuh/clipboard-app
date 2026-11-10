begin;
create or replace function public.invite_business_member(business uuid, member_email text)
returns uuid language plpgsql security definer set search_path = '' as $$
declare invitation uuid; normalized text := lower(trim(member_email));
begin
 if not private.is_business_owner(business) then
  raise exception 'Only the business owner can invite members' using errcode = '42501';
 end if;
 if normalized is null or length(normalized) not between 3 and 254 or normalized !~ '^[^[:space:]@]+@[^[:space:]@]+[.][^[:space:]@]+$' then
  raise exception 'A valid email is required';
 end if;
 perform 1 from public.businesses where id=business for update;
 if (select count(*) from public.business_invitations where business_id=business and created_at>=date_trunc('day',now() at time zone 'UTC') at time zone 'UTC') >= 20 then
  raise exception 'Daily invitation limit reached';
 end if;
 if exists(select 1 from public.business_invitations where business_id=business and email=normalized
  and expires_at>now() and revoked_at is null and accepted_at is null) then
  raise exception 'An active invitation already exists';
 end if;
 insert into public.business_invitations(business_id,email,invited_by)
 values(business,normalized,auth.uid()) returning id into invitation;
 return invitation;
end;
$$;
revoke all on function public.invite_business_member(uuid,text) from public,anon;
grant execute on function public.invite_business_member(uuid,text) to authenticated;
commit;
