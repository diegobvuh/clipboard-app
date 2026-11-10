-- Apply after the three initial tables created in Supabase on November 10.
-- No client can change membership or ownership with direct table writes.
begin;
create schema if not exists private;
revoke all on schema private from public, anon;
grant usage on schema private to authenticated;

create function private.is_business_member(business uuid) returns boolean
language sql stable security definer set search_path = '' as $$
 select exists(select 1 from public.business_members m
 where m.business_id = business and m.user_id = (select auth.uid()));
$$;
revoke all on function private.is_business_member(uuid) from public, anon;
grant execute on function private.is_business_member(uuid) to authenticated;

create function private.is_business_owner(business uuid) returns boolean
language sql stable security definer set search_path = '' as $$
 select exists(select 1 from public.businesses b
 where b.id = business and b.owner_id = (select auth.uid()));
$$;
revoke all on function private.is_business_owner(uuid) from public, anon;
grant execute on function private.is_business_owner(uuid) to authenticated;

create table public.business_invitations (
 id uuid primary key default gen_random_uuid(),
 business_id uuid not null references public.businesses(id),
 email text not null check (length(email) between 3 and 254 and email = lower(trim(email))),
 invited_by uuid not null references auth.users(id),
 created_at timestamptz not null default now(),
 expires_at timestamptz not null default now() + interval '7 days',
 accepted_at timestamptz,
 revoked_at timestamptz
);
create index business_invitations_business_idx on public.business_invitations(business_id);
alter table public.business_invitations enable row level security;
revoke all on public.business_invitations from anon, authenticated;

create policy business_read on public.businesses for select to authenticated
 using (private.is_business_member(id));
create policy members_read on public.business_members for select to authenticated
 using (private.is_business_member(business_id));
create policy inventory_read on public.inventory_items for select to authenticated
 using (private.is_business_member(business_id));
create policy inventory_insert on public.inventory_items for insert to authenticated
 with check (private.is_business_member(business_id) and created_by = (select auth.uid()));
create policy inventory_update on public.inventory_items for update to authenticated
 using (private.is_business_member(business_id))
 with check (private.is_business_member(business_id));
create policy invitations_owner_read on public.business_invitations for select to authenticated
 using (private.is_business_owner(business_id));

-- Restrict UPDATE columns: members cannot move items between businesses or forge authors.
grant select on public.businesses, public.business_members, public.inventory_items,
 public.business_invitations to authenticated;
grant insert on public.inventory_items to authenticated;
grant update(title, description, condition_notes, status, purchase_cost, asking_price)
 on public.inventory_items to authenticated;

create function public.create_business(business_name text, shop_username text default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare caller uuid := auth.uid(); business uuid;
begin
 if caller is null or not exists(select 1 from auth.users where id = caller and email_confirmed_at is not null) then
  raise exception 'A verified login is required' using errcode = '42501';
 end if;
 if business_name is null or length(trim(business_name)) not between 1 and 100 then
  raise exception 'Business name must contain 1 to 100 characters';
 end if;
 -- Serialize creation for this user to enforce one owned business in this initial release.
 perform 1 from auth.users where id = caller for update;
 if exists(select 1 from public.businesses where owner_id = caller) then
  raise exception 'You already own a business';
 end if;
 insert into public.businesses(name, depop_username, owner_id)
 values(trim(business_name), nullif(trim(shop_username), ''), caller) returning id into business;
 insert into public.business_members(business_id, user_id, role) values(business, caller, 'owner');
 return business;
end;
$$;

create function public.invite_business_member(business uuid, member_email text)
returns uuid language plpgsql security definer set search_path = '' as $$
declare invitation uuid; normalized text := lower(trim(member_email));
begin
 if not private.is_business_owner(business) then
  raise exception 'Only the business owner can invite members' using errcode = '42501';
 end if;
 if normalized is null or length(normalized) not between 3 and 254 or position('@' in normalized) < 2 then
  raise exception 'A valid email is required';
 end if;
 insert into public.business_invitations(business_id, email, invited_by)
 values(business, normalized, auth.uid()) returning id into invitation;
 return invitation;
end;
$$;

-- Invitation ID is not sufficient: a verified login with the invited email is required.
create function public.accept_business_invitation(invitation uuid)
returns uuid language plpgsql security definer set search_path = '' as $$
declare caller uuid := auth.uid(); caller_email text; pending public.business_invitations%rowtype;
begin
 select lower(email) into caller_email from auth.users
 where id = caller and email_confirmed_at is not null;
 if caller_email is null then raise exception 'A verified login is required' using errcode = '42501'; end if;
 select * into pending from public.business_invitations where id = invitation for update;
 if not found or pending.email <> caller_email or pending.expires_at <= now()
  or pending.accepted_at is not null or pending.revoked_at is not null then
  raise exception 'Invitation is unavailable' using errcode = '42501';
 end if;
 insert into public.business_members(business_id, user_id, role)
 values(pending.business_id, caller, 'member') on conflict do nothing;
 update public.business_invitations set accepted_at = now() where id = invitation;
 return pending.business_id;
end;
$$;

create function public.revoke_business_invitation(invitation uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare business uuid;
begin
 select business_id into business from public.business_invitations where id = invitation for update;
 if business is null or not private.is_business_owner(business) then
  raise exception 'Only the business owner can revoke invitations' using errcode = '42501';
 end if;
 update public.business_invitations set revoked_at = now() where id = invitation and accepted_at is null;
end;
$$;

create function public.remove_business_member(business uuid, member_user uuid)
returns void language plpgsql security definer set search_path = '' as $$
begin
 if not private.is_business_owner(business) then
  raise exception 'Only the business owner can remove members' using errcode = '42501';
 end if;
 if exists(select 1 from public.businesses where id = business and owner_id = member_user) then
  raise exception 'The owner cannot be removed';
 end if;
 delete from public.business_members where business_id = business and user_id = member_user;
 update public.business_invitations set revoked_at = now()
 where business_id = business and accepted_at is null and revoked_at is null
 and email = (select lower(email) from auth.users where id = member_user);
end;
$$;

revoke all on function public.create_business(text,text), public.invite_business_member(uuid,text),
 public.accept_business_invitation(uuid), public.revoke_business_invitation(uuid),
 public.remove_business_member(uuid,uuid) from public, anon;
grant execute on function public.create_business(text,text), public.invite_business_member(uuid,text),
 public.accept_business_invitation(uuid), public.revoke_business_invitation(uuid),
 public.remove_business_member(uuid,uuid) to authenticated;
commit;
