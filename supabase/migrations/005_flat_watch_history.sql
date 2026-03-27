-- Migration to support flat watch history (row-per-item)
-- This allows the TV app to save progress for individual movies/episodes.

-- 1. Add the missing columns
ALTER TABLE public.watch_history 
ADD COLUMN IF NOT EXISTS media_id INTEGER,
ADD COLUMN IF NOT EXISTS type TEXT,
ADD COLUMN IF NOT EXISTS title TEXT,
ADD COLUMN IF NOT EXISTS poster_path TEXT,
ADD COLUMN IF NOT EXISTS backdrop_path TEXT,
ADD COLUMN IF NOT EXISTS overview TEXT,
ADD COLUMN IF NOT EXISTS season INTEGER,
ADD COLUMN IF NOT EXISTS episode INTEGER,
ADD COLUMN IF NOT EXISTS position_ms INTEGER,
ADD COLUMN IF NOT EXISTS duration_ms INTEGER;

-- 2. Update Constraints to support TV app upserts
-- To support multiple history items per user, we need to remove the single-column PK on user_id
-- and add a unique constraint on the columns specified in the TV app's code.

DO $$ 
BEGIN
    -- Drop the existing primary key constraint if it exists
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'watch_history_pkey') THEN
        ALTER TABLE public.watch_history DROP CONSTRAINT watch_history_pkey;
    END IF;
END $$;

-- Add a unique constraint that matches the TV app's upsert logic:
-- onConflict: 'user_id, media_id, type, season, episode'
ALTER TABLE public.watch_history 
ADD CONSTRAINT watch_history_user_media_type_unique 
UNIQUE (user_id, media_id, type, season, episode);
