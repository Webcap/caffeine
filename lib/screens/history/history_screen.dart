import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/models/movie_stream_metadata.dart';
import 'package:reelriot/models/recently_watched.dart';
import 'package:reelriot/models/tv_stream_metadata.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/recently_watched_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/utils/constant.dart';
import 'package:reelriot/utils/globals.dart';
import 'package:reelriot/utils/globlal_methods.dart';
import 'package:reelriot/utils/theme/textStyle.dart';
import 'package:reelriot/widgets/mobile_context_menu.dart';
import 'package:reelriot/widgets/shimmer_widget.dart';
import 'package:reelriot/widgets/unified_video_loader.dart';

// ─── Design Tokens ─────────────────────────────────────────────────────────────
class _C {
  static const primary = Color(0xFFDC2626);
  static const secondary = Color(0xFF7C3AED);
  static const success = Color(0xFF10B981);

  static const bgCanvasDark = Color(0xFF030712);
  static const bgSurfaceDark = Color(0xFF0B0F14);
  static const bgElevatedDark = Color(0xFF111827);

  static const bgCanvasLight = Color(0xFFF8FAFC);
  static const bgSurfaceLight = Color(0xFFFFFFFF);
  static const bgElevatedLight = Color(0xFFF1F5F9);

  static const borderDark = Color(0x14FFFFFF);
  static const borderLight = Color(0x140F172A);

  static const textPrimDark = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
  static const textSecDark = Color(0xB8FFFFFF);
  static const textSecLight = Color(0xFF64748B);
  static const textTertDark = Color(0x80FFFFFF);
  static const textTertLight = Color(0xFF94A3B8);
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final recentPrv = Provider.of<RecentProvider>(context, listen: false);
      recentPrv.fetchMovies();
      recentPrv.fetchEpisodes();
      recentPrv.syncFromCloud();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final recentPrv = Provider.of<RecentProvider>(context, listen: false);
    await recentPrv.syncFromCloud();
    await recentPrv.fetchMovies();
    await recentPrv.fetchEpisodes();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recentPrv = context.watch<RecentProvider>();

    final bg = isDark ? _C.bgCanvasDark : _C.bgCanvasLight;
    final surface = isDark ? _C.bgSurfaceDark : _C.bgSurfaceLight;
    final elevated = isDark ? _C.bgElevatedDark : _C.bgElevatedLight;
    final border = isDark ? _C.borderDark : _C.borderLight;
    final textPrim = isDark ? _C.textPrimDark : _C.textPrimLight;
    final textSec = isDark ? _C.textSecDark : _C.textSecLight;
    final textTert = isDark ? _C.textTertDark : _C.textTertLight;

