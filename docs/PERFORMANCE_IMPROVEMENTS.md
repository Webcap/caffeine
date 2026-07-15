# Performance Improvement Guide

Prioritized recommendations for improving Caffeine app performance.

---

## Progress (as of last update)

| Item | Status | Notes |
|------|--------|-------|
| 1. Image memory optimization | In progress (~25%) | `CachedPosterImage` in `lib/widgets/cached_image.dart`. Phase 1 done: movie_grid_view, tv_grid_view, horizontal_scrolling_*, discover_*, common_widgets. ~40+ CachedNetworkImage usages remain. |
| 2. Replace Image.network | **Done** | Completed: `globlal_methods.dart`, `profile_page.dart` (avatar), `cast_bottom_sheet.dart` (poster backdrop). No remaining `Image.network` in lib. |
| 3. Defer startup fetches | **Done** | `main.dart`: `_deferredInit()` via `addPostFrameCallback`. |
| 4. Provider listen: false | In progress (~15%) | Fixed: `drawer_widget`, `common_widgets` (proxy reads), `tv_widgets.dart` (credits + images build proxy reads), `collecrions_widget.dart` (all build() proxy reads). Use `context.read` for proxy/config in build(); `context.watch` for theme/imageQuality. ~80+ usages remain. |
| 5. Extract list item widgets | In progress (~15%) | Done: `HorizontalMovieListItem`, `HorizontalTVListItem`, `MovieGridItem`, `TVGridItem` in horizontal_scrolling_movie_list, horizontal_scrolling_tv_list, movie_grid_view, tv_grid_view. Remaining: scrolling_tv_widget, collecrions_widget, bookmarks, discover, episode_list, etc. |
| 6. Add const constructors | Not started | - |
| 7. CacheManager tuning | **Done** | `config.dart`: `maxNrOfCacheObjects: 500`. |
| 8. Lazy loading | Not started | - |
| 9. Flutter DevTools | Manual | Run when profiling. |

**Overall: ~50–55% complete**

### Next phase (current focus)

- **4. Provider listen: false** – Continue audit: same pattern in `scrolling_tv_widget.dart`, `reccomend.dart`, bookmarks, discover, `movie_details`, `tv_detail_page`. In build(), use `context.read` for proxy/API config; use `context.watch` only for values that affect UI (theme, imageQuality, viewType).
- **5. Extract list item widgets** – Continue: same pattern in `scrolling_tv_widget.dart`, `scrolling_movie_list.dart`, `collecrions_widget.dart`, bookmarks tabs, discover result lists, `episode_list_widget.dart`. Use `itemBuilder: (context, index) => SomeListItem(data: list[index], ...)`.

---

## High impact (quick wins)

### 1. Image memory optimization

`CachedNetworkImage` loads full-resolution images into memory. Add `memCacheWidth` and `memCacheHeight` to limit decoded size:

```dart
// Example: for a 200x300 poster
CachedNetworkImage(
  imageUrl: url,
  memCacheWidth: 400,   // 2x for retina
  memCacheHeight: 600,
  maxWidthDiskCache: 400,
  maxHeightDiskCache: 600,
  // ... rest
)
```

**Where:** All `CachedNetworkImage` usages in `lib/screens/`. Use values based on display size (e.g. poster ~200px → 400 cache).

### 2. Replace Image.network with CachedNetworkImage

`lib/utils/globlal_methods.dart` line 18 uses `Image.network` in dialogs—no caching, fetches every time:

```dart
// Before
child: Image.network('https://image.flaticon.com/...')

// After
child: CachedNetworkImage(imageUrl: '...', height: 20, width: 20,
  placeholder: (_, __) => const SizedBox(height: 20, width: 20),
  errorWidget: (_, __, ___) => const Icon(Icons.error),
)
```

### 3. Defer non-critical startup work

`appInitialize()` runs ~25+ async operations before showing the UI. Defer non-essential work:

```dart
// Run after first frame (in appInitialize, after runApp):
await appInitialize();  // Keep: dotenv, Supabase, providers, SharedPrefs
// Defer to after first paint:
Future.microtask(() async {
  await recentProvider.fetchMovies();
  await recentProvider.fetchEpisodes();
  await appDependencyProvider.getConsumetUrl();
  // ... other config fetches
});
```

Or move `fetchConfigFromApi`, `recentProvider.fetchMovies/Episodes`, and provider config fetches to run after the first frame.

---

## Medium impact

### 4. Use `context.read` in event handlers

`Provider.of` without `listen: false` in event handlers can cause unnecessary rebuilds. Use:

```dart
// In onPressed, onTap, etc.
Provider.of<SettingsProvider>(context, listen: false)
// or
context.read<SettingsProvider>()
```

**Audit:** ~100+ Provider usages. Focus on callbacks (onPressed, onTap, submitForm).

### 5. Extract list item widgets

`ListView.builder`/`GridView.builder` itemBuilder closures rebuild when the parent rebuilds. Extract to a `StatelessWidget`:

```dart
// Before: inline
itemBuilder: (context, index) => ListTile(title: Text(items[index]))

// After: extracted
itemBuilder: (context, index) => MovieListItem(movie: items[index])
```

### 6. Add `const` constructors

Add `const` where widgets don't depend on runtime data:

```dart
const SizedBox(height: 10),
const SizedBox(width: 8),
const Padding(padding: EdgeInsets.all(8),
```

---

## Lower impact

### 7. CacheManager tuning

`lib/utils/config.dart` – `cacheProp()` uses 15-day stale period. Consider:

```dart
Config('cacheKey',
  stalePeriod: const Duration(days: 7),
  maxNrOfCacheObjects: 200,  // Limit cache size
)
```

### 8. Lazy loading for heavy screens

Consider `AutomaticKeepAliveClientMixin` for tab screens that are expensive to rebuild, or `PageStorageKey` for scroll position when switching tabs.

### 9. Profile with Flutter DevTools

- **Performance** tab: find jank and rebuilds
- **Memory** tab: check for leaks
- **Network** tab: inspect API calls

---

## Implementation priority

| Priority | Action                          | Effort |
|----------|----------------------------------|--------|
| 1        | Add memCacheWidth/Height to images | Medium |
| 2        | Defer startup fetches            | Low    |
| 3        | Replace Image.network in dialogs | Low    |
| 4        | Provider listen: false audit    | Medium |
| 5        | Extract list item widgets        | Medium |
| 6        | Add const constructors          | Low    |
