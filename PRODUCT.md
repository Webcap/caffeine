# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users

General consumers streaming movies, TV shows, and live sports on their phone or tablet without paying a subscription — the primary, full-account client of the ReelRiot product family (has its own email/password auth, unlike the companion `Reelriot-TV` app, which only pairs to an existing account created here or on web). They come to browse what's available, search for something specific, or continue something they started elsewhere on a synced ReelRiot device.

## Product Purpose

ReelRiot is a free, ad-supported streaming aggregator for movies, TV shows, and live sports, resolved through a backend ("Caffeine API") against a rotating list of third-party providers so a working stream is very likely to be found even when individual sources are unreliable. This mobile app is the primary touch-driven client — where an account is created and where the paired TV app's session originates.

## Positioning

Free and complete, not exclusive: breadth across movies/TV/live sports plus multi-provider failover, competing on "everything, for free, and it actually plays" rather than on subscription-gated exclusive content. (Consistent with the sibling `Reelriot-TV` app's confirmed positioning — verified against this app's own code: real login/register screens confirm it, unlike TV, holds the primary account.)

## Operating Context

- Flutter app targeting phone and tablet (Android confirmed via `android/` dir; `ios/` dir present). Touch-first, portrait-primary today, but the project's own `lib/design.json` already anticipates tablet/landscape/large-screen behavior it has not yet implemented on most screens.
- Two build flavors likely mirror the TV app's `dev`/`prod` split (not independently verified here).
- Content metadata via TMDB (optionally proxied); streaming sources resolved via the Caffeine API across providers (`flixhq`, `dcva`, others per `lib/video_providers/`).
- Ad-supported: native ad widgets exist (`native_ad_banner.dart`, `native_ad_poster_card.dart`).
- Watch history/continue-watching state synced (mirrors TV app's Supabase-backed history + server watch-stats merge pattern).

## Capabilities and Constraints

- Full auth (login/register/forgot-password/delete-account screens present) — this app owns account creation, TV does not.
- Bottom tab bar is the primary navigation pattern on phone (per `design.json`), not a rail — do not introduce TV's left-rail/D-pad pattern here, it belongs to a remote-only surface this app does not have.
- No confirmed ad-spec document equivalent to the web app's `docs/AD_SPECIFICATIONS.md` was found in this project; treat existing ad widget sizing in code as the current constraint rather than inventing new dimensions.
- `lib/design.json` is this project's existing, fairly comprehensive design specification (colors, type scale, spacing, component specs, and explicit sm/md/lg/xl/2xl responsive behavior per screen type, including a `movieDetail` screen-by-screen spec). Several files (including the episode detail page and its sub-widgets) already cite it in a header comment and use its dark-mode token values directly, but the actual layout code implements only the mobile (`base`) breakpoint behavior — the `lg`/`xl`/`2xl` guidance for detail pages ("2-column layout, media left, content right" / "poster, trailer, cast, synopsis, and recommendations can coexist") is specified but not built anywhere yet.
- The live app's actual primary/accent red in code is `#DC2626` (`maincolor` in `lib/utils/globals.dart`, and reused directly as `_C.primary` in the episode-detail widgets) — this matches `design.json`'s `primary-600` token, so the two sources of truth agree here despite `theme_data.dart`'s separate, seemingly-unused Material ColorScheme using different (legacy/generated) color roles.

## Brand Commitments

- Name: **ReelRiot**. Shared brand family with `reelriot-web` and `Reelriot-TV`.
- Established visual identity per `design.json` + actual code: dark-first cinematic UI, poster/still-led imagery, `#DC2626` red as the sole primary action/brand accent, Poppins as the working font family (not Roboto — that's specific to the TV app), rounded cards, translucent glass icon buttons over hero imagery, bottom tab navigation.

## Evidence on Hand

- Real, working app with full auth, watch history, and multi-provider streaming — a production client, not a prototype.
- `lib/design.json` is real, detailed, existing design authority for this project (see Capabilities and Constraints) — not to be treated as absent just because there's no top-level `DESIGN.md`.
- No testimonials, press, or user research on hand. Do not fabricate any.

## Product Principles

1. Free and ad-supported beats subscription-gated — ads and multi-provider failover are core to the business model, not afterthoughts.
2. This app is the account's source of truth — TV and other devices pair to sessions that start here; auth flows are not optional chrome.
3. Cinematic, poster-led, dark-first — the established `design.json` visual world is the identity to extend, not replace, when redesigning any single screen.
4. Never leave the user stuck finding a working stream (shared principle with `Reelriot-TV`, confirmed by the multi-provider architecture in `lib/video_providers/`).

## Accessibility & Inclusion

`design.json` specifies a 44×44px minimum touch target for interactive icons/pills — treat as the working standard for this app absent any other confirmed requirement.
