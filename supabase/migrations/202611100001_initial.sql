-- Already applied through Supabase SQL editor on November 10, 2026.
begin;
create table public.businesses (
 id uuid primary key default gen_random_uuid(),
 name text not null check (char_length(name) between 1 and 100),
 depop_username text,
 owner_id uuid not null references auth.users(id),
 created_at timestamptz not null default now()
);
create table public.business_members (
 business_id uuid not null references public.businesses(id),
 user_id uuid not null references auth.users(id),
 role text not null default 'member' check (role in ('owner','member')),
 created_at timestamptz not null default now(),
 primary key (business_id, user_id)
);
create table public.inventory_items (
 id uuid primary key default gen_random_uuid(),
 business_id uuid not null references public.businesses(id),
 created_by uuid not null references auth.users(id),
 title text not null check (char_length(title) between 1 and 200),
 description text not null default '',
 condition_notes text not null default '',
 status text not null default 'draft' check (status in ('draft','ready','listed','sold','archived')),
 purchase_cost numeric(12,2) check (purchase_cost >= 0),
 asking_price numeric(12,2) check (asking_price >= 0),
 created_at timestamptz not null default now()
);
create index business_members_user_idx on public.business_members(user_id);
create index inventory_items_business_idx on public.inventory_items(business_id);
alter table public.businesses enable row level security;
alter table public.business_members enable row level security;
alter table public.inventory_items enable row level security;
revoke all on public.businesses, public.business_members, public.inventory_items from anon, authenticated;
commit;
