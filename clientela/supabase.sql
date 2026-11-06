-- Clientela: run once in Supabase > SQL editor. Then add yourself as admin (last line).
create table if not exists public.clientela_admins (email text primary key);
create table if not exists public.clientela_members (
  ws text not null,
  email text not null,
  added_at timestamptz not null default now(),
  primary key (ws, email)
);
create table if not exists public.clientela_space_docs (
  path text primary key check (path ~ '^workspaces/[A-Za-z0-9_-]+(/chunks/[A-Za-z0-9_-]+)?$'),
  ws text generated always as (split_part(path, '/', 2)) stored,
  data jsonb,
  deleted boolean not null default false,
  updated_by uuid default auth.uid(),
  updated_at timestamptz not null default now()
);
create index if not exists clientela_space_docs_ws on public.clientela_space_docs (ws);
create index if not exists clientela_space_docs_upd on public.clientela_space_docs (updated_at);

-- who is asking, and what they may open
create or replace function public.clientela_me() returns text
  language sql stable as $$ select lower(coalesce(auth.jwt() ->> 'email', '')) $$;
create or replace function public.clientela_is_admin() returns boolean
  language sql stable security definer set search_path = public as $$
  select exists (select 1 from clientela_admins where lower(email) = clientela_me()) $$;
-- a client space is open to the admins, to its members, and to whoever creates it
create or replace function public.clientela_can(w text) returns boolean
  language sql stable security definer set search_path = public as $$
  select clientela_me() <> '' and (clientela_is_admin()
    or exists (select 1 from clientela_members where ws = w and lower(email) = clientela_me())
    or not exists (select 1 from clientela_space_docs where ws = w)) $$;

-- whoever creates a space becomes its member; every write is stamped
create or replace function public.clientela_touch() returns trigger
  language plpgsql security definer set search_path = public as $$
begin
  new.updated_at = now(); new.updated_by = auth.uid();
  if tg_op = 'INSERT' and clientela_me() <> '' and not clientela_is_admin() then
    insert into clientela_members (ws, email) values (split_part(new.path, '/', 2), clientela_me()) on conflict do nothing;
  end if;
  return new;
end $$;
drop trigger if exists clientela_touch on public.clientela_space_docs;
create trigger clientela_touch before insert or update on public.clientela_space_docs
  for each row execute function public.clientela_touch();

alter table public.clientela_admins enable row level security;
alter table public.clientela_members enable row level security;
alter table public.clientela_space_docs enable row level security;
drop policy if exists "me" on public.clientela_admins;
create policy "me" on public.clientela_admins for select to authenticated using (lower(email) = clientela_me());
drop policy if exists "read" on public.clientela_members;
create policy "read" on public.clientela_members for select to authenticated using (clientela_is_admin() or lower(email) = clientela_me());
drop policy if exists "admin add" on public.clientela_members;
create policy "admin add" on public.clientela_members for insert to authenticated with check (clientela_is_admin());
drop policy if exists "admin remove" on public.clientela_members;
create policy "admin remove" on public.clientela_members for delete to authenticated using (clientela_is_admin());
drop policy if exists "read" on public.clientela_space_docs;
create policy "read" on public.clientela_space_docs for select to authenticated using (clientela_can(ws));
drop policy if exists "add" on public.clientela_space_docs;
create policy "add" on public.clientela_space_docs for insert to authenticated with check (clientela_can(ws));
drop policy if exists "change" on public.clientela_space_docs;
create policy "change" on public.clientela_space_docs for update to authenticated using (clientela_can(ws)) with check (clientela_can(ws));

-- you, the consultant: you see every client space. Put your email here and run again.
insert into public.clientela_admins (email) values ('your@email.com') on conflict do nothing;
