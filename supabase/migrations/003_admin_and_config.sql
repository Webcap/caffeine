-- Admin and App Config Migration
-- Run this in Supabase SQL Editor after 002_handle_new_user.sql

-- Add is_admin to profiles
alter table public.profiles add column if not exists is_admin boolean default false;

-- app_config: single row storing caffeine-api config overrides (jsonb)
create table if not exists public.app_config (
  id uuid primary key default gen_random_uuid(),
  config jsonb not null default '{}',
  updated_at timestamptz default now(),
  updated_by uuid references auth.users
);

-- RLS
alter table public.app_config enable row level security;

-- Only admins can select and update app_config
create policy "Admins can select app_config"
  on public.app_config for select
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.is_admin = true
    )
  );

create policy "Admins can update app_config"
  on public.app_config for update
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.is_admin = true
    )
  );

create policy "Admins can insert app_config"
  on public.app_config for insert
  with check (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.is_admin = true
    )
  );

-- Service role bypasses RLS; caffeine-api uses service role to read
-- Allow anon/service to read for the API (API uses service role, not anon)
-- Actually: caffeine-api will use service_role key which bypasses RLS. No policy needed for that.
-- But we need to allow the initial read when no row exists - API will create/upsert via service role.
-- For now, add policy for service role: service_role bypasses RLS by default in Supabase.

-- Seed initial row so API always has something to merge
insert into public.app_config (id, config)
values ('00000000-0000-0000-0000-000000000001'::uuid, '{}')
on conflict (id) do nothing;
