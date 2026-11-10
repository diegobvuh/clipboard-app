begin;
alter table public.inventory_items add column listing_approved boolean not null default false, add column sale_proceeds numeric(12,2) check(sale_proceeds>=0),
 add column sale_fees numeric(12,2) check(sale_fees>=0), add column sale_shipping numeric(12,2) check(sale_shipping>=0),
 add column photo_refs jsonb not null default '[]' check(jsonb_typeof(photo_refs)='array' and jsonb_array_length(photo_refs)<=20);
create table public.business_workspaces (
 business_id uuid primary key references public.businesses(id), revision bigint not null default 0,
 data jsonb not null default '{"sessions":[],"expenses":[],"settings":{"measurement":"When asked","voice":""}}',
 updated_at timestamptz not null default now(), updated_by uuid references auth.users(id)
);
alter table public.business_workspaces enable row level security;
revoke all on public.business_workspaces from public,anon,authenticated;
-- Only RPCs can write workspace state, so version checks cannot be bypassed by clients.
create function public.load_business_workspace(business uuid) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare workspace public.business_workspaces%rowtype; pieces jsonb;
begin
 if not private.is_business_member(business) then raise exception 'Business access denied' using errcode='42501'; end if;
 select * into workspace from public.business_workspaces where business_id=business;
 select coalesce(jsonb_agg(jsonb_build_object('id',i.id,'name',i.title,'brand',i.brand,'size',i.size,'category',i.category,
 'condition',i.condition_notes,'description',i.description,'status',case i.status when 'draft' then 'Draft' when 'ready' then case when i.listing_approved then 'Approved' else 'Ready for review' end when 'listed' then 'Listed manually' when 'sold' then 'Sold' else 'Archived' end,
 'cost',coalesce(to_jsonb(i.purchase_cost),'""'::jsonb),'asking',coalesce(to_jsonb(i.asking_price),'""'::jsonb),
 'sale',coalesce(to_jsonb(i.sale_proceeds),'""'::jsonb),'fees',coalesce(to_jsonb(i.sale_fees),'""'::jsonb),
 'shipping',coalesce(to_jsonb(i.sale_shipping),'""'::jsonb),'photos',i.photo_refs) order by i.created_at desc),'[]'::jsonb)
 into pieces from public.inventory_items i where i.business_id=business and i.status<>'archived';
 return jsonb_build_object('revision',coalesce(workspace.revision,0),'state',
 coalesce(workspace.data,'{"sessions":[],"expenses":[],"settings":{"measurement":"When asked","voice":""}}'::jsonb)||jsonb_build_object('items',pieces));
end;
$$;

