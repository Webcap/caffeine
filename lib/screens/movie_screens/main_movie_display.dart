import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/functions/network.dart';
import 'package:reelriot/models/discovery_feed.dart';
import 'package:reelriot/models/live_tv.dart';
import 'package:reelriot/models/movie_models.dart';
import 'package:reelriot/models/movie_stream_metadata.dart';
import 'package:reelriot/models/recently_watched.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/recently_watched_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/provider/sign_in_provider.dart';
import 'package:reelriot/screens/common/update_screen.dart';
import 'package:reelriot/screens/movie_screens/movie_details.dart';
import 'package:reelriot/models/tv.dart';
import 'package:reelriot/screens/tv_screens/tv_detail_page.dart';
import 'package:reelriot/screens/movie_screens/widgets/genre_list_grid.dart';
import 'package:reelriot/screens/movie_screens/widgets/movies_from_watch_providers.dart';
import 'package:reelriot/screens/movie_screens/widgets/scrolling_movie_list.dart';
import 'package:reelriot/screens/tv_screens/live_event_screen.dart';
import 'package:reelriot/services/discovery_service.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/utils/constant.dart';
import 'package:reelriot/utils/globals.dart';
import 'package:reelriot/utils/globlal_methods.dart';
import 'package:reelriot/utils/theme/textStyle.dart';
import 'package:reelriot/widgets/banner_ad_widget.dart';
import 'package:reelriot/widgets/shimmer_widget.dart';
import 'package:reelriot/widgets/unified_video_loader.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reelriot/utils/sports_helpers.dart';
import 'package:reelriot/screens/movie_screens/widgets/main_movie_list.dart';
import 'package:reelriot/widgets/mobile_context_menu.dart';

// ── Design tokens (mirrors design.json / dash_screen tokens) ─────────────────
class _C {
  static const primary = Color(0xFFDC2626);
  static const primaryLight = Color(0xFFEF4444);
  static const secondary = Color(0xFF7C3AED);
  static const bgCanvasDark = Color(0xFF030712);
  static const bgSurfaceDark = Color(0xFF0B0F14);
  static const bgCanvasLight = Color(0xFFF8FAFC);
  static const textPrimDark = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
  static const textSecDark = Color(0xB8FFFFFF);
  static const textSecLight = Color(0xFF64748B);
  static const borderDark = Color(0x14FFFFFF);
  static const borderLight = Color(0x140F172A);
}

// ── Sealed carousel slide type ────────────────────────────────────────────────

sealed class _HeroSlide {}

class _MovieSlide extends _HeroSlide {
  final Movie movie;
  _MovieSlide(this.movie);
}

class _SportsSlide extends _HeroSlide {
  final FeaturedEvent event;
  _SportsSlide(this.event);
}

// ─────────────────────────────────────────────────────────────────────────────
// Main entry widget
// ─────────────────────────────────────────────────────────────────────────────

class MainMoviesDisplay extends StatefulWidget {
  const MainMoviesDisplay({super.key});

  @override
  State<MainMoviesDisplay> createState() => _MainMoviesDisplayState();
}

