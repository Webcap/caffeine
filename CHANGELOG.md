# Changelog

## [2.0.1+20260329] - 2026-03-29

### Added
- **External Subtitles Control (TV)**: Added a manual toggle for "External Subtitles (OpenSubtitles)" in the Settings screen to manually control auto-fetching.
- **Improved Config Sync (TV)**: Fixed an issue where server-side feature flags (like OpenSubtitles discovery) were not correctly applied to the local app state during startup.

### Changed
- **Standardized Subtitle Settings (Mobile)**: Removed redundant "Subtitle Language" and "Fetch All Subtitles" settings from Player Settings.
- **Unified Auto-Discovery (Mobile)**: Subtitle auto-discovery now automatically uses the "Default Audio Language" for a streamlined, integrated experience.

### Fixed
- **TV Subtitle Auto-Download**: Resolved a bug where subtitle discovery would be skipped despite being enabled in the remote configuration.

## [2.0.1] - 2026-03-28

### Added
- **Modern Feature Flag System**: Integrated a new centralized evaluation engine with deterministic rollouts and platform-specific overrides.
- **Anonymous ID Support**: Implemented persistent anonymous identifiers for guest users to ensure consistent feature A/B testing.
- **Subtitle Synchronization Controls**: Added real-time timing offset controls (+/- 1s, +/- 0.1s) to the mobile player.
- **UFC Sports Integration**: Fully integrated UFC/MMA event coverage with support for "Athlete vs. Athlete" data structures and fighter name fallbacks.
- **Multi-Language Subtitle Discovery**: Automated discovery of English and Spanish subtitle tracks on content launch.
- **Debug Navigation (Admin)**: Enhanced admin dashboard with active state highlighting and a centralized Debug dropdown for logs.

### Fixed
- **Premium Banner Visibility**: Resolved an issue where the "Get Premium" banner was not respecting the feature flag state in the Profile screen.
- **Feature Flag Evaluation Logic**: Fixed a bug that caused flags to stay disabled for guest users if the rollout was < 100%.

### Changed
- **Config Deprecation**: Added a 30-day removal notice to the legacy feature flag system in the admin panel (retiring April 27, 2026).
- **Update Routing**: Migrated all platform-specific update logic to the new centralized `/v1/updates` API.


## [2.0.0+20260328] - 2026-03-27

### Added
- **Unified Subtitle Menu**: Integrated subtitle search directly into the subtitle selection menu for a more cohesive user experience.
- **Multi-Language Subtitle Search**: Users can now search and inject subtitles in multiple languages directly from the player interface (Mobile & TV).
- **Subtitles Overhaul**: Standardized subtitle loading and parsing logic across platforms, improving reliability and adding smart default selection.
- **Background Bookmark Sync**: (TV) Automatic background synchronization of bookmarks for a seamless multi-device experience.
- **Dynamic Sports Filtering**: Real-time filtering of terminal and stale matches from the "Live Now" dashboard, with a new 6-hour threshold for ghost matches.
- **Enhanced Analytics**: Extended Mixpanel event tracking to include content playback and search queries.

### Fixed
- **SVG Asset Rendering**: Resolved `XmlParserException` in `server_rack.svg` and `chromecast.svg`.
- **Wakelock Management**: Improved screen-on reliability during long playback sessions and updates.
- **TV Pairing Focus**: Refined focus behavior on the "Get new code" button for TV enrollment.

### Changed
- **Update System Hardening**: Improved update reliability with automated checks and enhanced error handling.
- **Subtitle UI**: New platform-specific dialogs for subtitle language selection (TV & Mobile).

## [2.0.3+20260325] - 2026-03-26
 
### Added
- Newest Items and Popular filtering for actor detail pages (CastDetailPage).
- Modern ChoiceChip-style filter UI for movie and TV show credits.
- Localization support for new filter keys in English and Spanish.
 
## [2.0.1] - 2026-03-26

### Added
- Automatic cleanup of downloaded `.apk` files at startup (Mobile & TV).
- Full Mixpanel analytics integration across Mobile, TV, and Web.
- RevenueCat subscription system integration.
- Dynamic provider precedence system in settings.
- New glassmorphism design language for settings.
- Secure remote configuration for API keys and tokens.

### Fixed
- Mixpanel module resolution error in `caffeine-web`.
- App version mismatch between `pubspec.yaml` and UI.
- "Get new code" focus issue on TV pairing screen.
- External subtitle visibility in TV player settings.
- RevenueCat SDK initialization for anonymous users.

### Changed
- Refactored `AnalyticsService` for multi-platform support.
- Modernized web landing pages and routing.
- Decommissioned legacy Material 3 theme settings.
- Updated watch-time statistics calculation logic.
