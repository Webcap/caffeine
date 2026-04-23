-- Auto-create profile when a new user signs up (fixes RLS 42501 on signup)
-- Run this in Supabase SQL Editor after 001_firebase_replacement.sql

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, name, email, username, profile_id, verified, provider, image_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    new.email,
    coalesce(new.raw_user_meta_data->>'username', ''),
    coalesce((new.raw_user_meta_data->>'profile_id')::int, 0),
    coalesce((new.raw_user_meta_data->>'verified')::boolean, false),
    coalesce(new.raw_app_meta_data->>'provider', 'email'),
    ''
  );
  return new;
end;
$$;

-- Trigger on auth.users (runs with elevated privileges, bypasses RLS)
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
