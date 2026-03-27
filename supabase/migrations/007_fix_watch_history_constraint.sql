-- Fix the unique constraint to handle NULL season/episode correctly.
-- IMPORTANT: Delete duplicates FIRST before creating the unique index.

-- Step 1: Drop the old broken constraint
ALTER TABLE public.watch_history
  DROP CONSTRAINT IF EXISTS watch_history_user_media_type_unique;

-- Step 2: Drop any partial index left from a prior failed attempt
DROP INDEX IF EXISTS watch_history_upsert_idx;

-- Step 3: Delete duplicates using ctid (PostgreSQL internal row pointer, works
--         even when there is no id/primary-key column).
--         For each logical (user, media, type, season, episode) group, keep the
--         row with the highest updated_at and remove all others.
DELETE FROM public.watch_history w
WHERE w.ctid NOT IN (
  SELECT DISTINCT ON (user_id, media_id, type,
                      COALESCE(season, -1),
                      COALESCE(episode, -1))
    ctid
  FROM public.watch_history
  ORDER BY user_id, media_id, type,
           COALESCE(season, -1),
           COALESCE(episode, -1),
           updated_at DESC  -- keep newest
);

-- Step 4: Now it is safe to create the unique index
CREATE UNIQUE INDEX watch_history_upsert_idx
  ON public.watch_history (
    user_id,
    media_id,
    type,
    COALESCE(season, -1),
    COALESCE(episode, -1)
  );
