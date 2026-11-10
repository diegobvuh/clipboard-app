begin;
-- Verified Google accounts can create their own isolated business.
-- All other users remain unable to read business data until they accept an owner invitation.
create or replace function public.create_business(business_name text, shop_username text default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare caller uuid := auth.uid(); business uuid;
begin
 if caller is null or not exists(select 1 from auth.users u where u.id=caller
  and u.email_confirmed_at is not null
  and exists(select 1 from auth.identities i where i.user_id=u.id and i.provider='google')) then
  raise exception 'A verified Google login is required' using errcode='42501';
 end if;
 if business_name is null or length(trim(business_name)) not between 1 and 100 then
  raise exception 'Business name must contain 1 to 100 characters';
 end if;
 perform 1 from auth.users where id=caller for update;
 if exists(select 1 from public.businesses where owner_id=caller) then raise exception 'You already own a business'; end if;
 insert into public.businesses(name,depop_username,owner_id)
 values(trim(business_name),nullif(trim(shop_username),''),caller) returning id into business;
 insert into public.business_members(business_id,user_id,role) values(business,caller,'owner');
 return business;
end;
$$;
revoke all on function public.create_business(text,text) from public,anon;
grant execute on function public.create_business(text,text) to authenticated;

create function public.my_business_invitations()
returns table(id uuid,business_name text,expires_at timestamptz)
language sql stable security definer set search_path = '' as $$
 select inv.id,b.name,inv.expires_at from public.business_invitations inv
 join public.businesses b on b.id=inv.business_id
 join auth.users u on lower(u.email)=inv.email
 where u.id=(select auth.uid()) and u.email_confirmed_at is not null
 and inv.accepted_at is null and inv.revoked_at is null and inv.expires_at>now();
$$;
revoke all on function public.my_business_invitations() from public,anon;
grant execute on function public.my_business_invitations() to authenticated;

create function public.business_member_directory(business uuid)
returns table(user_id uuid,email text,role text)
language sql stable security definer set search_path = '' as $$
 select m.user_id,u.email,m.role from public.business_members m
 join auth.users u on u.id=m.user_id
 where m.business_id=business and private.is_business_owner(business);
$$;
revoke all on function public.business_member_directory(uuid) from public,anon;
grant execute on function public.business_member_directory(uuid) to authenticated;
commit;
