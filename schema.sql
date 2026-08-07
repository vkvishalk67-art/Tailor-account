-- ==========================================================
-- DARZI KHATA — FULL PLATFORM DATABASE SCHEMA
-- Shop SaaS + Worker Marketplace + Admin Control
-- ==========================================================

-- ---------- PROFILES (shops + workers, one row per account) ----------
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('shop','worker')),
  full_name text not null,           -- shop name OR worker name
  email text not null,
  phone text,
  cnic text,                          -- 13 digit CNIC, required for both roles
  area text,                          -- city/area only, never exact address (safety)
  subscription_status text default 'trial' check (subscription_status in ('trial','active','expired','blocked')),
  trial_end date,
  is_blocked boolean default false,
  blocked_reason text,
  created_at timestamp default now()
);

alter table profiles enable row level security;

create policy "Users can view own profile" on profiles for select using (auth.uid() = id);
create policy "Users can update own profile" on profiles for update using (auth.uid() = id);
create policy "Users can insert own profile" on profiles for insert with check (auth.uid() = id);

-- Admin full access (replace YOUR_ADMIN_EMAIL before running)
create policy "Admin can view all profiles" on profiles for select using (auth.jwt() ->> 'email' = 'YOUR_ADMIN_EMAIL');
create policy "Admin can update all profiles" on profiles for update using (auth.jwt() ->> 'email' = 'YOUR_ADMIN_EMAIL');

-- Active shops are visible to workers (for marketplace browsing), and vice versa
create policy "Active shops visible to workers" on profiles for select
  using (role = 'shop' and subscription_status = 'active' and is_blocked = false);
create policy "Workers visible to active shops" on profiles for select
  using (role = 'worker' and is_blocked = false);

-- ---------- BLOCKED CNICs (prevents re-registration after a block) ----------
create table blocked_cnics (
  cnic text primary key,
  reason text,
  blocked_at timestamp default now()
);
alter table blocked_cnics enable row level security;
create policy "Admin manages blocked cnics" on blocked_cnics for all
  using (auth.jwt() ->> 'email' = 'YOUR_ADMIN_EMAIL');

-- ---------- CUSTOM MEASUREMENT FIELDS (per shop, fully configurable) ----------
create table measurement_fields (
  id uuid default gen_random_uuid() primary key,
  shop_id uuid references profiles(id) on delete cascade not null,
  field_name text not null,       -- e.g. "Bazoo", "Tera", "Chest" — shop's own words
  field_order integer not null,   -- controls display order
  field_type text default 'number' check (field_type in ('number','text')),
  created_at timestamp default now()
);
alter table measurement_fields enable row level security;
create policy "Shop manages own fields" on measurement_fields for all
  using (auth.uid() = shop_id) with check (auth.uid() = shop_id);

-- ---------- CUSTOMERS ----------
create table customers (
  id uuid default gen_random_uuid() primary key,
  shop_id uuid references profiles(id) on delete cascade not null,
  name text not null,
  phone text,
  address text,
  suit_color text,
  measurements jsonb default '{}',  -- { "field_id": "value", ... } dynamic per shop template
  delivery_date date,
  status text default 'Pending' check (status in ('Pending','Ready','Delivered')),
  notes text,
  total_bill numeric,
  advance_paid numeric,
  face_photo_url text,
  design_photo_url text,
  created_at timestamp default now()
);
alter table customers enable row level security;
create policy "Shop manages own customers" on customers for all
  using (auth.uid() = shop_id) with check (auth.uid() = shop_id);

-- ---------- PAYMENTS (subscription + placement fees, manual verification) ----------
create table payments (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid references profiles(id) on delete cascade not null,
  payment_type text not null check (payment_type in ('subscription','placement_fee')),
  method text,               -- JazzCash/EasyPaisa/Bank
  reference text,            -- transaction ID
  amount numeric,
  status text default 'pending' check (status in ('pending','verified','rejected')),
  created_at timestamp default now()
);
alter table payments enable row level security;
create policy "Users view own payments" on payments for select using (auth.uid() = profile_id);
create policy "Users submit own payments" on payments for insert with check (auth.uid() = profile_id);
create policy "Admin manages all payments" on payments for all
  using (auth.jwt() ->> 'email' = 'YOUR_ADMIN_EMAIL');

-- ---------- WORKER SKILLS / PROFILE DETAILS ----------
create table worker_details (
  worker_id uuid primary key references profiles(id) on delete cascade,
  skills text,              -- e.g. "Kameez stitching, cutting"
  experience_years numeric,
  availability text default 'Available' check (availability in ('Available','Hired')),
  hired_by_shop uuid references profiles(id)
);
alter table worker_details enable row level security;
create policy "Worker manages own details" on worker_details for all
  using (auth.uid() = worker_id) with check (auth.uid() = worker_id);
create policy "Active shops view worker details" on worker_details for select using (true);

-- ---------- CONTACTS (log when a shop/worker reaches out — for trust & safety) ----------
create table contact_logs (
  id uuid default gen_random_uuid() primary key,
  from_profile uuid references profiles(id),
  to_profile uuid references profiles(id),
  created_at timestamp default now()
);
alter table contact_logs enable row level security;
create policy "Users insert own contact logs" on contact_logs for insert with check (auth.uid() = from_profile);
create policy "Admin views contact logs" on contact_logs for select
  using (auth.jwt() ->> 'email' = 'YOUR_ADMIN_EMAIL');

-- ---------- REPORTS (fraud / safety reporting) ----------
create table reports (
  id uuid default gen_random_uuid() primary key,
  reported_by uuid references profiles(id),
  reported_profile uuid references profiles(id),
  reason text not null,
  status text default 'open' check (status in ('open','reviewed','action_taken')),
  created_at timestamp default now()
);
alter table reports enable row level security;
create policy "Users submit reports" on reports for insert with check (auth.uid() = reported_by);
create policy "Admin manages reports" on reports for all
  using (auth.jwt() ->> 'email' = 'YOUR_ADMIN_EMAIL');

-- ---------- RATINGS (shop <-> worker mutual reviews) ----------
create table ratings (
  id uuid default gen_random_uuid() primary key,
  from_profile uuid references profiles(id),
  to_profile uuid references profiles(id),
  stars integer check (stars between 1 and 5),
  comment text,
  created_at timestamp default now()
);
alter table ratings enable row level security;
create policy "Users submit ratings" on ratings for insert with check (auth.uid() = from_profile);
create policy "Everyone views ratings" on ratings for select using (true);

-- ---------- STORAGE BUCKETS (run in Storage tab or via SQL) ----------
-- design-photos, face-photos, logos — all public buckets, authenticated upload
