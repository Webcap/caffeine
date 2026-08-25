-- Migration for app version telemetry & adoption tracking
create table if not exists public.app_version_telemetry (
  id uuid primary key default gen_random_uuid(),
  platform text not null, -- android, ios, tv, web
  environment text not null default 'production', -- production, development
  client_version text not null,
  device_id text, -- userId or anonymousId
  event_type text default 'version_check', -- version_check, forced_prompt_shown, update_download_clicked
  is_forced_prompt boolean default false,
  created_at timestamptz default now()
);

-- Indexes for efficient analytics querying
create index if not exists idx_app_version_telemetry_created_at on public.app_version_telemetry (created_at desc);
create index if not exists idx_app_version_telemetry_platform_env on public.app_version_telemetry (platform, environment, created_at desc);
create index if not exists idx_app_version_telemetry_device on public.app_version_telemetry (device_id, created_at desc);

-- Enable RLS
alter table public.app_version_telemetry enable row level security;

-- Admin policies
do $$
begin
  if not exists (select 1 from pg_policies where policyname = 'Admins can manage telemetry' and tablename = 'app_version_telemetry') then
    create policy "Admins can manage telemetry"
      on public.app_version_telemetry
      using (
        exists (
          select 1 from public.profiles
          where profiles.id = auth.uid() and profiles.is_admin = true
        )
      );
  end if;
  if not exists (select 1 from pg_policies where policyname = 'Anyone can insert telemetry' and tablename = 'app_version_telemetry') then
    create policy "Anyone can insert telemetry"
      on public.app_version_telemetry for insert
      with check (true);
  end if;
end $$;
