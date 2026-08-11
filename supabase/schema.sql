-- Run this script in the Supabase SQL editor.
-- The browser only uses the public anon key; RLS keeps each user's saves private.

create table if not exists public.stardream_saves (
  user_id uuid not null references auth.users(id) on delete cascade,
  folder text not null check (folder in ('STAR_CHS', 'STAR_CHT')),
  saved_at bigint not null,
  size integer not null check (size > 0 and size <= 4194304),
  save_b64 text not null,
  files jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (user_id, folder)
);

alter table public.stardream_saves enable row level security;

drop policy if exists "stardream_saves_select_own" on public.stardream_saves;
create policy "stardream_saves_select_own"
  on public.stardream_saves for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "stardream_saves_insert_own" on public.stardream_saves;
create policy "stardream_saves_insert_own"
  on public.stardream_saves for insert
  to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "stardream_saves_update_own" on public.stardream_saves;
create policy "stardream_saves_update_own"
  on public.stardream_saves for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "stardream_saves_delete_own" on public.stardream_saves;
create policy "stardream_saves_delete_own"
  on public.stardream_saves for delete
  to authenticated
  using (auth.uid() = user_id);

grant select, insert, update, delete on public.stardream_saves to authenticated;