create function public.save_business_workspace(business uuid, expected_revision bigint, payload jsonb) returns bigint
language plpgsql security definer set search_path='' as $$
declare current_revision bigint; piece jsonb; photo jsonb; trip jsonb; candidate jsonb; piece_id uuid; seen uuid[]:='{}'; ref text;
begin
 if not private.is_business_member(business) then raise exception 'Business access denied' using errcode='42501'; end if;
 if payload is null or jsonb_typeof(payload)<>'object' or octet_length(payload::text)>2000000 then raise exception 'Workspace exceeds the allowed size'; end if;
 if jsonb_typeof(payload->'items') is distinct from 'array' or jsonb_typeof(payload->'sessions') is distinct from 'array'
 or jsonb_typeof(payload->'expenses') is distinct from 'array' or jsonb_typeof(payload->'settings') is distinct from 'object' then raise exception 'Invalid workspace'; end if;
 if jsonb_array_length(payload->'items')>2000 or jsonb_array_length(payload->'sessions')>500 or jsonb_array_length(payload->'expenses')>5000 then raise exception 'Workspace record limit reached'; end if;
 insert into public.business_workspaces(business_id) values(business) on conflict do nothing;
 select revision into current_revision from public.business_workspaces where business_id=business for update;
 if current_revision<>expected_revision then raise exception 'WORKSPACE_CONFLICT: A teammate saved changes. Reload before saving.' using errcode='40001'; end if;
 for piece in select * from jsonb_array_elements(payload->'items') loop
  piece_id:=(piece->>'id')::uuid;
  if piece_id is null or piece_id=any(seen) then raise exception 'Missing or duplicate item ID'; end if;
  seen:=array_append(seen,piece_id);
  if exists(select 1 from public.inventory_items where id=piece_id and business_id<>business) then raise exception 'Item belongs to another business' using errcode='42501'; end if;
  if piece->>'status' not in ('Draft','Ready for review','Approved','Listed manually','Sold') or piece->>'status' is null then raise exception 'Invalid item status'; end if;
  if jsonb_typeof(piece->'photos') is distinct from 'array' or jsonb_array_length(piece->'photos')>20 then raise exception 'Invalid photo list'; end if;
  for photo in select * from jsonb_array_elements(piece->'photos') loop
   ref:=photo->>'path';
   if ref is null or split_part(ref,'/',1)<>business::text or split_part(ref,'/',2)<>piece_id::text or array_length(string_to_array(ref,'/'),1)<>3
   or ref !~ '^[a-zA-Z0-9/_.-]+$' or photo ? 'src' then raise exception 'Invalid private photo path'; end if;
  end loop;
  insert into public.inventory_items(id,business_id,created_by,title,brand,size,category,condition_notes,description,status,purchase_cost,asking_price,sale_proceeds,sale_fees,sale_shipping,photo_refs,listing_approved)
  values(piece_id,business,auth.uid(),coalesce(nullif(trim(piece->>'name'),''),'Untitled piece'),coalesce(piece->>'brand',''),coalesce(piece->>'size',''),coalesce(piece->>'category',''),coalesce(piece->>'condition',''),coalesce(piece->>'description',''),
  case piece->>'status' when 'Draft' then 'draft' when 'Listed manually' then 'listed' when 'Sold' then 'sold' else 'ready' end,
  nullif(piece->>'cost','')::numeric,nullif(piece->>'asking','')::numeric,nullif(piece->>'sale','')::numeric,nullif(piece->>'fees','')::numeric,nullif(piece->>'shipping','')::numeric,piece->'photos',piece->>'status'='Approved')
  on conflict(id) do update set title=excluded.title,brand=excluded.brand,size=excluded.size,category=excluded.category,condition_notes=excluded.condition_notes,
   description=excluded.description,status=excluded.status,purchase_cost=excluded.purchase_cost,asking_price=excluded.asking_price,
   sale_proceeds=excluded.sale_proceeds,sale_fees=excluded.sale_fees,sale_shipping=excluded.sale_shipping,photo_refs=excluded.photo_refs,listing_approved=excluded.listing_approved where public.inventory_items.business_id=business;
  if not found then raise exception 'Item belongs to another business' using errcode='42501'; end if;
 end loop;
 -- Deleting an item in the UI archives it; no records or stored files are purged.
 update public.inventory_items set status='archived' where business_id=business and not(id=any(seen)) and status<>'archived';
 -- Trip images use a separate business-scoped path. Reject embedded data and foreign paths.
 for trip in select * from jsonb_array_elements(payload->'sessions') loop
  if trip ? 'receiptPhoto' then raise exception 'Upload receipt photos before saving'; end if;
  if trip->>'receiptPath' is not null and (split_part(trip->>'receiptPath','/',1)<>business::text or split_part(trip->>'receiptPath','/',2)<>'trips' or split_part(trip->>'receiptPath','/',3)<>trip->>'id') then raise exception 'Invalid receipt path'; end if;
  if jsonb_typeof(trip->'candidates') is distinct from 'array' then raise exception 'Invalid trip'; end if;
  for candidate in select * from jsonb_array_elements(trip->'candidates') loop
   if candidate ? 'photo' or candidate ? 'tag' then raise exception 'Upload trip photos before saving'; end if;
   foreach ref in array array[candidate->>'photoPath',candidate->>'tagPath'] loop
    if ref is not null and (split_part(ref,'/',1)<>business::text or split_part(ref,'/',2)<>'trips' or split_part(ref,'/',3)<>trip->>'id') then raise exception 'Invalid trip photo path'; end if;
   end loop;
  end loop;
 end loop;
 update public.business_workspaces set revision=revision+1,data=jsonb_build_object('sessions',payload->'sessions','expenses',payload->'expenses','settings',payload->'settings'),updated_at=now(),updated_by=auth.uid() where business_id=business returning revision into current_revision;
 return current_revision;
end;
$$;
revoke all on function public.load_business_workspace(uuid),public.save_business_workspace(uuid,bigint,jsonb) from public,anon;
grant execute on function public.load_business_workspace(uuid),public.save_business_workspace(uuid,bigint,jsonb) to authenticated;

create or replace function private.can_access_photo(path text) returns boolean
language sql stable security definer set search_path='' as $$
 select exists(select 1 from public.business_members m where m.user_id=(select auth.uid()) and m.business_id::text=split_part(path,'/',1))
 and ((array_length(string_to_array(path,'/'),1)=3 and split_part(path,'/',2) ~ '^[0-9a-f-]{36}$')
 or (array_length(string_to_array(path,'/'),1)=4 and split_part(path,'/',2)='trips' and split_part(path,'/',3) ~ '^[0-9a-f-]{36}$'))
 and path ~ '^[a-zA-Z0-9/_.-]+$';
$$;
revoke insert,update on public.inventory_items from authenticated;
revoke update(title,description,condition_notes,status,purchase_cost,asking_price,brand,size,category) on public.inventory_items from authenticated;
-- AI remains off for new businesses until its server deployment and billing controls are verified.
alter table public.businesses add column ai_enabled boolean not null default false;
commit;
