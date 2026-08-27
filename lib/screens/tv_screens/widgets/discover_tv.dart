import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/functions/network.dart';
import 'package:reelriot/models/dropdown_select.dart';
import 'package:reelriot/models/filter_chip.dart';
import 'package:reelriot/models/live_tv.dart';
import 'package:reelriot/models/tv.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/tv_screens/live_event_screen.dart';
import 'package:reelriot/screens/tv_screens/tv_detail_page.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/utils/constant.dart';
import 'package:reelriot/utils/sports_helpers.dart';
import 'package:reelriot/utils/theme/textStyle.dart';
import 'package:reelriot/widgets/common_widgets.dart';
import 'package:reelriot/widgets/shimmer_widget.dart';

class _C {
  static const primary = Color(0xFFDC2626);
  static const textSec = Color(0xB8FFFFFF);
}

class DiscoverTV extends StatefulWidget {
  final bool includeAdult;
  const DiscoverTV(
      {required this.includeAdult, required this.discoverType, super.key});

  final String discoverType;
  @override
  DiscoverTVState createState() => DiscoverTVState();
}

class DiscoverTVState extends State<DiscoverTV>
    with AutomaticKeepAliveClientMixin {
  List<TV>? tvList;
  YearDropdownData yearDropdownData = YearDropdownData();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    getData();
  }

  List<TVGenreFilterChipWidget> tvGenreList = <TVGenreFilterChipWidget>[
    TVGenreFilterChipWidget(
        genreName: tr('action_and_adventure'), genreValue: '10759'),
    TVGenreFilterChipWidget(genreName: tr('animation'), genreValue: '16'),
    TVGenreFilterChipWidget(genreName: tr('comedy'), genreValue: '35'),
    TVGenreFilterChipWidget(genreName: tr('crime'), genreValue: '80'),
    TVGenreFilterChipWidget(genreName: tr('documentary'), genreValue: '99'),
    TVGenreFilterChipWidget(genreName: tr('drama'), genreValue: '18'),
    TVGenreFilterChipWidget(genreName: tr('family'), genreValue: '10751'),
    TVGenreFilterChipWidget(genreName: tr('kids'), genreValue: '10762'),
    TVGenreFilterChipWidget(genreName: tr('mystery'), genreValue: '9648'),
    TVGenreFilterChipWidget(genreName: tr('news'), genreValue: '10763'),
    TVGenreFilterChipWidget(genreName: tr('reality'), genreValue: '10764'),
    TVGenreFilterChipWidget(
        genreName: tr('scifi_and_fantasy'), genreValue: '10765'),
    TVGenreFilterChipWidget(genreName: tr('soap'), genreValue: '10766'),
    TVGenreFilterChipWidget(genreName: tr('talk'), genreValue: '10767'),
    TVGenreFilterChipWidget(
        genreName: tr('war_and_politics'), genreValue: '10768'),
    TVGenreFilterChipWidget(genreName: tr('western'), genreValue: '37'),
  ];

  void getData() {
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    List<String> years = yearDropdownData.yearsList.getRange(1, 26).toList();
    List<TVGenreFilterChipWidget> genres = tvGenreList;
    years.shuffle();
    genres.shuffle();
    fetchTV(
      '$tmdbApiBaseUrl/discover/tv?api_key=$tmdbApiKey&sort_by=popularity.desc&watch_region=US&first_air_date_year=${years.first}&with_genres=${genres.first.genreValue}',
      isProxyEnabled,
      proxyUrl,
    ).then((value) {
      if (mounted) {
        setState(() {
          tvList = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = Provider.of<SettingsProvider>(context);
    final appDep = Provider.of<AppDependencyProvider>(context);
    final imageQuality = settings.imageQuality;
    final themeMode = settings.appTheme;
    final isProxyEnabled = settings.enableProxy;
    final proxyUrl = appDep.tmdbProxy;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;
    final isLargeTablet = screenWidth >= 1000;
    final double carouselHeight =
        isLargeTablet ? 380.0 : (isTablet ? 340.0 : 230.0);
    final double viewportFraction =
        isLargeTablet ? 0.94 : (isTablet ? 0.92 : 0.88);

    if (tvList == null) {
      return SizedBox(
        height: carouselHeight,
        child: discoverMoviesAndTVShimmer(themeMode),
      );
    }

    final sportsSlides =
        (appDep.displayOTTDrawer && appDep.featuredEvents.isNotEmpty)
            ? appDep.featuredEvents
                .where((e) =>
                    !appDep.isSportRowHidden(e.sport, title: e.title))
                .take(3)
                .toList()
            : <FeaturedEvent>[];

    final tvs = tvList!.take(8).toList();
    final totalCount = sportsSlides.length + tvs.length;

    if (totalCount == 0) return const SizedBox.shrink();

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 12.0 : 8.0),
                child: Row(
                  children: [
                    const LeadingDot(),
                    Expanded(
                      child: Text(
                        tr("featured_tv_shows"),
                        style: kTextHeaderStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          height: carouselHeight,
          child: CarouselSlider.builder(
            options: CarouselOptions(
              height: carouselHeight,
              viewportFraction: viewportFraction,
              enlargeCenterPage: true,
              enlargeFactor: isTablet ? 0.12 : 0.10,
              enableInfiniteScroll: totalCount > 2,
              autoPlay: totalCount > 1,
              autoPlayInterval: const Duration(seconds: 5),
              autoPlayCurve: Curves.easeInOut,
              onPageChanged: (i, _) => setState(() => _currentPage = i),
            ),
            itemCount: totalCount,
            itemBuilder: (BuildContext context, int index, int _) {
              if (index < sportsSlides.length) {
                return _SportHeroSlide(
                  event: sportsSlides[index],
                  isTablet: isTablet,
                );
              }
              final tv = tvs[index - sportsSlides.length];
              return _TVHeroSlide(
                tv: tv,
                heroTag: '${tv.id}-${widget.discoverType}-$index',
                isDark: isDark,
                themeMode: themeMode,
                imageQuality: imageQuality,
                isProxyEnabled: isProxyEnabled,
                proxyUrl: proxyUrl,
                isTablet: isTablet,
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalCount, (i) {
            final active = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? (isTablet ? 26 : 20) : (isTablet ? 8 : 6),
              height: isTablet ? 8 : 6,
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

  @override
  bool get wantKeepAlive => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// TV Hero Slide
// ─────────────────────────────────────────────────────────────────────────────

class _TVHeroSlide extends StatelessWidget {
  final TV tv;
  final String heroTag;
  final bool isDark;
  final String themeMode;
  final String imageQuality;
  final bool isProxyEnabled;
  final String proxyUrl;
  final bool isTablet;

  const _TVHeroSlide({
    required this.tv,
    required this.heroTag,
    required this.isDark,
    required this.themeMode,
    required this.imageQuality,
    required this.isProxyEnabled,
    required this.proxyUrl,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final imgBase =
        buildImageUrl(tmdbBaseImageUrl, proxyUrl, isProxyEnabled, context);
    final backdropUrl = (tv.backdropPath != null && tv.backdropPath!.isNotEmpty)
        ? '$imgBase$imageQuality${tv.backdropPath}'
        : (tv.posterPath != null && tv.posterPath!.isNotEmpty
            ? '$imgBase$imageQuality${tv.posterPath}'
            : '');
    final rating = tv.voteAverage != null && tv.voteAverage! > 0
        ? tv.voteAverage!.toStringAsFixed(1)
        : '';
    final releaseYear =
        tv.firstAirDate != null && tv.firstAirDate!.length >= 4
            ? tv.firstAirDate!.substring(0, 4)
            : '';
    final overview = tv.overview?.trim() ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TVDetailPage(
              tvSeries: tv,
              heroId: heroTag,
            ),
          ),
        );
      },
      child: Hero(
        tag: heroTag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isTablet ? 20.0 : 16.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Backdrop image
              backdropUrl.isEmpty
                  ? Image.asset('assets/images/na_logo.png', fit: BoxFit.cover)
                  : CachedNetworkImage(
                      imageUrl: backdropUrl,
                      fit: BoxFit.cover,
                      cacheManager: cacheProp(),
                      placeholder: (_, __) => discoverImageShimmer(themeMode),
                      errorWidget: (_, __, ___) => Image.asset(
                        'assets/images/na_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),

              // Multi-layer Dark Gradient
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: isTablet ? 0.45 : 0.4),
                        Colors.black.withValues(alpha: isTablet ? 0.92 : 0.88),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              if (isTablet)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.82),
                          Colors.black.withValues(alpha: 0.45),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),

              // Foreground content
              Positioned(
                left: isTablet ? 24 : 16,
                right: isTablet ? 24 : 16,
                bottom: isTablet ? 22 : 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge: FEATURED TV + Rating + Year
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 10 : 8,
                            vertical: isTablet ? 4 : 3,
                          ),
                          decoration: BoxDecoration(
                            color: _C.primary.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _C.primary.withValues(alpha: 0.6),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: isTablet ? 7 : 6,
                                height: isTablet ? 7 : 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDC2626),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: isTablet ? 6 : 5),
                              Text(
                                'FEATURED TV',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 11 : 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (rating.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 8 : 6,
                              vertical: isTablet ? 4 : 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFFACC15)
                                    .withValues(alpha: 0.4),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: isTablet ? 14 : 12,
                                  color: const Color(0xFFFACC15),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  rating,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 11 : 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (releaseYear.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            releaseYear,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isTablet ? 12 : 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: isTablet ? 8 : 6),

                    // Title
                    Text(
                      tv.name ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 26 : 18,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'PoppinsSB',
                        letterSpacing: -0.3,
                        shadows: const [
                          Shadow(color: Colors.black87, blurRadius: 8)
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Overview on tablets
                    if (isTablet && overview.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 580),
                        child: Text(
                          overview,
                          style: const TextStyle(
                            color: Color(0xCCFFFFFF),
                            fontSize: 13,
                            height: 1.35,
                            fontWeight: FontWeight.w400,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 4)
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],

                    // Action buttons
                    if (isTablet) ...[
                      const SizedBox(height: 14),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _C.primary,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _C.primary.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.play_arrow_rounded,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 6),
                                Text(
                                  'Watch Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white30,
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.info_outline_rounded,
                                    color: Colors.white, size: 17),
                                SizedBox(width: 6),
                                Text(
                                  'Details',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
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
// Sports Hero Slide
// ─────────────────────────────────────────────────────────────────────────────

class _SportHeroSlide extends StatelessWidget {
  final FeaturedEvent event;
  final bool isTablet;
  const _SportHeroSlide({required this.event, this.isTablet = false});

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
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
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
          borderRadius: BorderRadius.circular(isTablet ? 19 : 15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background thumbnail
              if (event.thumbnailUrl.isNotEmpty)
                Opacity(
                  opacity: 0.25,
                  child: CachedNetworkImage(
                    imageUrl: event.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),

              // Sport watermark silhouette
              Positioned(
                right: -10,
                bottom: -15,
                child: Opacity(
                  opacity: 0.12,
                  child: Icon(
                    theme.icon,
                    size: isTablet ? 200 : 150,
                    color: Colors.white,
                  ),
                ),
              ),

              // Dark gradient overlay
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

              // LIVE badge + title + action
              Positioned(
                left: isTablet ? 24 : 16,
                right: isTablet ? 24 : 16,
                bottom: isTablet ? 22 : 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 10 : 8,
                            vertical: isTablet ? 4 : 3,
                          ),
                          decoration: BoxDecoration(
                            color: theme.accentColor.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: theme.accentColor.withValues(alpha: 0.6),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: isTablet ? 8 : 6,
                                height: isTablet ? 8 : 6,
                                decoration: BoxDecoration(
                                  color: theme.accentColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: isTablet ? 7 : 5),
                              Text(
                                '${theme.label} · LIVE NOW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 12 : 10,
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 24 : 16,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'PoppinsSB',
                        shadows: const [
                          Shadow(color: Colors.black87, blurRadius: 6)
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isTablet) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.accentColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: theme.accentColor.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow_rounded,
                                color: Colors.white, size: 20),
                            SizedBox(width: 6),
                            Text(
                              'Watch Stream',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
