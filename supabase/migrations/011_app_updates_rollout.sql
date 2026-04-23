-- Migration to add gradual rollout support to app updates
-- Creates the app_updates table if it doesn't exist and adds the rollout_percentage column.

create table if not exists public.app_updates (
  id uuid primary key default gen_random_uuid(),
  platform text not null, -- ios, android, tv, web
  environment text not null, -- production, development
  latest_version text not null,
  is_forced boolean default false,
  download_url text,
  store_url text,
  changelog text,
  updated_at timestamptz default now(),
  unique(platform, environment)
);

-- Add rollout_percentage if it doesn't exist
do $$ 
begin 
  if not exists (select 1 from information_schema.columns where table_name='app_updates' and column_name='rollout_percentage') then
    alter table public.app_updates add column rollout_percentage integer default 100;
  end if;
end $$;

-- Also create app_update_history for the audit trail
create table if not exists public.app_update_history (
  id uuid primary key default gen_random_uuid(),
  platform text not null,
  environment text not null,
  version text not null,
  is_forced boolean default false,
  rollout_percentage integer default 100,
  download_url text,
  store_url text,
  changelog text,
  note text,
  created_at timestamptz default now()
);

-- Enable RLS
alter table public.app_updates enable row level security;
alter table public.app_update_history enable row level security;

-- Admin policies (if not already existing)
do $$
begin
  if not exists (select 1 from pg_policies where policyname = 'Admins can manage app_updates' and tablename = 'app_updates') then
    create policy "Admins can manage app_updates"
      on public.app_updates
      using (
        exists (
          select 1 from public.profiles
          where profiles.id = auth.uid() and profiles.is_admin = true
        )
      );
  end if;

  if not exists (select 1 from pg_policies where policyname = 'Admins can view update history' and tablename = 'app_update_history') then
    create policy "Admins can view update history"
      on public.app_update_history for select
      using (
        exists (
          select 1 from public.profiles
          where profiles.id = auth.uid() and profiles.is_admin = true
        )
      );
  end if;
end $$;
