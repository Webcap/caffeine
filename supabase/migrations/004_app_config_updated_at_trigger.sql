-- Auto-update updated_at on app_config row update (client can omit it)
create or replace function public.update_app_config_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists app_config_updated_at on public.app_config;
create trigger app_config_updated_at
  before update on public.app_config
  for each row execute function public.update_app_config_updated_at();
