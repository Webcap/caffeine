-- Firebase Replacement Migration
-- Run this in Supabase SQL Editor

-- profiles (replaces users collection)
create table if not exists public.profiles (
  id uuid references auth.users primary key,
  username text unique,
  name text,
  email text,
  image_url text,
  provider text default 'email',
  verified boolean default false,
  joined_at timestamptz default now(),
  is_subscribed boolean default false,
  first_run boolean default true,
  profile_id integer default 0
);

-- usernames lookup (doc id = username)
create table if not exists public.usernames (
  username text primary key,
  user_id uuid references auth.users not null
);

-- bookmarks (movies/tvShows as JSONB)
create table if not exists public.bookmarks (
  user_id uuid references auth.users primary key,
  movies jsonb default '[]',
  tv_shows jsonb default '[]',
  updated_at timestamptz default now()
);

-- watch_history
create table if not exists public.watch_history (
  user_id uuid references auth.users primary key,
  movies jsonb default '[]',
  tv_shows jsonb default '[]',
  updated_at timestamptz default now()
);

-- RLS: users can only access their own data
alter table public.profiles enable row level security;
alter table public.usernames enable row level security;
alter table public.bookmarks enable row level security;
alter table public.watch_history enable row level security;

-- profiles policies
create policy "Users can read own profile" on profiles for select using (auth.uid() = id);
create policy "Users can update own profile" on profiles for update using (auth.uid() = id);
create policy "Users can insert own profile" on profiles for insert with check (auth.uid() = id);

-- usernames policies (public read for username availability check)
create policy "Users can read usernames" on usernames for select using (true);
create policy "Users can insert own username" on usernames for insert with check (auth.uid() = user_id);
create policy "Users can delete own username" on usernames for delete using (auth.uid() = user_id);
create policy "Users can update own username" on usernames for update using (auth.uid() = user_id);

-- bookmarks policies
create policy "Users own bookmarks" on bookmarks for all using (auth.uid() = user_id);

-- watch_history policies
create policy "Users own watch_history" on watch_history for all using (auth.uid() = user_id);
