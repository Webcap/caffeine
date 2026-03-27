# Required Environment Variables

The app loads configuration from a `.env` file in the project root. Create this file and add the following variables before running.

## Setup

1. Copy the template below into a new `.env` file in the project root.
2. Replace each placeholder with your actual credentials.
3. Never commit `.env` to version control (it's already in `.gitignore`).

## Variables

| Variable | Required | Description | Where to get it |
|----------|----------|-------------|-----------------|
| `TMDB_API_KEY` | Yes | The Movie Database API key | [TMDB Account Settings](https://www.themoviedb.org/settings/api) |
| `CONSUMET_URL` | Yes | Consumet API base URL | e.g. `https://api.consumet.org` |
| `CAFFEINE_API_URL` | Yes | Caffeine backend API URL (must expose `GET /config`) | Your Caffeine API deployment |
| `VIDSRC_API` | Yes | VidSrc streaming API URL | Your VidSrc API endpoint |
| `OPENSUBTITLES_API_KEY` | Yes | OpenSubtitles API key | [OpenSubtitles API](https://www.opensubtitles.com/en/consumers) |
| `SUPABASE_URL` | Yes | Supabase project URL | [Supabase Dashboard](https://supabase.com/dashboard) → Project Settings → API |
| `SUPABASE_ANNON_KEY` | Yes | Supabase anonymous/public key | [Supabase Dashboard](https://supabase.com/dashboard) → Project Settings → API |

## Template

```env
TMDB_API_KEY=your_tmdb_key
CONSUMET_URL=https://api.consumet.org
CAFFEINE_API_URL=your_caffeine_api_url
VIDSRC_API=your_vidsrc_api_url
OPENSUBTITLES_API_KEY=your_opensubtitles_key
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANNON_KEY=your_supabase_anon_key
```

## Notes

- **Supabase**: After Firebase removal, auth and data (profiles, bookmarks, watch history) use Supabase. Run the migration in `supabase/migrations/001_firebase_replacement.sql` and enable Email, Google, and Anonymous providers in the Supabase Dashboard.
- **CAFFEINE_API_URL**: The app fetches runtime config from `GET {CAFFEINE_API_URL}/config`. Ensure your backend exposes this endpoint with the expected JSON keys (e.g. `consumet_url`, `forced_update`, `latest_version`).
