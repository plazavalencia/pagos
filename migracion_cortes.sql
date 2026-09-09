-- Ejecutar en Supabase > SQL Editor
alter table config add column if not exists dias_corte int[] not null default '{5,10,20}';
update config set dias_corte = '{5,10,20}' where id = 1;
alter table config drop column if exists dia_limite;
