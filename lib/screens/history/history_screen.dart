import 'package:get/get.dart';
import 'package:reelriot/utils/routes/app_pages.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/models/movie_models.dart';
import 'package:reelriot/models/recently_watched.dart';
import 'package:reelriot/models/tv.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/recently_watched_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/provider/sign_in_provider.dart';
import 'package:reelriot/screens/movie_screens/movie_details.dart';
import 'package:reelriot/screens/tv_screens/tv_detail_page.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/utils/constant.dart';
import 'package:reelriot/widgets/mobile_context_menu.dart';

// ─── Design Tokens ─────────────────────────────────────────────────────────────
class _C {
  static const primary = Color(0xFFDC2626);
  static const primaryGlow = Color(0x33DC2626);
  static const secondary = Color(0xFF7C3AED);
  static const success = Color(0xFF10B981);
  static const ratingGold = Color(0xFFEAB308);

  static const bgCanvasDark = Color(0xFF030712);
  static const bgSurfaceDark = Color(0xFF0B0F14);
  static const bgElevatedDark = Color(0xFF111827);
  static const bgCardDark = Color(0xFF1F2937);

  static const bgCanvasLight = Color(0xFFF8FAFC);
  static const bgSurfaceLight = Color(0xFFFFFFFF);
  static const bgElevatedLight = Color(0xFFF1F5F9);
  static const bgCardLight = Color(0xFFE2E8F0);

  static const borderDark = Color(0x14FFFFFF);
  static const borderLight = Color(0x140F172A);

  static const textPrimDark = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
  static const textSecDark = Color(0xB8FFFFFF);
  static const textSecLight = Color(0xFF64748B);
  static const textTertDark = Color(0x80FFFFFF);
  static const textTertLight = Color(0xFF94A3B8);
}

