-- Mare Rosso — esquema + datos de PRUEBA (100% ficticios)
-- Ejecutar en el SQL Editor de un proyecto de Supabase NUEVO Y SEPARADO,
-- nunca en el proyecto de producción (dlrfcibanmxipvhucnao).

create table clientes (
  id bigint primary key,
  nombre text not null,
  tel text default '',
  seg text default 'domicilio',
  ruta text default 'lunes',
  zona text default '',
  notas text default '',
  fmt jsonb default '[]'::jsonb,
  estado text default 'activo',
  freq text default 'semanal',
  lat double precision,
  lng double precision,
  created_at timestamptz default now()
);

create table pedidos (
  id bigint not null,
  week_key text not null,
  week_label text default '',
  nombre text,
  ruta text default '',
  zona text default '',
  notas text default '',
  tel text default '',
  fmt jsonb default '[]'::jsonb,
  seg text default 'domicilio',
  pago text default 'pendiente',
  entregado boolean default false,
  nota_cobro text default '',
  agregado_manual boolean default false,
  es_entrega_rapida boolean default false,
  auto_key text default '',
  created_at timestamptz default now(),
  primary key (id, week_key)
);

create table kv_store (
  key text primary key,
  value text
);

-- RLS abierta — está bien para este proyecto desechable con datos falsos.
-- (En producción la seguridad real vive en las políticas RLS, no en esconder la anon key.)
alter table clientes enable row level security;
alter table pedidos enable row level security;
alter table kv_store enable row level security;
create policy "anon all clientes" on clientes for all using (true) with check (true);
create policy "anon all pedidos" on pedidos for all using (true) with check (true);
create policy "anon all kv_store" on kv_store for all using (true) with check (true);

-- ── Seed: 4 clientes ficticios, semana actual ──
-- (nota: un CTE "with" solo vive dentro de UNA sentencia en Postgres,
-- por eso se repite en cada insert que necesita la fecha del lunes)

insert into clientes (id, nombre, tel, seg, ruta, zona, notas, fmt, estado, freq)
values
  (9001, 'Cliente Prueba Uno',    '60000001', 'domicilio', 'lunes',  'Zona Prueba', 'Casa de prueba 1 — portón azul', '[{"u":30,"q":1,"p":5000}]'::jsonb, 'activo', 'semanal'),
  (9002, 'Cliente Prueba Dos',    '60000002', 'domicilio', 'lunes',  'Zona Prueba', 'Casa de prueba 2 — portón rojo', '[{"u":15,"q":2,"p":3000}]'::jsonb, 'activo', 'semanal'),
  (9003, 'Cliente Prueba Tres',   '60000003', 'b2b',       'lunes',  'Zona Prueba', 'Local de prueba 3', '[{"u":30,"q":4,"p":4000}]'::jsonb, 'activo', 'semanal'),
  (9004, 'Cliente Prueba Cuatro', '60000004', 'domicilio', 'martes', 'Zona Prueba', 'Casa de prueba 4', '[{"u":30,"q":1,"p":5500}]'::jsonb, 'activo', 'semanal');

insert into pedidos (id, week_key, week_label, nombre, ruta, zona, notas, tel, fmt, seg, pago, entregado, auto_key)
select c.id, wk.monday::text, 'Semana de prueba', c.nombre, c.ruta, c.zona, c.notas, c.tel, c.fmt, c.seg, 'pendiente', false, ''
from clientes c, (select (current_date - ((extract(isodow from current_date)::int) - 1))::date as monday) wk
where c.id in (9001,9002,9003,9004);

insert into kv_store (key, value)
select 'CONFIRMACIONES', json_build_object(
  wk.monday::text || '_9001', json_build_object('estado','confirmado'),
  wk.monday::text || '_9002', json_build_object('estado','confirmado'),
  wk.monday::text || '_9003', json_build_object('estado','confirmado'),
  wk.monday::text || '_9004', json_build_object('estado','confirmado')
)::text
from (select (current_date - ((extract(isodow from current_date)::int) - 1))::date as monday) wk;

insert into kv_store (key, value) values ('inventario', '[]');
insert into kv_store (key, value) values ('movimientos', '[]');
insert into kv_store (key, value) values ('ruta_orders', '{}');
