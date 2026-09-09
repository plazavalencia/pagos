-- ============================================================
-- Libro de Cuotas — Esquema Supabase
-- Ejecutar completo en: Supabase Dashboard > SQL Editor > New query
-- ============================================================

-- Extensión para generar UUIDs
create extension if not exists "pgcrypto";

-- --------------------------------------------------------------
-- Tabla: vecinos
-- --------------------------------------------------------------
create table vecinos (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  sector text,
  cuota_social numeric not null default 0,
  seguridad numeric not null default 0,
  created_at timestamptz not null default now()
);

-- --------------------------------------------------------------
-- Tabla: vehiculos (patentes) — un vecino puede tener varias
-- --------------------------------------------------------------
create table vehiculos (
  id uuid primary key default gen_random_uuid(),
  vecino_id uuid not null references vecinos(id) on delete cascade,
  patente text not null,
  created_at timestamptz not null default now()
);

-- --------------------------------------------------------------
-- Tabla: pagos
-- --------------------------------------------------------------
create table pagos (
  id uuid primary key default gen_random_uuid(),
  vecino_id uuid not null references vecinos(id) on delete cascade,
  fecha date not null,
  monto numeric not null,
  concepto text not null check (concepto in ('cuota_social','seguridad','ambos','otro')),
  metodo text not null check (metodo in ('correo_banco','whatsapp','app_banco')),
  nota text,
  created_at timestamptz not null default now()
);

-- --------------------------------------------------------------
-- Tabla: config (una sola fila, el día límite del mes)
-- --------------------------------------------------------------
create table config (
  id int primary key default 1,
  dia_limite int not null default 5,
  constraint solo_una_fila check (id = 1)
);
insert into config (id, dia_limite) values (1, 5);

-- --------------------------------------------------------------
-- Tabla: envios (marca qué meses ya se enviaron/transfirieron)
-- --------------------------------------------------------------
create table envios (
  mes text primary key,  -- formato 'YYYY-MM'
  enviado boolean not null default true,
  created_at timestamptz not null default now()
);

-- ============================================================
-- SEGURIDAD (RLS)
-- Este HTML se publicará en GitHub Pages, es decir, la URL y
-- la clave "anon" del proyecto quedarán visibles para cualquiera
-- que vea el código fuente de la página. Por eso NO dejamos las
-- tablas abiertas: solo un usuario autenticado (tú) podrá
-- leer/escribir. Esto requiere que actives Supabase Auth y
-- crees tu propio usuario (instrucciones más abajo).
-- ============================================================

alter table vecinos enable row level security;
alter table vehiculos enable row level security;
alter table pagos enable row level security;
alter table config enable row level security;
alter table envios enable row level security;

create policy "solo autenticados - vecinos" on vecinos
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "solo autenticados - vehiculos" on vehiculos
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "solo autenticados - pagos" on pagos
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "solo autenticados - config" on config
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "solo autenticados - envios" on envios
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- ============================================================
-- DESPUÉS DE CORRER ESTE SQL:
-- 1. Ve a Authentication > Users en el dashboard de Supabase
-- 2. Crea un usuario manualmente con tu email y una contraseña
--    (botón "Add user" > "Create new user")
-- 3. Ese será el único usuario que puede entrar a la app
-- ============================================================
