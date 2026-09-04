-- ============================================================
-- SCHEMAT BAZY DANYCH DLA APLIKACJI "MAGAZYN CZĘŚCI" (v2)
-- Ten skrypt jest bezpieczny do uruchomienia zarówno na nowym
-- projekcie, jak i na projekcie, gdzie uruchamiałeś już wersję v1
-- (nic nie zduplikuje ani nie nadpisze istniejących danych).
-- Wklej całość do: Supabase -> SQL Editor -> New query -> Run
-- ============================================================

-- 1. BAZA PRODUKTÓW (kod -> nazwa)
create table if not exists products (
  code text primary key,
  name text not null,
  updated_at timestamptz default now()
);
-- kategoria produktu decyduje, który "magazyn"/protokół obsługuje aplikacja
-- po zeskanowaniu danego kodu (nowość v3)
alter table products add column if not exists category text not null default 'czesci';
alter table products drop constraint if exists products_category_check;
alter table products add constraint products_category_check check (category in ('czesci','atrament'));

-- 2. PRACOWNICY
create table if not exists employees (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  active boolean default true,
  created_at timestamptz default now()
);

-- 3. LINIE PRODUKCYJNE (nowość v2)
create table if not exists lines (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  active boolean default true,
  created_at timestamptz default now()
);

-- 4. URZĄDZENIA (nowość v2)
create table if not exists devices (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  active boolean default true,
  created_at timestamptz default now()
);

-- 5. WYDANIA CZĘŚCI (historia)
create table if not exists issues (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz default now(),
  code text not null,
  product_name text,
  qty int not null default 1,
  line text not null,
  employee text not null,
  comarch_done boolean default false,
  comarch_done_at timestamptz
);

-- kolumna "device" mogła nie istnieć w wersji v1 - dodajemy bezpiecznie
alter table issues add column if not exists device text;

-- pola dla magazynu atramentów/rozpuszczalników (nowość v3)
alter table issues add column if not exists category text not null default 'czesci';
alter table issues drop constraint if exists issues_category_check;
alter table issues add constraint issues_category_check check (category in ('czesci','atrament'));
alter table issues add column if not exists use_by_date date;
alter table issues add column if not exists mixed_before_use boolean;
-- "line" było wymagane (not null) w v1/v2, ale atramenty go nie używają - poluzuj wymóg
alter table issues alter column line drop not null;

-- 6. USTAWIENIA (np. logo firmy do protokołu PDF)
create table if not exists settings (
  key text primary key,
  value text,
  updated_at timestamptz default now()
);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================
alter table settings enable row level security;

drop policy if exists "public read settings" on settings;
create policy "public read settings" on settings for select using (true);

drop policy if exists "admin insert settings" on settings;
create policy "admin insert settings" on settings for insert to authenticated with check (true);
drop policy if exists "admin update settings" on settings;
create policy "admin update settings" on settings for update to authenticated using (true);
drop policy if exists "admin delete settings" on settings;
create policy "admin delete settings" on settings for delete to authenticated using (true);

alter table products enable row level security;
alter table employees enable row level security;
alter table lines enable row level security;
alter table devices enable row level security;
alter table issues enable row level security;

-- Odczyt: dostępny dla wszystkich (aplikacja na tabletach nie wymaga logowania)
drop policy if exists "public read products" on products;
create policy "public read products" on products for select using (true);

drop policy if exists "public read employees" on employees;
create policy "public read employees" on employees for select using (true);

drop policy if exists "public read lines" on lines;
create policy "public read lines" on lines for select using (true);

drop policy if exists "public read devices" on devices;
create policy "public read devices" on devices for select using (true);

drop policy if exists "public read issues" on issues;
create policy "public read issues" on issues for select using (true);

-- Wydania (issues): każdy może dodawać, edytować (checkbox Comarch) i usuwać wpisy
drop policy if exists "public insert issues" on issues;
create policy "public insert issues" on issues for insert with check (true);

drop policy if exists "public update issues" on issues;
create policy "public update issues" on issues for update using (true);

drop policy if exists "public delete issues" on issues;
create policy "public delete issues" on issues for delete using (true);

-- Produkty, pracownicy, linie, urządzenia: modyfikować może
-- WYŁĄCZNIE zalogowany administrator
drop policy if exists "admin insert products" on products;
create policy "admin insert products" on products for insert to authenticated with check (true);
drop policy if exists "admin update products" on products;
create policy "admin update products" on products for update to authenticated using (true);
drop policy if exists "admin delete products" on products;
create policy "admin delete products" on products for delete to authenticated using (true);

drop policy if exists "admin insert employees" on employees;
create policy "admin insert employees" on employees for insert to authenticated with check (true);
drop policy if exists "admin update employees" on employees;
create policy "admin update employees" on employees for update to authenticated using (true);
drop policy if exists "admin delete employees" on employees;
create policy "admin delete employees" on employees for delete to authenticated using (true);

drop policy if exists "admin insert lines" on lines;
create policy "admin insert lines" on lines for insert to authenticated with check (true);
drop policy if exists "admin update lines" on lines;
create policy "admin update lines" on lines for update to authenticated using (true);
drop policy if exists "admin delete lines" on lines;
create policy "admin delete lines" on lines for delete to authenticated using (true);

drop policy if exists "admin insert devices" on devices;
create policy "admin insert devices" on devices for insert to authenticated with check (true);
drop policy if exists "admin update devices" on devices;
create policy "admin update devices" on devices for update to authenticated using (true);
drop policy if exists "admin delete devices" on devices;
create policy "admin delete devices" on devices for delete to authenticated using (true);

-- ============================================================
-- REALTIME — zmiany widoczne na wszystkich urządzeniach na żywo
-- (bezpieczne do wielokrotnego uruchomienia - nie zwróci błędu,
-- jeśli tabela jest już częścią publikacji)
-- ============================================================
do $$
begin
  begin
    alter publication supabase_realtime add table issues;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table employees;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table lines;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table devices;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table products;
  exception when duplicate_object then null;
  end;
end $$;
