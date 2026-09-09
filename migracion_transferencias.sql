-- Ejecutar en Supabase > SQL Editor

create table transferencias (
  id uuid primary key default gen_random_uuid(),
  tipo text not null check (tipo in ('seguridad','cuota_social')),
  monto numeric not null,
  fecha date not null,
  created_at timestamptz not null default now()
);

alter table transferencias enable row level security;

create policy "solo autenticados - transferencias" on transferencias
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