enum _HistoryFilter { all, inProgress, completed }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  _HistoryFilter _selectedFilter = _HistoryFilter.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final signIn = Provider.of<SignInProvider>(context, listen: false);
      final recentPrv = Provider.of<RecentProvider>(context, listen: false);
      if (!signIn.isSignedIn) {
        recentPrv.clearLocalData();
        return;
      }
      recentPrv.fetchMovies();
      recentPrv.fetchEpisodes();
      recentPrv.syncFromCloud();
      recentPrv.fetchWatchStatsFromApi();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final signIn = Provider.of<SignInProvider>(context, listen: false);
    final recentPrv = Provider.of<RecentProvider>(context, listen: false);
    if (!signIn.isSignedIn) {
      await recentPrv.clearLocalData();
      return;
    }
    await recentPrv.syncFromCloud();
    await recentPrv.fetchMovies();
    await recentPrv.fetchEpisodes();
    await recentPrv.fetchWatchStatsFromApi();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recentPrv = context.watch<RecentProvider>();
    final signIn = context.watch<SignInProvider>();

    final bg = isDark ? _C.bgCanvasDark : _C.bgCanvasLight;
    final surface = isDark ? _C.bgSurfaceDark : _C.bgSurfaceLight;
    final elevated = isDark ? _C.bgElevatedDark : _C.bgElevatedLight;
    final border = isDark ? _C.borderDark : _C.borderLight;
    final textPrim = isDark ? _C.textPrimDark : _C.textPrimLight;
    final textSec = isDark ? _C.textSecDark : _C.textSecLight;
    final textTert = isDark ? _C.textTertDark : _C.textTertLight;

    final moviesCount = signIn.isSignedIn ? recentPrv.movies.length : 0;
    final tvCount = signIn.isSignedIn ? recentPrv.episodes.length : 0;
    final totalCount = moviesCount + tvCount;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                // ── Top App Bar ──────────────────────────────────────────────────
                Container(
                  color: surface,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Row(
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: elevated,
                                    border: Border.all(color: border, width: 1),
                                  ),
                                  child: Icon(Icons.arrow_back_rounded, size: 20, color: textPrim),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
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
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  Text(
                                    signIn.isSignedIn
                                        ? '$totalCount ${tr('items')} • $moviesCount ${tr('movies')}, $tvCount ${tr('tv_series')}'
                                        : 'Sign in to access your history',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textTert,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (signIn.isSignedIn)
                              IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: elevated,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: border, width: 1),
                                  ),
                                  child: Icon(
                                    Icons.refresh_rounded,
                                    color: textSec,
                                    size: 18,
                                  ),
                                ),
                                onPressed: _refresh,
                                tooltip: tr('refresh'),
                              ),
                          ],
                        ),
                      ),

                      // ── Stats Summary Banner (Tablet & Mobile) ─────────────
                      if (signIn.isSignedIn && totalCount > 0)
                        _WatchStatsBanner(
                          recentPrv: recentPrv,
                          isDark: isDark,
                          elevated: elevated,
                          border: border,
                          textPrim: textPrim,
                          textSec: textSec,
                          textTert: textTert,
                        ),

                      // ── Tab Bar & Filter Controls (Only if signed in) ──────
                      if (signIn.isSignedIn)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                          child: Row(
                            children: [
                              // Main Category Tabs (All, Movies, TV)
                              Expanded(
                                child: Container(
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: elevated,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: border),
                                  ),
                                  child: TabBar(
                                    controller: _tabController,
                                    indicator: BoxDecoration(
                                      color: _C.primary,
                                      borderRadius: BorderRadius.circular(11),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _C.primary.withValues(alpha: 0.35),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    dividerColor: Colors.transparent,
                                    labelColor: Colors.white,
                                    unselectedLabelColor: textSec,
                                    labelStyle: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'PoppinsSB',
                                    ),
                                    tabs: [
                                      Tab(text: 'All ($totalCount)'),
                                      Tab(text: '${tr('movies')} ($moviesCount)'),
                                      Tab(text: '${tr('tv_series')} ($tvCount)'),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Filter Status Menu Button (All, In Progress, Completed)
                              _FilterStatusButton(
                                selected: _selectedFilter,
                                isDark: isDark,
                                elevated: elevated,
                                border: border,
                                textPrim: textPrim,
                                onSelected: (filter) => setState(() => _selectedFilter = filter),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Body Content ──────────────────────────────────────────────
                Expanded(
                  child: !signIn.isSignedIn
                      ? _SignedOutHistoryView(
                          isDark: isDark,
                          elevated: elevated,
                          border: border,
                          textPrim: textPrim,
                          textSec: textSec,
                          textTert: textTert,
                        )
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _UnifiedHistoryTab(
                              movies: recentPrv.movies,
                              episodes: recentPrv.episodes,
                              filter: _selectedFilter,
                              isDark: isDark,
                              onRefresh: _refresh,
                            ),
                            _MoviesHistoryTab(
                              movies: recentPrv.movies,
                              filter: _selectedFilter,
                              isDark: isDark,
                              onRefresh: _refresh,
                            ),
                            _TvHistoryTab(
                              episodes: recentPrv.episodes,
                              filter: _selectedFilter,
                              isDark: isDark,
                              onRefresh: _refresh,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Signed Out Full History View ─────────────────────────────────────────────

class _SignedOutHistoryView extends StatelessWidget {
  final bool isDark;
  final Color elevated;
  final Color border;
  final Color textPrim;
  final Color textSec;
  final Color textTert;

  const _SignedOutHistoryView({
    required this.isDark,
    required this.elevated,
    required this.border,
    required this.textPrim,
    required this.textSec,
    required this.textTert,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.primary.withValues(alpha: 0.1),
                border: Border.all(color: _C.primary.withValues(alpha: 0.25), width: 1.5),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 52,
                color: _C.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sign In to View Watch History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textPrim,
                fontFamily: 'PoppinsSB',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Your playback progress and watched titles are securely saved to your account. Sign in to resume movies and TV shows across all your mobile and TV devices.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: textTert,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Get.toNamed(Routes.login),
              style: FilledButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
                shadowColor: _C.primary.withValues(alpha: 0.4),
              ),
              icon: const Icon(Icons.login_rounded, size: 18),
              label: const Text(
                'Sign In Now',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Watch Stats Banner ────────────────────────────────────────────────────────

class _WatchStatsBanner extends StatelessWidget {
  final RecentProvider recentPrv;
  final bool isDark;
  final Color elevated;
  final Color border;
  final Color textPrim;
  final Color textSec;
  final Color textTert;

  const _WatchStatsBanner({
    required this.recentPrv,
    required this.isDark,
    required this.elevated,
    required this.border,
    required this.textPrim,
    required this.textSec,
    required this.textTert,
  });

  @override
  Widget build(BuildContext context) {
    int totalMins = 0;
    for (var m in recentPrv.movies) {
      totalMins += ((m.elapsed ?? 0) ~/ 60000);
    }
    for (var e in recentPrv.episodes) {
      totalMins += ((e.elapsed ?? 0) ~/ 60000);
    }

    final formattedWatchTime = recentPrv.formatWatchTime(totalMins);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: elevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _C.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.timer_outlined, size: 18, color: _C.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Time Watched',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: textTert,
                    ),
                  ),
                  Text(
                    formattedWatchTime.isEmpty ? '0m' : formattedWatchTime,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textPrim,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 24,
              width: 1,
              color: border,
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'In Progress',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textTert,
                  ),
                ),
                Text(
                  '${recentPrv.continueWatchingMovies.length + recentPrv.inProgressEpisodes.length} active',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _C.ratingGold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Status Button ──────────────────────────────────────────────────────

class _FilterStatusButton extends StatelessWidget {
  final _HistoryFilter selected;
  final bool isDark;
  final Color elevated;
  final Color border;
  final Color textPrim;
  final ValueChanged<_HistoryFilter> onSelected;

  const _FilterStatusButton({
    required this.selected,
    required this.isDark,
    required this.elevated,
    required this.border,
    required this.textPrim,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_HistoryFilter>(
      initialValue: selected,
      onSelected: onSelected,
      color: isDark ? const Color(0xFF1F2937) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: _HistoryFilter.all,
          child: Row(
            children: [
              Icon(Icons.list_alt_rounded, size: 16, color: selected == _HistoryFilter.all ? _C.primary : textPrim),
              const SizedBox(width: 8),
              Text('All Statuses', style: TextStyle(fontWeight: selected == _HistoryFilter.all ? FontWeight.w700 : FontWeight.w500)),
            ],
          ),
        ),
        PopupMenuItem(
          value: _HistoryFilter.inProgress,
          child: Row(
            children: [
              Icon(Icons.timelapse_rounded, size: 16, color: selected == _HistoryFilter.inProgress ? _C.primary : _C.ratingGold),
              const SizedBox(width: 8),
              Text('In Progress', style: TextStyle(fontWeight: selected == _HistoryFilter.inProgress ? FontWeight.w700 : FontWeight.w500)),
            ],
          ),
        ),
        PopupMenuItem(
          value: _HistoryFilter.completed,
          child: Row(
            children: [
              Icon(Icons.check_circle_rounded, size: 16, color: selected == _HistoryFilter.completed ? _C.primary : _C.success),
              const SizedBox(width: 8),
              Text('Completed', style: TextStyle(fontWeight: selected == _HistoryFilter.completed ? FontWeight.w700 : FontWeight.w500)),
            ],
          ),
        ),
      ],
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected == _HistoryFilter.all ? elevated : _C.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected == _HistoryFilter.all ? border : _C.primary.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list_rounded,
              size: 16,
              color: selected == _HistoryFilter.all ? textPrim : _C.primary,
            ),
            const SizedBox(width: 6),
            Text(
              selected == _HistoryFilter.all
                  ? 'Filter'
                  : (selected == _HistoryFilter.inProgress ? 'Active' : 'Done'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected == _HistoryFilter.all ? textPrim : _C.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Unified History Tab (Combined Movies & TV) ────────────────────────────────

class _UnifiedHistoryTab extends StatelessWidget {
  final List<RecentMovie> movies;
  final List<RecentEpisode> episodes;
  final _HistoryFilter filter;
  final bool isDark;
  final Future<void> Function() onRefresh;

  const _UnifiedHistoryTab({
    required this.movies,
    required this.episodes,
    required this.filter,
    required this.isDark,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Combine and sort chronologically
    final List<dynamic> allItems = [];

    final filteredMovies = movies.where((m) {
      final elapsed = m.elapsed ?? 0;
      final remaining = m.remaining ?? 0;
      final isCompleted = remaining == 0 && elapsed > 0;
      if (filter == _HistoryFilter.inProgress) return !isCompleted;
      if (filter == _HistoryFilter.completed) return isCompleted;
      return true;
    }).toList();

    final filteredEpisodes = episodes.where((e) {
      final elapsed = e.elapsed ?? 0;
      final remaining = e.remaining ?? 0;
      final isCompleted = remaining == 0 && elapsed > 0;
      if (filter == _HistoryFilter.inProgress) return !isCompleted;
      if (filter == _HistoryFilter.completed) return isCompleted;
      return true;
    }).toList();

    allItems.addAll(filteredMovies);
    allItems.addAll(filteredEpisodes);

    // Sort by dateTime descending
    allItems.sort((a, b) {
      final da = a is RecentMovie ? (a.dateTime ?? '') : (a as RecentEpisode).dateTime ?? '';
      final db = b is RecentMovie ? (b.dateTime ?? '') : (b as RecentEpisode).dateTime ?? '';
      return db.compareTo(da);
    });

    if (allItems.isEmpty) {
      return _EmptyHistoryView(
        icon: Icons.history_rounded,
        message: filter == _HistoryFilter.all
            ? 'Your watch history is empty. Start streaming movies or TV shows to track progress here.'
            : (filter == _HistoryFilter.inProgress ? 'No items in progress.' : 'No completed titles.'),
        isDark: isDark,
      );
    }

    return _ResponsiveHistoryGrid(
      items: allItems,
      isDark: isDark,
      onRefresh: onRefresh,
    );
  }
}

// ─── Movies History Tab ────────────────────────────────────────────────────────

class _MoviesHistoryTab extends StatelessWidget {
  final List<RecentMovie> movies;
  final _HistoryFilter filter;
  final bool isDark;
  final Future<void> Function() onRefresh;

  const _MoviesHistoryTab({
    required this.movies,
    required this.filter,
    required this.isDark,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final filteredMovies = movies.where((m) {
      final elapsed = m.elapsed ?? 0;
      final remaining = m.remaining ?? 0;
      final isCompleted = remaining == 0 && elapsed > 0;
      if (filter == _HistoryFilter.inProgress) return !isCompleted;
      if (filter == _HistoryFilter.completed) return isCompleted;
      return true;
    }).toList();

    if (filteredMovies.isEmpty) {
      return _EmptyHistoryView(
        icon: Icons.movie_outlined,
        message: filter == _HistoryFilter.all
            ? tr('no_movies_bookmarked')
            : (filter == _HistoryFilter.inProgress ? 'No movies in progress.' : 'No completed movies.'),
        isDark: isDark,
      );
    }

    return _ResponsiveHistoryGrid(
      items: filteredMovies,
      isDark: isDark,
      onRefresh: onRefresh,
    );
  }
}

// ─── TV History Tab ───────────────────────────────────────────────────────────

class _TvHistoryTab extends StatelessWidget {
  final List<RecentEpisode> episodes;
  final _HistoryFilter filter;
  final bool isDark;
  final Future<void> Function() onRefresh;

  const _TvHistoryTab({
    required this.episodes,
    required this.filter,
    required this.isDark,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final filteredEpisodes = episodes.where((e) {
      final elapsed = e.elapsed ?? 0;
      final remaining = e.remaining ?? 0;
      final isCompleted = remaining == 0 && elapsed > 0;
      if (filter == _HistoryFilter.inProgress) return !isCompleted;
      if (filter == _HistoryFilter.completed) return isCompleted;
      return true;
    }).toList();

    if (filteredEpisodes.isEmpty) {
      return _EmptyHistoryView(
        icon: Icons.live_tv_outlined,
        message: filter == _HistoryFilter.all
            ? tr('no_tv_bookmarked')
            : (filter == _HistoryFilter.inProgress ? 'No TV episodes in progress.' : 'No completed episodes.'),
        isDark: isDark,
      );
    }

    return _ResponsiveHistoryGrid(
      items: filteredEpisodes,
      isDark: isDark,
      onRefresh: onRefresh,
    );
  }
}

// ─── Responsive History Grid (Phone & Tablet) ──────────────────────────────────

class _ResponsiveHistoryGrid extends StatelessWidget {
  final List<dynamic> items;
  final bool isDark;
  final Future<void> Function() onRefresh;

  const _ResponsiveHistoryGrid({
    required this.items,
    required this.isDark,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final appDep = Provider.of<AppDependencyProvider>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final recentPrv = Provider.of<RecentProvider>(context, listen: false);

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final screenW = constraints.maxWidth;
        // Responsive columns:
        // Phone (< 680px): 1 column wide card
        // Tablet Portrait (680px - 1000px): 2 columns
        // Large Tablet Landscape (> 1000px): 3 columns
        final int cols = screenW > 1000 ? 3 : (screenW > 680 ? 2 : 1);

        return RefreshIndicator(
          onRefresh: onRefresh,
          color: _C.primary,
          child: cols == 1
              ? ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildItemCard(
                        context,
                        item,
                        appDep,
                        settings,
                        recentPrv,
                        isDark,
                      ),
                    );
                  },
                )
              : GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 122,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildItemCard(
                      context,
                      item,
                      appDep,
                      settings,
                      recentPrv,
                      isDark,
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    dynamic item,
    AppDependencyProvider appDep,
    SettingsProvider settings,
    RecentProvider recentPrv,
    bool isDark,
  ) {
    final imgBase = buildImageUrl(
      tmdbBaseImageUrl,
      appDep.tmdbProxy,
      settings.enableProxy,
      context,
    );

    if (item is RecentMovie) {
      final elapsed = item.elapsed ?? 0;
      final remaining = item.remaining ?? 0;
      final total = elapsed + remaining;
      final isCompleted = remaining == 0 && elapsed > 0;
      final progress = total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 0.0;
      final posterUrl = item.posterPath != null && item.posterPath!.isNotEmpty
          ? '$imgBase${settings.imageQuality}${item.posterPath}'
          : '';

      return _HistoryCard(
        title: item.title ?? tr('unknown'),
        subtitle: '${item.releaseYear ?? ''}',
        mediaTypeTag: 'Movie',
        posterUrl: posterUrl,
        progress: progress,
        isCompleted: isCompleted,
        timeText: isCompleted
            ? tr('completed')
            : '${(progress * 100).toInt()}% • ${recentPrv.formatWatchTime(elapsed ~/ 60000)} / ${recentPrv.formatWatchTime(total ~/ 60000)}',
        isDark: isDark,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MovieDetailPage(
                movie: Movie(
                  id: item.id,
                  title: item.title,
                  posterPath: item.posterPath,
                  backdropPath: item.backdropPath,
                  releaseDate: item.releaseYear?.toString(),
                ),
                heroId: 'history_movie_${item.id}',
              ),
            ),
          );
        },
        onLongPress: () {
          MobileContextMenu.show(
            context: context,
            title: item.title ?? '',
            subtitle: '${item.releaseYear ?? ''}',
            items: [
              if (!isCompleted)
                MobileContextMenuItem(
                  label: tr('mark_as_completed'),
                  icon: Icons.check_circle_outline,
                  onTap: () => recentPrv.markMovieAsCompleted(item),
                ),
              MobileContextMenuItem(
                label: tr('remove_from_history'),
                icon: Icons.delete_outline,
                color: Colors.red,
                onTap: () => recentPrv.deleteMovie(item.id!),
              ),
            ],
          );
        },
        onDelete: () => recentPrv.deleteMovie(item.id!),
      );
    } else {
      final ep = item as RecentEpisode;
      final elapsed = ep.elapsed ?? 0;
      final remaining = ep.remaining ?? 0;
      final total = elapsed + remaining;
      final isCompleted = remaining == 0 && elapsed > 0;
      final progress = total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 0.0;
      final posterUrl = ep.posterPath != null && ep.posterPath!.isNotEmpty
          ? '$imgBase${settings.imageQuality}${ep.posterPath}'
          : '';
      final sNum = ep.seasonNum ?? 1;
      final eNum = ep.episodeNum ?? 1;
      final epTitle = ep.episodeName != null && ep.episodeName!.isNotEmpty
          ? ep.episodeName!
          : 'Episode $eNum';

      return _HistoryCard(
        title: ep.seriesName ?? tr('unknown'),
        subtitle: 'S$sNum · E$eNum • $epTitle',
        mediaTypeTag: 'TV',
        posterUrl: posterUrl,
        progress: progress,
        isCompleted: isCompleted,
        timeText: isCompleted
            ? tr('completed')
            : '${(progress * 100).toInt()}% • ${recentPrv.formatWatchTime(elapsed ~/ 60000)} / ${recentPrv.formatWatchTime(total ~/ 60000)}',
        isDark: isDark,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TVDetailPage(
                tvSeries: TV(
                  id: ep.seriesId,
                  name: ep.seriesName,
                  posterPath: ep.posterPath,
                ),
                heroId: 'history_tv_${ep.seriesId}',
              ),
            ),
          );
        },
        onLongPress: () {
          MobileContextMenu.show(
            context: context,
            title: ep.seriesName ?? '',
            subtitle: 'S$sNum · E$eNum • $epTitle',
            items: [
              if (!isCompleted)
                MobileContextMenuItem(
                  label: tr('mark_as_completed'),
                  icon: Icons.check_circle_outline,
                  onTap: () => recentPrv.markEpisodeAsCompleted(ep),
                ),
              MobileContextMenuItem(
                label: tr('remove_from_history'),
                icon: Icons.delete_outline,
                color: Colors.red,
                onTap: () => recentPrv.deleteEpisode(
                  ep.id!,
                  ep.episodeNum!,
                  ep.seasonNum!,
                ),
              ),
            ],
          );
        },
        onDelete: () => recentPrv.deleteEpisode(
          ep.id!,
          ep.episodeNum!,
          ep.seasonNum!,
        ),
      );
    }
  }
}

// ─── Reusable History Card ────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? mediaTypeTag;
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
    this.mediaTypeTag,
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
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // ── Thumbnail / Poster ──────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 68,
                  height: 98,
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
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 1),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      if (mediaTypeTag != null)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              mediaTypeTag!,
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: Colors.white70,
                              ),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textPrim,
                              fontFamily: 'PoppinsSB',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: onDelete,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 6, bottom: 2),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: textTert,
                            ),
                          ),
                        ),
                      ],
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
                        minHeight: 4.5,
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
                                size: 13,
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
                        if (!isCompleted && progress > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: _C.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Resume',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _C.primary,
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0x18FFFFFF) : const Color(0x0A000000),
              ),
              child: Icon(
                icon,
                size: 48,
                color: textTert.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              tr('watch_history'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textPrim,
                fontFamily: 'PoppinsSB',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: textTert,
                fontFamily: 'Poppins',
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
