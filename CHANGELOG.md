# Changelog
 
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