class _MainMoviesDisplayState extends State<MainMoviesDisplay>
    with AutomaticKeepAliveClientMixin {
  // Discovery feed (from Caffeine /v1/discovery)
  DiscoveryFeed? _feed;
  bool _feedLoaded = false;

  // Trending movies (resolved to Movie objects for nav)
  List<Movie>? _trendingMovies;

  // Hero carousel slides (merged movies + sports)
  List<_HeroSlide>? _heroSlides;

  // Carousel page indicator
  int _heroPage = 0;

  @override
  void initState() {
    super.initState();
    // defer to next frame so context providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final appDep = context.read<AppDependencyProvider>();
    final settings = context.read<SettingsProvider>();
    final signIn = context.read<SignInProvider>();

    // 1. Fetch sports if enabled (in parallel)
    if (appDep.displayOTTDrawer && appDep.featuredEvents.isEmpty) {
      appDep.fetchSportsStreams();
    }

    // 2. Fetch discovery feed
    final feed = await DiscoveryService.instance.fetchHomeFeed(
      caffeineBaseUrl: appDep.caffeineAPIURL,
      userId: signIn.uid,
      mediaType: 'movie',
      region: settings.defaultCountry,
    );

    if (!mounted) return;

    if (feed != null) {
      setState(() {
        _feed = feed;
        _feedLoaded = true;
      });
      // Try to populate trending from the feed; fall back to TMDB if the
      // feed came back empty or has no trending row.
      _buildTrendingMovies(feed);
      if (feed.rows.isEmpty ||
          feed.rowByType(['trending', 'community_trending', 'social_buzz']) == null) {
        _loadTrendingFallback();
      }
    } else {
      // API unreachable — load trending from TMDB directly.
      setState(() => _feedLoaded = true);
      _loadTrendingFallback();
    }

    _buildHeroSlides();
  }

  // Build trending Movie list from discovery items (best-effort, no detail fetch)
  void _buildTrendingMovies(DiscoveryFeed feed) {
    final trendingRow = feed.rowByType(['trending', 'community_trending', 'social_buzz']);
    if (trendingRow == null || trendingRow.items.isEmpty) return;

    final movies = trendingRow.items.map((item) {
      return Movie(
        id: item.tmdbId,
        title: item.title,
        posterPath: item.posterPath,
        backdropPath: item.backdropPath,
        voteAverage: item.voteAverage,
        overview: null,
        releaseDate: null,
        adult: false,
        originalLanguage: null,
        originalTitle: item.title,
        popularity: null,
        video: false,
        voteCount: null,
      );
    }).toList();

    if (mounted) setState(() => _trendingMovies = movies);
  }

  // Fallback: fetch trending from TMDB directly
  void _loadTrendingFallback() {
    final settings = context.read<SettingsProvider>();
    final appDep = context.read<AppDependencyProvider>();
    fetchMovies(
      '$tmdbApiBaseUrl/trending/movie/week?api_key=$tmdbApiKey'
          '&language=${settings.appLanguage}&include_adult=${settings.isAdult}',
      settings.enableProxy,
      appDep.tmdbProxy,
    ).then((movies) {
      if (mounted) setState(() => _trendingMovies = movies);
    }).catchError((_) {});
  }

  // Merge hero slides: discovery featured + sports events
  void _buildHeroSlides() {
    final appDep = context.read<AppDependencyProvider>();
    final slides = <_HeroSlide>[];

    // Discovery featured movies
    if (_feed != null) {
      final featuredRow = _feed!.rowByType(['featured', 'now_playing', 'popular']);
      if (featuredRow != null) {
        for (final item in featuredRow.items.take(10)) {
          slides.add(_MovieSlide(Movie(
            id: item.tmdbId,
            title: item.title,
            posterPath: item.posterPath,
            backdropPath: item.backdropPath,
            voteAverage: item.voteAverage,
            overview: null,
            releaseDate: null,
            adult: false,
            originalLanguage: null,
            originalTitle: item.title,
            popularity: null,
            video: false,
            voteCount: null,
          )));
        }
      }
    }

    // Inject sports slides when OTT is enabled
    if (appDep.displayOTTDrawer) {
      final sportsSlides = appDep.featuredEvents.take(3).map((e) => _SportsSlide(e)).toList();
      slides.insertAll(0, sportsSlides);
    }

    if (mounted) {
      // Always set _heroSlides — even an empty list — so the carousel exits
      // the shimmer state and renders the TMDB fallback widget instead.
      setState(() => _heroSlides = slides);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();
    final appDep = context.watch<AppDependencyProvider>();
    final lang = settings.appLanguage;
    final region = settings.defaultCountry;
    final includeAdult = settings.isAdult;
    final themeMode = settings.appTheme;
    final rMovies = context.watch<RecentProvider>().continueWatchingMovies;

    // Re-build hero slides reactively when sports events load
    if (appDep.displayOTTDrawer &&
        appDep.featuredEvents.isNotEmpty &&
        (_heroSlides == null ||
            !_heroSlides!.any((s) => s is _SportsSlide))) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _buildHeroSlides());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: _C.primary,
      backgroundColor: isDark ? _C.bgCanvasDark : _C.bgCanvasLight,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        children: [
          // ── 1. Hero carousel ─────────────────────────────────────────────────
          _HeroCarousel(
          slides: _heroSlides,
          feedLoaded: _feedLoaded,
          themeMode: themeMode,
          isDark: isDark,
          imageQuality: settings.imageQuality,
          isProxyEnabled: settings.enableProxy,
          proxyUrl: appDep.tmdbProxy,
          currentPage: _heroPage,
          onPageChanged: (i) => setState(() => _heroPage = i),
          // Fallback: when no discovery slides, show TMDB discover widget
          fallbackWidget: _DiscoverFallbackCarousel(
            includeAdult: includeAdult,
            discoverType: 'discover',
          ),
        ),

        const UpdateBottom(),

        // ── 2. Continue Watching ─────────────────────────────────────────────
        if (rMovies.isNotEmpty)
          _ContinueWatchingRow(
            movies: rMovies,
            isDark: isDark,
            themeMode: themeMode,
            imageQuality: settings.imageQuality,
            isProxyEnabled: settings.enableProxy,
            proxyUrl: appDep.tmdbProxy,
            fetchRoute: appDep.fetchRoute,
          ),

        const BannerAdWidget(),

        // ── 3. Discovery Feed Rows or Fallback ───────────────────────────────
        if (_feedLoaded && _feed != null && _feed!.rows.any((r) => r.type != 'featured'))
          ..._feed!.rows.where((row) => row.type != 'featured').map((row) {
            return _DiscoveryRowWidget(
              row: row,
              isDark: isDark,
              themeMode: themeMode,
              imageQuality: settings.imageQuality,
              isProxyEnabled: settings.enableProxy,
              proxyUrl: appDep.tmdbProxy,
              lang: lang,
              includeAdult: includeAdult,
            );
          })
        else ...[
          // ── Trending Now (discovery or TMDB fallback) ─────────────────────
          _TrendingNowRow(
            movies: _trendingMovies,
            isDark: isDark,
            themeMode: themeMode,
            imageQuality: settings.imageQuality,
            isProxyEnabled: settings.enableProxy,
            proxyUrl: appDep.tmdbProxy,
            lang: lang,
            includeAdult: includeAdult,
          ),

          // ── Remaining standard rows ───────────────────────────────────────
          ScrollingMovies(
            title: tr('popular'),
            api: '$tmdbApiBaseUrl/movie/popular?api_key=$tmdbApiKey&language=$lang',
            discoverType: 'popular',
            isTrending: false,
            includeAdult: includeAdult,
          ),
          ScrollingMovies(
            title: tr('top_rated'),
            api: '$tmdbApiBaseUrl/movie/top_rated?api_key=$tmdbApiKey&region=$region&language=$lang',
            discoverType: 'top_rated',
            isTrending: false,
            includeAdult: includeAdult,
          ),
          ScrollingMovies(
            title: tr('now_playing'),
            api: '$tmdbApiBaseUrl/movie/now_playing?api_key=$tmdbApiKey&language=$lang',
            discoverType: 'now_playing',
            isTrending: false,
            includeAdult: includeAdult,
          ),
          ScrollingMovies(
            title: tr('upcoming'),
            api: _upcomingUrl(lang, region),
            discoverType: 'upcoming',
            isTrending: false,
            includeAdult: includeAdult,
          ),
        ],

        GenreListGrid(
          api: '$tmdbApiBaseUrl/genre/movie/list?api_key=$tmdbApiKey&language=$lang',
        ),
        const MoviesFromWatchProviders(),
      ],
    ));
  }

  String _upcomingUrl(String lang, String region) {
    final regionParam = region.isNotEmpty ? '&region=$region' : '';
    return '$tmdbApiBaseUrl/movie/upcoming?api_key=$tmdbApiKey&language=$lang$regionParam';
  }

  @override
  bool get wantKeepAlive => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Hero carousel widget
