# ReelRiot Mobile - Project Task Backlog

**Document Identification:** RR-TODO-2026-08  
**Standard Compliance:** IEC/IEEE 82079-1:2019 (*Information for use of products — Structure, Content and Presentation*)  
**Project:** ReelRiot Mobile (`c:\Users\cnieves.wmg\Desktop\Projects\reelriot`)  
**Status:** Active  

---

## 1. High-Priority Maintenance Tasks

### Task 1.1: Investigate & Restore Continue Watching Service (Recently Watched)
* **Target Milestone:** Immediate Patch / Next Minor Release
* **Priority:** High
* **Rationale:** The Continue Watching / Recently Watched carousels and watch history entries are failing to display on the movie/TV dashboard screens and profile history. Playback progress tracking and persistence across local SQLite storage and Supabase cloud sync require end-to-end investigation.

#### Scope of Work & Affected Components:
1. **Playback Progress Persistence & Database Layer:**
   - [ ] [`lib/controller/recently_watched_database_controller.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/controller/recently_watched_database_controller.dart): Audit SQLite schema, table creation, and upsert operations for `insertRecentMovieData` and `insertRecentEpisodeData`.
   - [ ] [`lib/screens/player/player.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/screens/player/player.dart): Verify elapsed duration recording across both native MediaKit playback and embedded iframe modes during periodic intervals (30s) and on screen pop.

2. **State Management & Provider Layer:**
   - [ ] [`lib/provider/recently_watched_provider.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/provider/recently_watched_provider.dart): Audit provider lifecycle, cache invalidation, and synchronization between local SQLite records and Supabase cloud watch history.
   - [ ] [`lib/main.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/main.dart) / [`lib/caffiene_main.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/caffiene_main.dart): Ensure `RecentlyWatchedProvider` is initialized and loaded on application bootstrap.

3. **UI Presentation & Carousel Widgets:**
   - [ ] [`lib/screens/movie_screens/widgets/scrolling_recent_movies.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/screens/movie_screens/widgets/scrolling_recent_movies.dart): Verify visibility triggers, progress bar calculations, and thumbnail binding on the movies dashboard.
   - [ ] [`lib/screens/tv_screens/widgets/scrolling_recent_tv_episode.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/screens/tv_screens/widgets/scrolling_recent_tv_episode.dart): Verify episode progress tracking, season/episode labels, and resume playback routing on the TV dashboard.
   - [ ] [`lib/screens/watch_history/watch_history_screen.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/screens/watch_history/watch_history_screen.dart): Verify watch history list population and deletion triggers.

4. **Automated Unit & Integration Tests:**
   - [ ] Create/update unit tests for SQLite recently watched CRUD methods and provider state notification pipeline.

---

## 2. General Roadmap & Enhancements

* [ ] Add automated telemetry/QoS event verification for embedded player streams.
