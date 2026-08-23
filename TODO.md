# ReelRiot Mobile - Project Task Backlog

**Document Identification:** RR-TODO-2026-08  
**Standard Compliance:** IEC/IEEE 82079-1:2019 (*Information for use of products — Structure, Content and Presentation*)  
**Project:** ReelRiot Mobile (`c:\Users\cnieves.wmg\Desktop\Projects\reelriot`)  
**Status:** Active  

---

## 1. High-Priority Maintenance Tasks

### Task 1.1: Remove Consumet API Infrastructure & Associated Providers
* **Target Milestone:** Next Minor Release
* **Priority:** Critical
* **Rationale:** The upstream Consumet API hosting (`consumet-api-livid.vercel.app`) has been disabled/decommissioned, causing 100% failure rates on all Consumet-dependent providers (Goku, Sflix, HiMovies, Zoro, Dramacool, ViewAsian). All stream extraction is migrating exclusively to the unified Caffeine API.

#### Scope of Work & Affected Components:
1. **Provider Registry & Precedence:**
   - [x] [`lib/video_providers/provider_names.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/video_providers/provider_names.dart): Remove `goku`, `sflix`, and `himovies` from `ProviderNames.providers` and `checkableCodeNames`.

2. **Provider Loader & Stream Handlers:**
   - [x] [`lib/video_providers/provider_loader.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/video_providers/provider_loader.dart):
     - Remove `_loadMovieGoku`, `_loadMovieSflix`, `_loadMovieHimovies` and their respective TV methods (`_loadTVGoku`, `_loadTVSflix`, `_loadTVHimovies`).
     - Remove parameter dependencies on `consumetUrl`.

3. **Legacy Scraper & Network Method Deprecation:**
   - [x] [`lib/functions/network.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/functions/network.dart): Remove legacy Consumet scraper fetch functions (`getMovieStreamLinksAndSubsGoku`, `getMovieStreamLinksAndSubsSflix`, `getMovieStreamLinksAndSubsHimovies`, etc.).
   - [x] [`lib/video_providers/`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/video_providers/): Deprecate or remove unused Consumet scraper wrapper files (`dramacool.dart`, `viewasian.dart`, `zoro.dart`).

4. **API Endpoints & Configuration:**
   - [x] [`lib/api/endpoints.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/api/endpoints.dart): Remove Consumet search, info, and watch URL generator methods (`getMovieStreamLinkGoku`, `getMovieTVStreamLinksSflix`, `getMovieTVStreamLinksHimovies`, etc.).
   - [x] [`lib/utils/constant.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/utils/constant.dart): Remove `consumetApi` and `consumetInfoApi` getters.
   - [x] [`lib/provider/app_dependency_provider.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/provider/app_dependency_provider.dart): Remove `consumetUrl` state and initializers.
   - [x] [`.env`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/.env) & [`.env.example`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/.env.example): Remove `CONSUMET_URL` variable.

5. **Automated Unit & Integration Tests:**
   - [x] [`test/video_providers/provider_names_test.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/test/video_providers/provider_names_test.dart): Update assertions to reflect the removal of Consumet providers.
   - [x] [`test/video_providers/provider_loader_test.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/test/video_providers/provider_loader_test.dart): Remove Consumet mock tests and verify multi-provider routing.
   - [x] [`test/api/endpoints_test.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/test/api/endpoints_test.dart): Remove Consumet URL generation test groups.

---

### Task 1.2: Disable Failing Headless Browser Providers (VidLink & VidSrc / VidSrc.su)
* **Target Milestone:** Immediate Patch
* **Priority:** High
* **Rationale:** Headless browser scrapers for VidLink (`vidlink`) and VidSrc / VidSrc.su (`vidsrc` / `vidsrcsu`) are experiencing consistent timeouts (>12,000 ms) and upstream Cloudflare blocking on backend scraping workers. Having them at the top of the provider precedence list introduces excessive latency and failed playback attempts on mobile.

#### Scope of Work & Affected Components:
1. **Provider Registry & Default Precedence:**
   - [x] [`lib/video_providers/provider_names.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/video_providers/provider_names.dart): 
     - Remove `vidlink` and `vidsrcsu` from default active list `ProviderNames.providers`.
     - Update `defaultPrecedenceString` to exclude `vidlink` and `vidsrcsu` to avoid mobile player timeouts.
     - Move them to disabled/optional checkable list or deprecate.

