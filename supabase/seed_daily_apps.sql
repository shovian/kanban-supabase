-- Idempotent seed: "Daily Apps" board for the first auth user.
-- Safe to re-run; does nothing if the board already exists for that user.
begin;

do $$
declare
  v_owner uuid;
  v_board uuid;
  v_backlog uuid;
begin
  select id into v_owner from auth.users order by created_at limit 1;
  if v_owner is null then
    raise exception 'seed_daily_apps: no user exists in auth.users';
  end if;

  if exists (select 1 from public.boards where user_id = v_owner and name = 'Daily Apps') then
    raise notice 'Board "Daily Apps" already exists for %, skipping', v_owner;
    return;
  end if;

  insert into public.boards (user_id, name)
  values (v_owner, 'Daily Apps')
  returning id into v_board;

  insert into public.columns (board_id, name, position)
  values (v_board, 'Doing', 1), (v_board, 'Shipped', 2);

  insert into public.columns (board_id, name, position)
  values (v_board, 'Backlog', 0)
  returning id into v_backlog;

  insert into public.tasks (board_id, column_id, title, description, position, creator_id)
  select v_board, v_backlog, t.title, t.descr, t.pos, v_owner
  from (values
    (0,  'ocr',                 'Tesseract.js — Apache-2.0'),
    (1,  'whisper-transcribe',  'transformers.js — Apache-2.0'),
    (2,  'text-to-speech',      'kokoro-js — Apache-2.0'),
    (3,  'csv-sql',             'DuckDB-wasm — MIT'),
    (4,  'postgres-playground', 'PGlite — Apache-2.0'),
    (5,  'python-scratchpad',   'Pyodide — MPL-2.0'),
    (6,  'mermaid-editor',      'Mermaid — MIT'),
    (7,  'imagemagick',         'magick-wasm — Apache-2.0'),
    (8,  'code-formatter',      'Prettier standalone — MIT'),
    (9,  'og-image-maker',      'Satori — MPL-2.0'),
    (10, 'hand-tracking',       'MediaPipe Tasks — Apache-2.0'),
    (11, 'local-llm-chat',      'WebLLM — Apache-2.0'),
    (12, 'image-captioner',     'transformers.js — Apache-2.0'),
    (13, 'dos-player',          'js-dos — GPL-2.0'),
    (14, 'flash-player',        'Ruffle — MIT/Apache-2.0')
  ) as t(pos, title, descr);
end
$$;

commit;
