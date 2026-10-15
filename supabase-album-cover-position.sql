-- Andi Photography: additive album cover crop settings
-- Safe to run once in Supabase SQL Editor. Existing albums keep centered position and normal zoom.
alter table public.portfolio_events
  add column if not exists cover_position_x integer not null default 50,
  add column if not exists cover_position_y integer not null default 50,
  add column if not exists cover_zoom numeric(3,2) not null default 1.00;

do $$
begin
  if not exists (select 1 from pg_constraint where conrelid='public.portfolio_events'::regclass and conname='portfolio_events_cover_position_x_check') then
    alter table public.portfolio_events add constraint portfolio_events_cover_position_x_check check (cover_position_x between 0 and 100);
  end if;
  if not exists (select 1 from pg_constraint where conrelid='public.portfolio_events'::regclass and conname='portfolio_events_cover_position_y_check') then
    alter table public.portfolio_events add constraint portfolio_events_cover_position_y_check check (cover_position_y between 0 and 100);
  end if;
  if not exists (select 1 from pg_constraint where conrelid='public.portfolio_events'::regclass and conname='portfolio_events_cover_zoom_check') then
    alter table public.portfolio_events add constraint portfolio_events_cover_zoom_check check (cover_zoom between 1.00 and 2.50);
  end if;
end $$;