2. **Provider Loader & Execution Pipeline:**
   - [x] [`lib/video_providers/provider_loader.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/video_providers/provider_loader.dart):
     - Update movie and TV loaders so `vidlink` and `vidsrcsu` are bypassable or isolated behind fallback toggles.

3. **Status Screen & Test Updates:**
   - [x] [`lib/screens/common/server_status_screen.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/screens/common/server_status_screen.dart): Ensure server status indicator appropriately marks `vidlink` and `vidsrcsu` as offline or degraded.
   - [x] [`test/video_providers/provider_names_test.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/test/video_providers/provider_names_test.dart): Update unit tests to verify default provider precedence list excludes `vidlink` and `vidsrcsu`.

---

### Task 1.3: Fix Client Implementation Defect — Missing VidFun Handler in TV Loader
* **Target Milestone:** Immediate Patch
* **Priority:** Critical
* **Rationale:** In [`lib/video_providers/provider_loader.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/video_providers/provider_loader.dart#L111-L123), `_loadMovieFlixAPIMulti` correctly dispatches `vidfun`, but `loadTVFromProvider()` omits `case 'vidfun':` in its switch statement. Consequently, all TV show playback requests routing through VidFun fail immediately with `Unknown provider: vidfun`.

#### Scope of Work & Affected Components:
1. **TV Stream Dispatching:**
   - [x] [`lib/video_providers/provider_loader.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/video_providers/provider_loader.dart): Add `case 'vidfun':` to `loadTVFromProvider()` to dispatch `_loadTVFlixAPIMulti` for episodic content.

2. **Automated Unit Tests:**
   - [x] [`test/video_providers/provider_loader_test.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/test/video_providers/provider_loader_test.dart): Add unit test verifying that `loadTVFromProvider()` with `providerCode: 'vidfun'` successfully routes to the multi-provider TV extractor.

---

### Task 1.4: Integrate High-Performing Available Alternatives (Vixsrc, CoorenLabs, VidZee)
* **Target Milestone:** Immediate Patch
* **Priority:** Critical
* **Rationale:** Caffeine API backend scrapers for Vixsrc (~200ms latency), CoorenLabs (~700ms latency), and VidZee (~1000ms latency) demonstrated high reliability and sub-second stream resolution in audit testing. WatchFreeStreams (`wfs.lol`) has been decommissioned and removed across all platforms.

#### Scope of Work & Affected Components:
1. **Provider Registry & Precedence:**
   - [x] [`lib/video_providers/provider_names.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/video_providers/provider_names.dart):
     - Register `vixsrc` (`Vixsrc`), `coorenlabs` (`CoorenLabs`), and `vidzee` (`VidZee`) in `ProviderNames.providers`.
     - Update `defaultPrecedenceString` to prioritize `vixsrc` -> `coorenlabs` -> `vidzee` -> `vidfun`.
     - Add provider IDs to `checkableCodeNames`.

2. **Provider Loader Route Dispatching:**
   - [x] [`lib/video_providers/provider_loader.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/video_providers/provider_loader.dart):
     - Ensure `loadMovieFromProvider()` and `loadTVFromProvider()` switch blocks route `vixsrc`, `coorenlabs`, and `vidzee` through `_loadMovieFlixAPIMulti` and `_loadTVFlixAPIMulti`.

3. **Status Screen & Test Updates:**
   - [x] [`lib/screens/common/server_status_screen.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/lib/screens/common/server_status_screen.dart): Verify health checks resolve correctly for active providers.
   - [x] [`test/video_providers/provider_names_test.dart`](file:///c:/Users/cnieves.wmg/Desktop/Projects/reelriot/test/video_providers/provider_names_test.dart): Update test expectations for provider list length, order, and checkable names.

---

## 2. General Roadmap & Enhancements

* [x] Add automated periodic health-check / circuit-breaker for video providers on app startup.
* [x] Optimize stream initialization fallback latency across active providers.
