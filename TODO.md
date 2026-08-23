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
   - [x] [`lib/controller/recently_watched_database_controller.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/controller/recently_watched_database_controller.dart): Audited SQLite schema, table creation, path resolution, and dynamic Supabase auth uid binding.
   - [x] [`lib/screens/player/player.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/screens/player/player.dart): Implemented elapsed duration tracking and periodic/exit progress persistence across both native MediaKit and embedded iframe playback modes.

2. **State Management & Provider Layer:**
   - [x] [`lib/provider/recently_watched_provider.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/provider/recently_watched_provider.dart): Verified cloud-to-local sync, up-next calculations, and live provider state notifications.
   - [x] [`lib/main.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/main.dart) / [`lib/caffiene_main.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/caffiene_main.dart): Verified `RecentlyWatchedProvider` initialization and deferred cloud sync pipeline.

3. **UI Presentation & Carousel Widgets:**
   - [x] [`lib/screens/movie_screens/main_movie_display.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/screens/movie_screens/main_movie_display.dart): Verified `_ContinueWatchingRow` binding and reactive state updates.
   - [x] [`lib/screens/tv_screens/tv_screen.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/screens/tv_screens/tv_screen.dart) / [`lib/screens/tv_screens/widgets/scrolling_recent_tv_episode.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/screens/tv_screens/widgets/scrolling_recent_tv_episode.dart): Verified in-progress and up-next episode carousels.
   - [x] [`lib/screens/watch_history/watch_history_screen.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/screens/watch_history/watch_history_screen.dart): Verified watch history list and deletion triggers.

---

## 2. General Roadmap & Enhancements

* [ ] Add automated telemetry/QoS event verification for embedded player streams.
