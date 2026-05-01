# Changelog
 
## [2026.04.29+501] - 2026-05-01
 
### Added
- **Auth System Overhaul**: Completely rewritten mobile authentication architecture to ensure persistent, long-term sessions.
- **`AuthService` Integration**: Centralized all authentication logic into a robust, standalone service for improved reliability and testability.
- **Proactive Session Health Check**: Implemented background session verification to automatically refresh tokens before they expire.
 
### Fixed
- **Persistent Session Loss**: Resolved the "daily sign-in" issue by hardening the persistence layer and token refresh logic.
- **Android Keystore Resilience**: Added auto-repair logic to `SecureLocalStorage` to handle and recover from Android-specific encryption failures (e.g., `BadPaddingException`).
- **Spurious Sign-Outs**: Hardened the auth stream listener to ignore transient network errors that were previously triggering accidental logouts.
- **Initialization Race Conditions**: Optimized `SplashScreen` and `main.dart` to ensure session recovery is prioritized and verified before routing.
 

## [2026.04.28] - 2026-04-28

### Added
- **New Stream Provider**: Integrated **VidSrc.su** (vidsrcsu) as the primary fallback provider, significantly improving stream availability when default sources are down.

### Changed
- **Provider Failover Prioritization**: Reordered the provider precedence to prioritize `VidLink` and `VidSrc.su` as the top two sources.
- **Provider Registry Cleanup**: Removed defunct and unreliable providers including `vixsrc`, `zoro`, `dramacool`, and `viewasian` to prevent playback hangs.
- **Status Check Optimization**: Removed placeholder anime providers (`animekai`, `animepahe`, `hianime`) from the server status loop for a more accurate dashboard.

### Optimized
- **App Size Reduction**: Reduced the application installation footprint by approximately **5.2 MB**.
- **Asset Hygiene**: Purged legacy `.old` backup files and removed 15 redundant Poppins font variants that were not being utilized by the application.
- **Icon Tree-Shaking**: Improved build-time icon tree-shaking for `SocialIcons.ttf`, reducing font asset size by 55%.


### Changed
- **Complete Rebranding**: Fully transitioned the application identity from "Caffeine" to **Reelriot**.
- **Visual Identity Update**: Integrated new monochrome branding assets and updated the application icon for a premium look.
- **UI Localization**: Updated all user-facing strings and the share text to use the new "Reelriot" name and "reelriot.app" domain.
- **Asset Hygiene**: Removed legacy Caffeine image assets and optimized the internal registry for the new identity.

### Fixed
- **Initialization Crash**: Resolved a startup exception caused by missing legacy asset references.
- **Hardcoded Text Sweep**: Fixed multiple instances of hardcoded "Caffeine" labels in the Dashboard, Profile, and Subscription screens.


## [2026.04.21] - 2026-04-21

### Added
- **API Key Authorization**: All requests to the Caffeine API now authenticate with a secure Bearer token.
- **Chromecast Button**: The cast button now appears in the player automatically when connected to Wi-Fi.

### Fixed
- **Player Resume**: The player now correctly resumes from the last saved cloud position when returning to a title.
- **Home Screen Recommendation Crash**: Fixed an exception where live sports events were misidentified as TV shows, causing invalid TMDB requests.
- **Player State `LateInitializationError`**: Resolved a crash caused by accessing `duration` before it was initialized.
- **Resume Watching Stability**: Improved seek timing and provider retry logic to prevent loss of playback position during source switches.

### Changed
- **Video Player Upgrade**: Migrated to a new media player engine (media_kit) for improved playback stability, better hardware decoding support, and reduced crashes during long sessions.
- **GitHub Sign-In Removed**: Removed GitHub as a sign-in option from the login screen.

---

## [2.0.1+20260406] - 2026-04-06

### Fixed
- **Auth Session Expiry Redirect (Mobile)**: Resolved an issue where users remained on the current screen after a session expired or was revoked. The app now automatically redirects to the login screen on sign-out.
- **Profile Page Error on Sign-Out (Mobile)**: Prevented an "Error Occurred" banner from appearing on the Profile page when a user's session was invalid. The page now exits gracefully while navigation resets.
- **TV Show Availability (Mobile)**: Several shows (including The Challenge S41) were showing as unavailable on mobile while working on the TV app. Fixed by:
  - Adding a standard browser `User-Agent` header to all scraper API requests, matching the TV app's behavior.
  - Synchronizing the release date logic with the TV app — episodes airing today are now correctly treated as available.
  - Removing a `posterPath != null` guard that was incorrectly hiding the **Watch Now** button for seasons without a TMDB poster (e.g., newly added seasons).

### Changed
- **Episode List Layout (Mobile)**: Refactored the TV season episode list for improved readability across different screen sizes.
  - Thumbnail width is now percentage-based (38% of screen, clamped 120–180px) instead of fixed.
  - Episode metadata (title, air date, rating) stacks vertically to prevent text truncation on narrow displays.

---

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