// ─────────────────────────────────────────────────────────────────────────────

class _HeroCarousel extends StatelessWidget {
  final List<_HeroSlide>? slides;
  final bool feedLoaded;
  final String themeMode;
  final bool isDark;
  final String imageQuality;
  final bool isProxyEnabled;
  final String proxyUrl;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final Widget fallbackWidget;

  const _HeroCarousel({
    required this.slides,
    required this.feedLoaded,
    required this.themeMode,
    required this.isDark,
    required this.imageQuality,
    required this.isProxyEnabled,
    required this.proxyUrl,
    required this.currentPage,
    required this.onPageChanged,
    required this.fallbackWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Loading
    if (!feedLoaded || slides == null) {
      return Column(
        children: [
          SizedBox(
            height: 220,
            child: discoverMoviesAndTVShimmer(themeMode),
          ),
        ],
      );
    }

    // No discovery slides — show the legacy TMDB carousel
    if (slides!.isEmpty) return fallbackWidget;

    final slideList = slides!;

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: slideList.length,
          options: CarouselOptions(
            height: 220,
            viewportFraction: 0.88,
            enlargeCenterPage: true,
            enlargeFactor: 0.12,
            enableInfiniteScroll: slideList.length > 2,
            autoPlay: slideList.length > 1,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayCurve: Curves.easeInOut,
            onPageChanged: (i, _) => onPageChanged(i),
          ),
          itemBuilder: (context, index, _) {
            final slide = slideList[index];
            return _buildSlide(context, slide);
          },
        ),
        const SizedBox(height: 10),
        // Page indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(slideList.length, (i) {
            final active = i == currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? _C.primary
                    : (isDark ? Colors.white30 : Colors.black26),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSlide(BuildContext context, _HeroSlide slide) {
    if (slide is _SportsSlide) {
      return _SportHeroSlide(event: slide.event);
    }
    final movie = (slide as _MovieSlide).movie;
    final imgBase = buildImageUrl(tmdbBaseImageUrl, proxyUrl, isProxyEnabled, context);
    final backdropUrl = movie.backdropPath != null
        ? '$imgBase$imageQuality${movie.backdropPath}'
        : (movie.posterPath != null ? '$imgBase$imageQuality${movie.posterPath}' : '');

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MovieDetailPage(
            movie: movie,
            heroId: 'hero-${movie.id}',
          ),
        ),
      ),
      child: Hero(
        tag: 'hero-${movie.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              backdropUrl.isEmpty
                  ? Image.asset('assets/images/na_logo.png', fit: BoxFit.cover)
                  : CachedNetworkImage(
                      imageUrl: backdropUrl,
                      fit: BoxFit.cover,
                      cacheManager: cacheProp(),
                      placeholder: (_, __) =>
                          discoverImageShimmer(themeMode),
                      errorWidget: (_, __, ___) => Image.asset(
                        'assets/images/na_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
              // Gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.78),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              // Title at bottom
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Text(
                  movie.title ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'PoppinsSB',
                    shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Sports hero slide
class _SportHeroSlide extends StatelessWidget {
  final FeaturedEvent event;
  const _SportHeroSlide({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = resolveSportTheme(
      sport: event.sport,
      title: event.title,
    );

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LiveEventScreen(
            event: StreameastEvent(
              id: event.id,
              title: event.title,
              url: '',
              logoUrl: event.thumbnailUrl,
              sport: event.sport,
            ),
            videoUrl: event.videoUrl,
            referrer: event.referrer ?? '',
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: theme.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: theme.accentColor.withValues(alpha: 0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.accentColor.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background thumbnail (if available)
              if (event.thumbnailUrl.isNotEmpty)
                Opacity(
                  opacity: 0.25,
                  child: CachedNetworkImage(
                    imageUrl: event.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),

              // Sport watermark silhouette on the right
              Positioned(
                right: -10,
                bottom: -15,
                child: Opacity(
                  opacity: 0.12,
                  child: Icon(
                    theme.icon,
                    size: 150,
                    color: Colors.white,
                  ),
                ),
              ),

              // Dark gradient overlay for text readability
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // LIVE badge + title + tag
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: theme.accentColor.withValues(alpha: 0.6),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: theme.accentColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${theme.label} · LIVE NOW',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'PoppinsSB',
                        shadows: [Shadow(color: Colors.black87, blurRadius: 6)],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Continue Watching row (wide landscape cards)
// ─────────────────────────────────────────────────────────────────────────────

class _ContinueWatchingRow extends StatefulWidget {
  final List<RecentMovie> movies;
  final bool isDark;
  final String themeMode;
  final String imageQuality;
  final bool isProxyEnabled;
  final String proxyUrl;
  final String fetchRoute;

  const _ContinueWatchingRow({
    required this.movies,
    required this.isDark,
    required this.themeMode,
    required this.imageQuality,
    required this.isProxyEnabled,
    required this.proxyUrl,
    required this.fetchRoute,
  });

  @override
  State<_ContinueWatchingRow> createState() => _ContinueWatchingRowState();
}

class _ContinueWatchingRowState extends State<_ContinueWatchingRow> {
  bool _lockTap = false;

  void _suppressTap() {
    setState(() => _lockTap = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _lockTap = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textPrim = widget.isDark ? _C.textPrimDark : _C.textPrimLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _C.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                tr('recently_watched'),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: textPrim,
                  fontFamily: 'PoppinsSB',
                ),
              ),
            ],
          ),
        ),

        // Wide cards horizontal list
        SizedBox(
          height: 130,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: widget.movies.length,
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              final isFirst = index == 0;

              final imgBase = buildImageUrl(
                tmdbBaseImageUrl,
                widget.proxyUrl,
                widget.isProxyEnabled,
                context,
              );
              final imageUrl = movie.backdropPath != null
                  ? '$imgBase${widget.imageQuality}${movie.backdropPath}'
                  : (movie.posterPath != null
                      ? '$imgBase${widget.imageQuality}${movie.posterPath}'
                      : '');

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onLongPress: () {
                    _suppressTap();
                    final prv =
                        context.read<RecentProvider>();
                    MobileContextMenu.show(
                      context: context,
                      title: movie.title ?? '',
                      subtitle: '${movie.releaseYear}',
                      items: [
                        MobileContextMenuItem(
                          label: tr('mark_as_completed'),
                          icon: Icons.check_circle_outline,
                          onTap: () => prv.markMovieAsCompleted(movie),
                        ),
                        MobileContextMenuItem(
                          label: tr('remove_from_history'),
                          icon: Icons.delete_outline,
                          color: Colors.red,
                          onTap: () => prv.deleteMovie(movie.id!),
                        ),
                      ],
                    );
                  },
                  onTap: () async {
                    if (_lockTap) return;
                    final connected = await checkConnection();
                    if (!context.mounted) return;
                    if (connected) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UnifiedVideoLoader(
                            mediaType: MediaType.movie,
                            download: false,
                            route: widget.fetchRoute == 'flixHQ'
                                ? StreamRoute.flixHQ
                                : StreamRoute.tmDB,
                            movieMetadata: MovieStreamMetadata(
                              backdropPath: movie.backdropPath,
                              elapsed: movie.elapsed,
                              isAdult: null,
                              movieId: movie.id,
                              movieName: movie.title,
                              posterPath: movie.posterPath,
                              releaseYear: movie.releaseYear,
                              releaseDate: null,
                            ),
                          ),
                        ),
                      );
                    } else {
                      GlobalMethods.showCustomScaffoldMessage(
                        SnackBar(
                          content: Text(
                            tr('check_connection'),
                            style: kTextSmallBodyStyle,
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                        context,
                      );
                    }
                  },
                  child: SizedBox(
                    width: 200,
                    child: Stack(
                      children: [
                        // Backdrop/poster image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imageUrl.isEmpty
                              ? Image.asset(
                                  'assets/images/na_logo.png',
                                  width: 200,
                                  height: 130,
                                  fit: BoxFit.cover,
                                )
                              : CachedNetworkImage(
                                  cacheManager: cacheProp(),
                                  imageUrl: imageUrl,
                                  width: 200,
                                  height: 130,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) =>
                                      scrollingImageShimmer(widget.themeMode),
                                  errorWidget: (_, __, ___) => Image.asset(
                                    'assets/images/na_logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        // Dark gradient overlay — must be direct Stack child (not inside ClipRRect)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.72),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // "Recommend" badge on first item
                        if (isFirst)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: _C.secondary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Recommend',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        // Play icon overlay
                        Center(
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white54, width: 1.5),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        // Title + progress bar at bottom
                        Positioned(
                          left: 8,
                          right: 8,
                          bottom: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie.title ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'PoppinsSB',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                                child: SizedBox(
                                  height: 3,
                                  child: LinearProgressIndicator(
                                    value: (movie.elapsed ?? 0) /
                                        ((movie.elapsed ?? 0) +
                                                (movie.remaining ?? 1))
                                            .clamp(1, double.infinity),
                                    backgroundColor: Colors.white24,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            _C.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Divider(
          color: widget.isDark ? Colors.white12 : Colors.black12,
          thickness: 1,
          endIndent: 20,
          indent: 10,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Trending Now row (compact poster cards with rating + runtime)
// ─────────────────────────────────────────────────────────────────────────────

class _TrendingNowRow extends StatelessWidget {
  final List<Movie>? movies;
  final bool isDark;
  final String themeMode;
  final String imageQuality;
  final bool isProxyEnabled;
  final String proxyUrl;
  final String lang;
  final bool includeAdult;

  const _TrendingNowRow({
    required this.movies,
    required this.isDark,
    required this.themeMode,
    required this.imageQuality,
    required this.isProxyEnabled,
    required this.proxyUrl,
    required this.lang,
    required this.includeAdult,
  });

  @override
  Widget build(BuildContext context) {
    final textPrim = isDark ? _C.textPrimDark : _C.textPrimLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _C.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tr('trending_this_week'),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: textPrim,
                      fontFamily: 'PoppinsSB',
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: movies == null
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MainMoviesList(
                              title: tr('trending_this_week'),
                              api:
                                  '$tmdbApiBaseUrl/trending/movie/week?api_key=$tmdbApiKey&language=$lang',
                              includeAdult: includeAdult,
                              discoverType: 'Trending',
                              isTrending: true,
                            ),
                          ),
                        ),
                style: TextButton.styleFrom(
                  foregroundColor: _C.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  tr('view_all'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Cards
        SizedBox(
          height: 215,
          child: movies == null
              ? scrollingMoviesAndTVShimmer(themeMode)
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: movies!.length,
                  itemBuilder: (context, index) {
                    final movie = movies![index];
                    final imgBase = buildImageUrl(
                        tmdbBaseImageUrl, proxyUrl, isProxyEnabled, context);
                    final posterUrl = movie.posterPath != null
                        ? '$imgBase$imageQuality${movie.posterPath}'
                        : '';

                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MovieDetailPage(
                              movie: movie,
                              heroId: 'trending-${movie.id}-$index',
                            ),
                          ),
                        ),
                        child: SizedBox(
                          width: 110,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Poster with rating badge
                              Expanded(
                                flex: 6,
                                child: Hero(
                                  tag: 'trending-${movie.id}-$index',
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        child: posterUrl.isEmpty
                                            ? Image.asset(
                                                'assets/images/na_logo.png',
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                              )
                                            : CachedNetworkImage(
                                                cacheManager: cacheProp(),
                                                imageUrl: posterUrl,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                                placeholder: (_, __) =>
                                                    scrollingImageShimmer(
                                                        themeMode),
                                                errorWidget: (_, __, ___) =>
                                                    Image.asset(
                                                  'assets/images/na_logo.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                      ),
                                      // Star rating badge (top-left)
                                      if (movie.voteAverage != null)
                                        Positioned(
                                          top: 6,
                                          left: 6,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(
                                                  alpha: 0.65),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.star_rounded,
                                                  size: 11,
                                                  color: Color(0xFFFACC15),
                                                ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  movie.voteAverage!
                                                      .toStringAsFixed(1),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              // Title
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(2, 5, 2, 0),
                                  child: Text(
                                    movie.title ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: textPrim,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 12),
        Divider(
          color: isDark ? Colors.white12 : Colors.black12,
          thickness: 1,
          endIndent: 20,
          indent: 10,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Legacy TMDB carousel fallback (used when discovery API is unavailable)
// ─────────────────────────────────────────────────────────────────────────────

class _DiscoverFallbackCarousel extends StatefulWidget {
  final bool includeAdult;
  final String discoverType;

  const _DiscoverFallbackCarousel({
    required this.includeAdult,
    required this.discoverType,
  });

  @override
  State<_DiscoverFallbackCarousel> createState() =>
      _DiscoverFallbackCarouselState();
}

class _DiscoverFallbackCarouselState
    extends State<_DiscoverFallbackCarousel>
    with AutomaticKeepAliveClientMixin {
  List<Movie>? _movies;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final settings = context.read<SettingsProvider>();
    final appDep = context.read<AppDependencyProvider>();
    final lang = settings.appLanguage;
    final region = settings.defaultCountry;
    fetchMovies(
      '$tmdbApiBaseUrl/discover/movie?api_key=$tmdbApiKey'
          '&language=$lang&sort_by=popularity.desc'
          '&watch_region=$region&include_adult=${widget.includeAdult}',
      settings.enableProxy,
      appDep.tmdbProxy,
    ).then((v) {
      if (mounted) setState(() => _movies = v);
    }).catchError((_) {
      if (mounted) setState(() => _movies = []);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final settings = context.watch<SettingsProvider>();
    final appDep = context.watch<AppDependencyProvider>();
    final themeMode = settings.appTheme;
    final imageQuality = settings.imageQuality;
    final isProxyEnabled = settings.enableProxy;
    final proxyUrl = appDep.tmdbProxy;

    if (_movies == null) {
      return SizedBox(height: 350, child: discoverMoviesAndTVShimmer(themeMode));
    }
    if (_movies!.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 350,
      child: CarouselSlider.builder(
        options: CarouselOptions(
          disableCenter: true,
          viewportFraction: 0.6,
          enlargeCenterPage: true,
          autoPlay: true,
        ),
        itemCount: _movies!.length,
        itemBuilder: (context, index, _) {
          final movie = _movies![index];
          final imgBase = buildImageUrl(
              tmdbBaseImageUrl, proxyUrl, isProxyEnabled, context);
          final url = movie.posterPath != null
              ? '$imgBase$imageQuality${movie.posterPath}'
              : '';
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MovieDetailPage(
                  movie: movie,
                  heroId: 'fbcarousel-${movie.id}-$index',
                ),
              ),
            ),
            child: Hero(
              tag: 'fbcarousel-${movie.id}-$index',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: url.isEmpty
                    ? Image.asset('assets/images/na_logo.png', fit: BoxFit.cover)
                    : CachedNetworkImage(
                        cacheManager: cacheProp(),
                        imageUrl: url,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            discoverImageShimmer(themeMode),
                        errorWidget: (_, __, ___) => Image.asset(
                          'assets/images/na_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Discovery Row Widget (Dynamic rows from Caffeine API)
// ─────────────────────────────────────────────────────────────────────────────

class _DiscoveryRowWidget extends StatelessWidget {
  final DiscoveryRow row;
  final bool isDark;
  final String themeMode;
  final String imageQuality;
  final bool isProxyEnabled;
  final String proxyUrl;
  final String lang;
  final bool includeAdult;

  const _DiscoveryRowWidget({
    required this.row,
    required this.isDark,
    required this.themeMode,
    required this.imageQuality,
    required this.isProxyEnabled,
    required this.proxyUrl,
    required this.lang,
    required this.includeAdult,
  });

  @override
  Widget build(BuildContext context) {
    final textPrim = isDark ? _C.textPrimDark : _C.textPrimLight;
    final items = row.items;

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 10),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _C.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  row.title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: textPrim,
                    fontFamily: 'PoppinsSB',
                  ),
                ),
              ),
            ],
          ),
        ),

        // Cards
        SizedBox(
          height: 215,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final imgBase = buildImageUrl(
                  tmdbBaseImageUrl, proxyUrl, isProxyEnabled, context);
              final posterUrl = item.posterPath != null
                  ? '$imgBase$imageQuality${item.posterPath}'
                  : '';

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    final heroId = '${row.id}-${item.tmdbId}-$index';
                    if (item.mediaType == 'tv') {
                      final tvSeries = TV(
                        id: item.tmdbId,
                        name: item.title,
                        posterPath: item.posterPath,
                        backdropPath: item.backdropPath,
                        voteAverage: item.voteAverage,
                        overview: null,
                        firstAirDate: null,
                        originalLanguage: null,
                        originalName: item.title,
                        popularity: null,
                        voteCount: null,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TVDetailPage(
                            tvSeries: tvSeries,
                            heroId: heroId,
                          ),
                        ),
                      );
                    } else {
                      final movie = Movie(
                        id: item.tmdbId,
                        title: item.title,
                        posterPath: item.posterPath,
                        backdropPath: item.backdropPath,
                        voteAverage: item.voteAverage,
                        overview: null,
                        releaseDate: null,
                        adult: false,
                        originalLanguage: null,
                        originalTitle: item.title,
                        popularity: null,
                        video: false,
                        voteCount: null,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovieDetailPage(
                            movie: movie,
                            heroId: heroId,
                          ),
                        ),
                      );
                    }
                  },
                  child: SizedBox(
                    width: 110,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Poster with rating badge
                        Expanded(
                          flex: 6,
                          child: Hero(
                            tag: '${row.id}-${item.tmdbId}-$index',
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: posterUrl.isEmpty
                                      ? Image.asset(
                                          'assets/images/na_logo.png',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        )
                                      : CachedNetworkImage(
                                          cacheManager: cacheProp(),
                                          imageUrl: posterUrl,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          placeholder: (_, __) =>
                                              scrollingImageShimmer(themeMode),
                                          errorWidget: (_, __, ___) =>
                                              Image.asset(
                                            'assets/images/na_logo.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                                // Star rating badge
                                if (item.voteAverage != null)
                                  Positioned(
                                    top: 6,
                                    left: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black
                                            .withValues(alpha: 0.65),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            size: 11,
                                            color: Color(0xFFFACC15),
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            item.voteAverage!
                                                .toStringAsFixed(1),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        // Title
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(2, 5, 2, 0),
                            child: Text(
                              item.title ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: textPrim,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Divider(
          color: isDark ? Colors.white12 : Colors.black12,
          thickness: 1,
          endIndent: 20,
          indent: 10,
        ),
      ],
    );
  }
}

