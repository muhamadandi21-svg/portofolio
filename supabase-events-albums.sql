-- Andi Photography: additive migration for event albums
-- This migration preserves all existing portfolio_items rows and media files.
-- Run once in Supabase Dashboard > SQL Editor.

create table if not exists public.portfolio_events (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text not null unique,
  description text,
  event_date date,
  cover_url text,
  published boolean not null default true,
  sort_order integer not null default 10,
  created_at timestamptz not null default now()
);

alter table public.portfolio_items
  add column if not exists event_id uuid
  references public.portfolio_events(id) on delete set null;

create index if not exists portfolio_items_event_id_idx
  on public.portfolio_items(event_id);

alter table public.portfolio_events enable row level security;

do $$
begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='portfolio_events' and policyname='Public can view published portfolio events') then
    create policy "Public can view published portfolio events" on public.portfolio_events for select using (published = true);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='portfolio_events' and policyname='Authenticated users can view all portfolio events') then
    create policy "Authenticated users can view all portfolio events" on public.portfolio_events for select to authenticated using (true);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='portfolio_events' and policyname='Authenticated users can create portfolio events') then
    create policy "Authenticated users can create portfolio events" on public.portfolio_events for insert to authenticated with check (auth.uid() is not null);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='portfolio_events' and policyname='Authenticated users can update portfolio events') then
    create policy "Authenticated users can update portfolio events" on public.portfolio_events for update to authenticated using (auth.uid() is not null) with check (auth.uid() is not null);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='portfolio_events' and policyname='Authenticated users can delete portfolio events') then
    create policy "Authenticated users can delete portfolio events" on public.portfolio_events for delete to authenticated using (auth.uid() is not null);
  end if;
end $$;

-- Security note: write policies allow authenticated accounts to manage events.
-- If Supabase sign-up is enabled, restrict these write policies to the admin UID.
