-- =============================================================================
-- Spice Garden – Supabase Database Migration
-- File: supabase/migrations/001_initial_schema.sql
-- Apply via: Supabase Dashboard → SQL Editor, or `supabase db push`
-- =============================================================================

-- ── Extensions ────────────────────────────────────────────────────────────────
create extension if not exists "pgcrypto";

-- ── 1. Profiles (role management) ─────────────────────────────────────────────
create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  email       text unique not null,
  full_name   text,
  role        text not null default 'customer'
                check (role in ('customer', 'cook', 'admin')),
  created_at  timestamptz not null default now()
);

comment on table public.profiles is
  'One row per authenticated user. Role is set server-side only.';

-- Auto-create profile on sign-up
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', '')
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ── 2. Menu items ──────────────────────────────────────────────────────────────
create table if not exists public.menu_items (
  id           uuid primary key default gen_random_uuid(),
  name         text not null,
  description  text not null default '',
  price        numeric(10,2) not null check (price >= 0),
  category     text not null default 'Main',
  image_url    text,
  is_available boolean not null default true,
  sort_order   int not null default 0,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

-- Seed menu items that match the Phase 1 mock data
-- IDs are hardcoded so they match the app's mock IDs (Phase 2 transition)
insert into public.menu_items (id, name, description, price, category, image_url, sort_order)
values
  ('00000000-0001-0000-0000-000000000001', 'Meals',        'Full South Indian meals with rice, sambar, rasam, kootu, and papad.', 120.00, 'Rice',      'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400', 1),
  ('00000000-0001-0000-0000-000000000002', 'Fish Fry',     'Crispy fried fish marinated in aromatic spices.',                     180.00, 'Fry',       'https://images.unsplash.com/photo-1544943910-4c1dc44aab44?w=400', 2),
  ('00000000-0001-0000-0000-000000000003', 'Chicken Fry',  'Tender chicken pieces fried with pepper and spices.',                 200.00, 'Fry',       'https://images.unsplash.com/photo-1598103442097-8b74394b95c1?w=400', 3),
  ('00000000-0001-0000-0000-000000000004', 'Parotta',      'Flaky, layered Kerala parotta served with salna.',                    40.00,  'Bread',     'https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=400', 4),
  ('00000000-0001-0000-0000-000000000005', 'Idli',         'Soft steamed rice cakes with coconut chutney and sambar.',            60.00,  'Breakfast', 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=400', 5),
  ('00000000-0001-0000-0000-000000000006', 'Dosa',         'Crispy golden dosa with potato masala, chutney, and sambar.',         70.00,  'Breakfast', 'https://images.unsplash.com/photo-1630383249896-424e482df921?w=400', 6),
  ('00000000-0001-0000-0000-000000000007', 'Biryani',      'Fragrant basmati rice cooked with tender meat and whole spices.',    220.00, 'Rice',      'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=400', 7)
on conflict (id) do nothing;

-- ── 3. Orders ─────────────────────────────────────────────────────────────────
create table if not exists public.orders (
  id             uuid primary key default gen_random_uuid(),
  order_number   text unique not null,
  customer_id    uuid references public.profiles(id) on delete set null,
  customer_name  text not null,
  table_number   text,
  is_takeaway    boolean not null default false,
  status         text not null default 'new'
                   check (status in ('new','accepted','preparing','ready','completed','cancelled')),
  cancel_reason  text,
  total_amount   numeric(10,2) not null default 0,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

comment on column public.orders.status is
  'Lifecycle: new → accepted → preparing → ready → completed | cancelled';

-- Auto-generate order_number: ORD-MMDD-NNN
create or replace function public.generate_order_number()
returns text
language sql
as $$
  select 'ORD-'
      || to_char(now(), 'MMDD')
      || '-'
      || lpad(
           (select count(*) + 1 from public.orders
            where date_trunc('day', created_at) = date_trunc('day', now()))::text,
           3, '0'
         );
$$;

-- Auto-update updated_at
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;

create trigger orders_touch_updated_at
  before update on public.orders
  for each row execute function public.touch_updated_at();

-- ── 4. Order items ─────────────────────────────────────────────────────────────
create table if not exists public.order_items (
  id              uuid primary key default gen_random_uuid(),
  order_id        uuid not null references public.orders(id) on delete cascade,
  menu_item_id    uuid not null references public.menu_items(id) on delete restrict,
  menu_item_name  text not null,         -- snapshot
  quantity        int not null check (quantity >= 1),
  unit_price      numeric(10,2) not null check (unit_price >= 0),
  created_at      timestamptz not null default now()
);

create index if not exists order_items_order_id_idx on public.order_items(order_id);
create index if not exists order_items_menu_item_id_idx on public.order_items(menu_item_id);

-- =============================================================================
-- Row Level Security
-- =============================================================================

alter table public.profiles   enable row level security;
alter table public.menu_items enable row level security;
alter table public.orders     enable row level security;
alter table public.order_items enable row level security;

-- Helper: is the current user a cook or admin?
create or replace function public.is_kitchen_staff()
returns boolean
language sql
stable
security definer
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid()
      and role in ('cook', 'admin')
  );
$$;

-- ── profiles policies ─────────────────────────────────────────────────────────
create policy "Users can view their own profile"
  on public.profiles for select
  using (id = auth.uid() or public.is_kitchen_staff());

create policy "Users can update their own profile (name only)"
  on public.profiles for update
  using (id = auth.uid())
  with check (
    id = auth.uid()
    -- prevent role self-escalation
    and role = (select role from public.profiles where id = auth.uid())
  );

-- ── menu_items policies ───────────────────────────────────────────────────────
create policy "Everyone can read available menu items"
  on public.menu_items for select
  using (is_available = true or public.is_kitchen_staff());

create policy "Only admins can modify menu items"
  on public.menu_items for all
  using (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'))
  with check (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));

-- ── orders policies ───────────────────────────────────────────────────────────
-- Customers can insert their own orders
create policy "Customers can place orders"
  on public.orders for insert
  with check (customer_id = auth.uid());

-- Customers can only see their own orders; kitchen staff see all
create policy "Customers see their own orders; kitchen sees all"
  on public.orders for select
  using (customer_id = auth.uid() or public.is_kitchen_staff());

-- Only kitchen staff can change order status
create policy "Kitchen staff can update order status"
  on public.orders for update
  using (public.is_kitchen_staff())
  with check (public.is_kitchen_staff());

-- ── order_items policies ──────────────────────────────────────────────────────
-- Customers can add items to their own orders
create policy "Customers can insert their own order items"
  on public.order_items for insert
  with check (
    exists (
      select 1 from public.orders
      where id = order_id and customer_id = auth.uid()
    )
  );

-- Customers see their own items; kitchen sees all
create policy "Customers see their own order items; kitchen sees all"
  on public.order_items for select
  using (
    public.is_kitchen_staff()
    or exists (
      select 1 from public.orders
      where id = order_items.order_id and customer_id = auth.uid()
    )
  );

-- =============================================================================
-- Realtime
-- Enable realtime on orders and order_items so the app gets live updates.
-- Run in SQL editor AFTER the migration above.
-- =============================================================================

-- alter publication supabase_realtime add table public.orders;
-- alter publication supabase_realtime add table public.order_items;
-- (Uncomment after migration runs successfully)
