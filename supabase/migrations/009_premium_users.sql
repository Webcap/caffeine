-- Premium Users Migration
-- Table: premium_users

-- Generic updated_at function if not exists
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql 
SET search_path = '';

-- Table: premium_users
create table if not exists public.premium_users (
  id uuid primary key references public.profiles(id) on delete cascade,
  plan_id uuid references public.plans(id) on delete set null,
  status text not null default 'active', -- active, expired, canceled
  start_date timestamptz not null default now(),
  end_date timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- RLS
alter table public.premium_users enable row level security;

-- Admin All Access
create policy "Admins can manage premium_users"
  on public.premium_users for all
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.is_admin = true
    )
  );

-- Users can read their own premium status
create policy "Users can read their own premium status"
  on public.premium_users for select
  using (auth.uid() = id);

-- Trigger for updated_at
drop trigger if exists set_premium_users_updated_at on public.premium_users;
create trigger set_premium_users_updated_at
  before update on public.premium_users
  for each row execute function public.set_updated_at();

-- Note: Seed data is not applicable here as this tracks real users.