    final moviesCount = recentPrv.movies.length;
    final tvCount = recentPrv.episodes.length;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top App Bar ──────────────────────────────────────────────────
            Container(
              color: surface,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: textPrim,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr('watch_history'),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: textPrim,
                                  fontFamily: 'PoppinsSB',
                                ),
                              ),
                              Text(
                                '${moviesCount + tvCount} ${tr('items')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textTert,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.refresh_rounded,
                            color: textSec,
                            size: 22,
                          ),
                          onPressed: _refresh,
                          tooltip: tr('refresh'),
                        ),
                      ],
                    ),
                  ),

                  // ── Tab Bar ───────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: elevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: _C.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: Colors.white,
                        unselectedLabelColor: textSec,
                        labelStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'PoppinsSB',
                        ),
                        tabs: [
                          Tab(text: '${tr('movies')} ($moviesCount)'),
                          Tab(text: '${tr('tv_series')} ($tvCount)'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Tab Content ─────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _MoviesHistoryTab(
                    movies: recentPrv.movies,
                    isDark: isDark,
                    onRefresh: _refresh,
                  ),
                  _TvHistoryTab(
                    episodes: recentPrv.episodes,
                    isDark: isDark,
                    onRefresh: _refresh,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Movies History Tab ────────────────────────────────────────────────────────

class _MoviesHistoryTab extends StatelessWidget {
  final List<RecentMovie> movies;
  final bool isDark;
  final Future<void> Function() onRefresh;

  const _MoviesHistoryTab({
    required this.movies,
    required this.isDark,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return _EmptyHistoryView(
        icon: Icons.movie_outlined,
        message: tr('no_movies_bookmarked'),
        isDark: isDark,
      );
    }

    final appDep = Provider.of<AppDependencyProvider>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final recentPrv = Provider.of<RecentProvider>(context, listen: false);

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: _C.primary,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              final elapsed = movie.elapsed ?? 0;
              final remaining = movie.remaining ?? 0;
              final total = elapsed + remaining;
              final isCompleted = remaining == 0 && elapsed > 0;
              final progress = total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 0.0;

              final imgBase = buildImageUrl(
                tmdbBaseImageUrl,
                appDep.tmdbProxy,
                settings.enableProxy,
                context,
              );
              final posterUrl = movie.posterPath != null && movie.posterPath!.isNotEmpty
                  ? '$imgBase${settings.imageQuality}${movie.posterPath}'
                  : '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _HistoryCard(
                  title: movie.title ?? tr('unknown'),
                  subtitle: '${movie.releaseYear ?? ''}',
                  posterUrl: posterUrl,
                  progress: progress,
                  isCompleted: isCompleted,
                  timeText: isCompleted
                      ? tr('completed')
                      : '${(progress * 100).toInt()}% • ${recentPrv.formatWatchTime(elapsed ~/ 60000)} / ${recentPrv.formatWatchTime(total ~/ 60000)}',
                  isDark: isDark,
                  onTap: () async {
                    final connected = await checkConnection();
                    if (!context.mounted) return;
                    if (connected) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UnifiedVideoLoader(
                            mediaType: MediaType.movie,
                            download: false,
                            route: appDep.fetchRoute == 'flixHQ'
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
                        ),
                        context,
                      );
                    }
                  },
                  onLongPress: () {
                    MobileContextMenu.show(
                      context: context,
                      title: movie.title ?? '',
                      subtitle: '${movie.releaseYear ?? ''}',
                      items: [
                        if (!isCompleted)
                          MobileContextMenuItem(
                            label: tr('mark_as_completed'),
                            icon: Icons.check_circle_outline,
                            onTap: () => recentPrv.markMovieAsCompleted(movie),
                          ),
                        MobileContextMenuItem(
                          label: tr('remove_from_history'),
                          icon: Icons.delete_outline,
                          color: Colors.red,
                          onTap: () => recentPrv.deleteMovie(movie.id!),
                        ),
                      ],
                    );
                  },
                  onDelete: () => recentPrv.deleteMovie(movie.id!),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── TV History Tab ───────────────────────────────────────────────────────────

class _TvHistoryTab extends StatelessWidget {
  final List<RecentEpisode> episodes;
  final bool isDark;
  final Future<void> Function() onRefresh;

  const _TvHistoryTab({
    required this.episodes,
    required this.isDark,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (episodes.isEmpty) {
      return _EmptyHistoryView(
        icon: Icons.live_tv_outlined,
        message: tr('no_tv_bookmarked'),
        isDark: isDark,
      );
    }

    final appDep = Provider.of<AppDependencyProvider>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final recentPrv = Provider.of<RecentProvider>(context, listen: false);

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: _C.primary,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: episodes.length,
            itemBuilder: (context, index) {
              final episode = episodes[index];
              final elapsed = episode.elapsed ?? 0;
              final remaining = episode.remaining ?? 0;
              final total = elapsed + remaining;
              final isCompleted = remaining == 0 && elapsed > 0;
              final progress = total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 0.0;

              final imgBase = buildImageUrl(
                tmdbBaseImageUrl,
                appDep.tmdbProxy,
                settings.enableProxy,
                context,
              );
              final posterUrl = episode.posterPath != null && episode.posterPath!.isNotEmpty
                  ? '$imgBase${settings.imageQuality}${episode.posterPath}'
                  : '';

              final sNum = episode.seasonNum ?? 1;
              final eNum = episode.episodeNum ?? 1;
              final epTitle = episode.episodeName != null && episode.episodeName!.isNotEmpty
                  ? episode.episodeName!
                  : 'Episode $eNum';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _HistoryCard(
                  title: episode.seriesName ?? tr('unknown'),
                  subtitle: 'S$sNum:E$eNum • $epTitle',
                  posterUrl: posterUrl,
                  progress: progress,
                  isCompleted: isCompleted,
                  timeText: isCompleted
                      ? tr('completed')
                      : '${(progress * 100).toInt()}% • ${recentPrv.formatWatchTime(elapsed ~/ 60000)} / ${recentPrv.formatWatchTime(total ~/ 60000)}',
                  isDark: isDark,
                  onTap: () async {
                    final connected = await checkConnection();
                    if (!context.mounted) return;
                    if (connected) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UnifiedVideoLoader(
                            mediaType: MediaType.tvShow,
                            download: false,
                            route: appDep.fetchRoute == 'flixHQ'
                                ? StreamRoute.flixHQ
                                : StreamRoute.tmDB,
                            tvMetadata: TVStreamMetadata(
                              tvId: episode.seriesId,
                              seriesName: episode.seriesName,
                              seasonNumber: episode.seasonNum,
                              episodeNumber: episode.episodeNum,
                              episodeName: episode.episodeName,
                              posterPath: episode.posterPath,
                              airDate: null,
                              episodeId: episode.id,
                              elapsed: episode.elapsed,
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
                        ),
                        context,
                      );
                    }
                  },
                  onLongPress: () {
                    MobileContextMenu.show(
                      context: context,
                      title: episode.seriesName ?? '',
                      subtitle: 'S$sNum:E$eNum • $epTitle',
                      items: [
                        if (!isCompleted)
                          MobileContextMenuItem(
                            label: tr('mark_as_completed'),
                            icon: Icons.check_circle_outline,
                            onTap: () => recentPrv.markEpisodeAsCompleted(episode),
                          ),
                        MobileContextMenuItem(
                          label: tr('remove_from_history'),
                          icon: Icons.delete_outline,
                          color: Colors.red,
                          onTap: () => recentPrv.deleteEpisode(
                            episode.id!,
                            episode.episodeNum!,
                            episode.seasonNum!,
                          ),
                        ),
                      ],
                    );
                  },
                  onDelete: () => recentPrv.deleteEpisode(
                    episode.id!,
                    episode.episodeNum!,
                    episode.seasonNum!,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Reusable History Card ────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String posterUrl;
  final double progress;
  final bool isCompleted;
  final String timeText;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.title,
    required this.subtitle,
    required this.posterUrl,
    required this.progress,
    required this.isCompleted,
    required this.timeText,
    required this.isDark,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? _C.bgElevatedDark : _C.bgElevatedLight;
    final border = isDark ? _C.borderDark : _C.borderLight;
    final textPrim = isDark ? _C.textPrimDark : _C.textPrimLight;
    final textSec = isDark ? _C.textSecDark : _C.textSecLight;
    final textTert = isDark ? _C.textTertDark : _C.textTertLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 1),
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // ── Thumbnail / Poster ──────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 68,
                  height: 96,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (posterUrl.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: posterUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: isDark ? Colors.white10 : Colors.black12,
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.black26,
                            child: const Icon(Icons.movie, size: 28),
                          ),
                        )
                      else
                        Container(
                          color: Colors.black26,
                          child: const Icon(Icons.movie, size: 28),
                        ),
                      // Play overlay button
                      Center(
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // ── Metadata & Progress ─────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textPrim,
                        fontFamily: 'PoppinsSB',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: textSec,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: isCompleted ? 1.0 : progress,
                        minHeight: 4,
                        backgroundColor: border.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted ? _C.success : _C.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (isCompleted) ...[
                              const Icon(
                                Icons.check_circle_rounded,
                                color: _C.success,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              timeText,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isCompleted
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isCompleted ? _C.success : textTert,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: onDelete,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: textTert,
                            ),
                          ),
                        ),
                      ],
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

// ─── Empty View ───────────────────────────────────────────────────────────────

class _EmptyHistoryView extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool isDark;

  const _EmptyHistoryView({
    required this.icon,
    required this.message,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textPrim = isDark ? _C.textPrimDark : _C.textPrimLight;
    final textTert = isDark ? _C.textTertDark : _C.textTertLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: textTert.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              tr('watch_history'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textPrim,
                fontFamily: 'PoppinsSB',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: textTert,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
