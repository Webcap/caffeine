-- Add completed column to watch_history to track fully-watched items (>= 90%)
ALTER TABLE public.watch_history
  ADD COLUMN IF NOT EXISTS completed BOOLEAN NOT NULL DEFAULT FALSE;

-- Index for faster filtering in the Continue Watching query
CREATE INDEX IF NOT EXISTS idx_watch_history_completed
  ON public.watch_history (user_id, completed);
