-- Caixa Cigarros compartilhado: execute uma vez no SQL Editor do Supabase.
alter table public.vendas add column if not exists marca text;
alter table public.vendas add column if not exists tipo text;
alter table public.vendas add column if not exists preco_unitario numeric;
alter table public.vendas add column if not exists subtotal numeric;
alter table public.vendas add column if not exists taxa numeric;
alter table public.vendas add column if not exists total numeric;
alter table public.vendas add column if not exists data_venda date;

-- Compatibilidade com vendas antigas já existentes na tabela
update public.vendas set marca = coalesce(marca, produto), total = coalesce(total, valor), subtotal = coalesce(subtotal, valor), data_venda = coalesce(data_venda, criado_em::date) where marca is null or total is null or subtotal is null or data_venda is null;

grant select, insert, delete on table public.vendas to authenticated;
grant usage, select on sequence public.vendas_id_seq to authenticated;

-- Realtime: adiciona a tabela à publicação se ainda não estiver nela
do $$ begin
  if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'vendas') then
    alter publication supabase_realtime add table public.vendas;
  end if;
end $$;
