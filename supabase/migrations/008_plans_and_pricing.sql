-- Plans and Pricing Migration
-- Run this in Supabase SQL Editor

-- Table: plans
create table if not exists public.plans (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  price text not null,
  period text not null,
  is_popular boolean default false,
  save_text text,
  sort_order integer default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Table: premium_features
create table if not exists public.premium_features (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null,
  icon_name text not null,
  color_hex text not null,
  sort_order integer default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- RLS
alter table public.plans enable row level security;
alter table public.premium_features enable row level security;

-- Public Read Policies
create policy "Anyone can read plans" on plans for select using (true);
create policy "Anyone can read premium_features" on premium_features for select using (true);

-- Admin CRUD Policies for plans
create policy "Admins can manage plans"
  on public.plans for all
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.is_admin = true
    )
  );

-- Admin CRUD Policies for premium_features
create policy "Admins can manage premium_features"
  on public.premium_features for all
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.is_admin = true
    )
  );

-- Seed Plans
insert into public.plans (title, price, period, is_popular, save_text, sort_order)
values 
  ('Monthly Plan', '$6.99', '/ month', false, null, 1),
  ('Yearly Plan', '$49.99', '/ year', true, 'Save 40%', 0)
on conflict do nothing;

-- Seed Features
insert into public.premium_features (title, description, icon_name, color_hex, sort_order)
values 
  ('AD Free Playback', 'No more interruptions. Pure content.', 'ban', '#448AFF', 0),
  ('Live Sports', 'Exclusive access to live matches and events.', 'football', '#DC2626', 1),
  ('24/7 Live Support', 'Priority assistance from our dedicated team.', 'headset', '#69F0AE', 2)
on conflict do nothing;
