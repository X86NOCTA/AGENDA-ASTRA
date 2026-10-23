-- ASTRA: dias de funcionamento e agenda trancada. Rode no SQL Editor (pode rodar mais de uma vez)
create table if not exists astra_config(id int primary key default 1, dias int[] default '{1,2,3,4,5,6}', atende_feriados boolean default false);
insert into astra_config(id) values (1) on conflict do nothing;
create table if not exists astra_bloqueios(id uuid primary key default gen_random_uuid(), data date not null, periodo text not null default 'dia', motivo text, created_at timestamptz default now());
alter table astra_config enable row level security;
alter table astra_bloqueios enable row level security;
drop policy if exists astra_config_auth on astra_config;
drop policy if exists astra_bloqueios_auth on astra_bloqueios;
do $$ declare cond text := 'true'; begin
  if to_regclass('public.astra_acesso') is not null then cond := $c$exists(select 1 from astra_acesso a where a.email = auth.jwt()->>'email')$c$; end if;
  execute format('create policy astra_config_auth on astra_config for all to authenticated using (%s) with check (%s)',cond,cond);
  execute format('create policy astra_bloqueios_auth on astra_bloqueios for all to authenticated using (%s) with check (%s)',cond,cond);
end $$;
