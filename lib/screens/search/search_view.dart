import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/functions/functions.dart';
import 'package:caffiene/functions/network.dart';
import 'package:caffiene/models/movie_models.dart';
import 'package:caffiene/models/person.dart';
import 'package:caffiene/models/tv.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/movie_screens/movie_details.dart';
import 'package:caffiene/screens/search/searched_person.dart';
import 'package:caffiene/screens/tv_screens/tv_detail_page.dart';
import 'package:caffiene/services/analytics_service.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/utils/constant.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
class _C {
  static const primary = Color(0xFFDC2626);
  static const ratingGold = Color(0xFFEAB308);

  static const bgCanvasDark = Color(0xFF030712);
  static const bgElevatedDark = Color(0xFF111827);
  static const bgCanvasLight = Color(0xFFF8FAFC);
  static const bgElevatedLight = Color(0xFFF1F5F9);

  static const borderDark = Color(0x14FFFFFF);
  static const borderLight = Color(0x140F172A);

  static const textPrimDark = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
  static const textSecDark = Color(0xB8FFFFFF);
  static const textSecLight = Color(0xFF475569);
  static const textTertDark = Color(0x80FFFFFF);
  static const textTertLight = Color(0xFF64748B);
}

// ── Result union type ──────────────────────────────────────────────────────

enum _ResultKind { movie, tv, person }

class _SearchResults {
  final List<Movie> movies;
  final List<TV> shows;
  final List<Person> people;
  const _SearchResults({
    required this.movies,
    required this.shows,
    required this.people,
  });
  bool get isEmpty => movies.isEmpty && shows.isEmpty && people.isEmpty;
}

// ── Page ───────────────────────────────────────────────────────────────────

class SearchPage extends StatefulWidget {
  final bool includeAdult;
  final String lang;

  const SearchPage({
    super.key,
    required this.includeAdult,
    required this.lang,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const _historyKey = 'caffeine_recent_searches';
  static const _maxHistory = 10;
  // How many results to show per section before "See all"
  static const _sectionPreview = 5;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  String _query = '';
  List<String> _history = [];
  Future<_SearchResults>? _resultsFuture;

  // Track which sections are expanded beyond preview
  final Set<_ResultKind> _expanded = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── History ──────────────────────────────────────────────────────────────

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _history = prefs.getStringList(_historyKey) ?? []);
    }
  }

  Future<void> _saveToHistory(String term) async {
    if (term.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_historyKey) ?? [];
    list.remove(term);
    list.insert(0, term);
    if (list.length > _maxHistory) list.removeLast();
    await prefs.setStringList(_historyKey, list);
    if (mounted) setState(() => _history = list);
  }

  Future<void> _removeHistoryItem(String term) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_historyKey) ?? [];
    list.remove(term);
    await prefs.setStringList(_historyKey, list);
    if (mounted) setState(() => _history = list);
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    if (mounted) setState(() => _history = []);
  }

  // ── Search ────────────────────────────────────────────────────────────────

  void _onTextChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 420), () {
      final term = value.trim();
      if (term == _query) return;
      _runSearch(term);
    });
  }

  void _runSearch(String term) {
    _expanded.clear();
    if (term.isEmpty) {
      setState(() {
        _query = '';
        _resultsFuture = null;
      });
      return;
    }

    AnalyticsService.instance.trackEvent('Search Performed', {'query': term});

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final appDep = Provider.of<AppDependencyProvider>(context, listen: false);
    final proxy = appDep.tmdbProxy;
    final isProxy = settings.enableProxy;

    setState(() {
      _query = term;
      // All three fetches run in parallel via Future.wait
      _resultsFuture = Future.wait([
        fetchMovies(
          Endpoints.movieSearchUrl(term, widget.includeAdult, widget.lang),
          isProxy,
          proxy,
        ).catchError((_) => <Movie>[]),
        fetchTV(
          Endpoints.tvSearchUrl(term, widget.includeAdult, widget.lang),
          isProxy,
          proxy,
        ).catchError((_) => <TV>[]),
        fetchPerson(
          Endpoints.personSearchUrl(term, widget.includeAdult, widget.lang),
          isProxy,
          proxy,
        ).catchError((_) => <Person>[]),
      ]).then((results) => _SearchResults(
            movies: results[0] as List<Movie>,
            shows: results[1] as List<TV>,
            people: results[2] as List<Person>,
          ));
    });
  }

  void _applyHistory(String term) {
    _controller.text = term;
    _controller.selection = TextSelection.collapsed(offset: term.length);
    _runSearch(term);
    _focusNode.unfocus();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _C.bgCanvasDark : _C.bgCanvasLight;
    final elevated = isDark ? _C.bgElevatedDark : _C.bgElevatedLight;
    final border = isDark ? _C.borderDark : _C.borderLight;
    final textPrim = isDark ? _C.textPrimDark : _C.textPrimLight;
    final textSec = isDark ? _C.textSecDark : _C.textSecLight;
    final textTert = isDark ? _C.textTertDark : _C.textTertLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _SearchBar(
              controller: _controller,
              focusNode: _focusNode,
              isDark: isDark,
              elevated: elevated,
              border: border,
              textPrim: textPrim,
              textTert: textTert,
              onChanged: _onTextChanged,
              onSubmitted: (v) {
                final term = v.trim();
                _saveToHistory(term);
                _runSearch(term);
              },
              onClear: () {
                _controller.clear();
                _runSearch('');
              },
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: _query.isEmpty || _resultsFuture == null
                  ? _HistoryView(
                      history: _history,
                      isDark: isDark,
                      elevated: elevated,
                      border: border,
                      textPrim: textPrim,
                      textSec: textSec,
                      textTert: textTert,
                      onTap: _applyHistory,
                      onRemove: _removeHistoryItem,
                      onClear: _clearHistory,
                    )
                  : FutureBuilder<_SearchResults>(
                      future: _resultsFuture,
                      builder: (ctx, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return _UnifiedShimmer(isDark: isDark);
                        }
                        final results = snap.data;
                        if (results == null || results.isEmpty) {
                          return _EmptyResults(
                            isDark: isDark,
                            textTert: textTert,
                          );
                        }
                        return _UnifiedResults(
                          results: results,
                          query: _query,
                          isDark: isDark,
                          elevated: elevated,
                          border: border,
                          textPrim: textPrim,
                          textSec: textSec,
                          textTert: textTert,
                          sectionPreview: _sectionPreview,
                          expanded: _expanded,
                          onToggleExpand: (kind) => setState(
                            () => _expanded.contains(kind)
                                ? _expanded.remove(kind)
                                : _expanded.add(kind),
                          ),
                          onSaveQuery: () => _saveToHistory(_query),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search bar ─────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final Color elevated;
  final Color border;
  final Color textPrim;
  final Color textTert;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onBack;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.elevated,
    required this.border,
    required this.textPrim,
    required this.textTert,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: elevated,
                border: Border.all(color: border, width: 1),
              ),
              child: Icon(Icons.arrow_back_rounded, size: 18, color: textPrim),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: elevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border, width: 1),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(Icons.search_rounded,
                      size: 20,
                      color: isDark ? _C.textTertDark : _C.textTertLight),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                      style: TextStyle(
                        color: textPrim,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: tr('search_text'),
                        hintStyle: TextStyle(
                          color: isDark ? _C.textTertDark : _C.textTertLight,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: controller,
                    builder: (_, __) => controller.text.isEmpty
                        ? const SizedBox(width: 12)
                        : GestureDetector(
                            onTap: onClear,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(Icons.close_rounded,
                                  size: 18,
                                  color: isDark
                                      ? _C.textTertDark
                                      : _C.textTertLight),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── History view ───────────────────────────────────────────────────────────

class _HistoryView extends StatelessWidget {
  final List<String> history;
  final bool isDark;
  final Color elevated;
  final Color border;
  final Color textPrim;
  final Color textSec;
  final Color textTert;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onRemove;
  final VoidCallback onClear;

  const _HistoryView({
    required this.history,
    required this.isDark,
    required this.elevated,
    required this.border,
    required this.textPrim,
    required this.textSec,
    required this.textTert,
    required this.onTap,
    required this.onRemove,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded,
                size: 56,
                color:
                    isDark ? const Color(0x28FFFFFF) : const Color(0x28000000)),
            const SizedBox(height: 14),
            Text(
              tr('enter_word'),
              style: TextStyle(
                  fontSize: 15, color: textTert, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Text(
              'Movies, TV shows, people',
              style: TextStyle(fontSize: 13, color: textTert),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent searches',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textTert,
                  letterSpacing: 0.5),
            ),
            GestureDetector(
              onTap: onClear,
              child: const Text(
                'Clear all',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _C.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...history.map((term) => _HistoryRow(
              term: term,
              isDark: isDark,
              elevated: elevated,
              border: border,
              textPrim: textPrim,
              textTert: textTert,
              onTap: () => onTap(term),
              onRemove: () => onRemove(term),
            )),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final String term;
  final bool isDark;
  final Color elevated;
  final Color border;
  final Color textPrim;
  final Color textTert;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _HistoryRow({
    required this.term,
    required this.isDark,
    required this.elevated,
    required this.border,
    required this.textPrim,
    required this.textTert,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: elevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.history_rounded, size: 17, color: textTert),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(term,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textPrim)),
                ),
                GestureDetector(
                  onTap: onRemove,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Icon(Icons.close_rounded, size: 16, color: textTert),
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

// ── Unified shimmer ────────────────────────────────────────────────────────

class _UnifiedShimmer extends StatelessWidget {
  final bool isDark;
  const _UnifiedShimmer({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final base = isDark ? const Color(0xFF111827) : const Color(0xFFE2E8F0);
    final hi = isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: hi,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _shimSection('Movies', 4, isPortrait: true),
          const SizedBox(height: 24),
          _shimSection('TV Shows', 4, isPortrait: true),
          const SizedBox(height: 24),
          _shimSection('People', 4, isPortrait: false),
        ],
      ),
    );
  }

  Widget _shimSection(String label, int count, {required bool isPortrait}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header placeholder
        Row(
          children: [
            Container(
                width: 4,
                height: 16,
                color: Colors.white,
                margin: const EdgeInsets.only(right: 8)),
            Container(width: 80, height: 14, color: Colors.white),
          ],
        ),
        const SizedBox(height: 14),
        ...List.generate(
            count,
            (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: isPortrait ? 72 : 52,
                        height: isPortrait ? 108 : 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(isPortrait ? 12 : 999),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                height: 14,
                                width: 160,
                                color: Colors.white,
                                margin: const EdgeInsets.only(bottom: 8)),
                            Container(
                                height: 11,
                                width: 90,
                                color: Colors.white,
                                margin: const EdgeInsets.only(bottom: 10)),
                            Container(
                                height: 22,
                                width: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
      ],
    );
  }
}

// ── Empty results ──────────────────────────────────────────────────────────

class _EmptyResults extends StatelessWidget {
  final bool isDark;
  final Color textTert;
  const _EmptyResults({required this.isDark, required this.textTert});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 60,
              color:
                  isDark ? const Color(0x28FFFFFF) : const Color(0x28000000)),
          const SizedBox(height: 14),
          Text(tr('no_result'),
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w500, color: textTert)),
        ],
      ),
    );
  }
}

// ── Unified results list ───────────────────────────────────────────────────

class _UnifiedResults extends StatelessWidget {
  final _SearchResults results;
  final String query;
  final bool isDark;
  final Color elevated;
  final Color border;
  final Color textPrim;
  final Color textSec;
  final Color textTert;
  final int sectionPreview;
  final Set<_ResultKind> expanded;
  final ValueChanged<_ResultKind> onToggleExpand;
  final VoidCallback onSaveQuery;

  const _UnifiedResults({
    required this.results,
    required this.query,
    required this.isDark,
    required this.elevated,
    required this.border,
    required this.textPrim,
    required this.textSec,
    required this.textTert,
    required this.sectionPreview,
    required this.expanded,
    required this.onToggleExpand,
    required this.onSaveQuery,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final appDep = Provider.of<AppDependencyProvider>(context, listen: false);
    final imageQuality = settings.imageQuality;
    final proxy = appDep.tmdbProxy;
    final isProxy = settings.enableProxy;

    final divider = Divider(
      height: 1,
      thickness: 1,
      indent: 86,
      endIndent: 0,
      color: isDark ? _C.borderDark : _C.borderLight,
    );

    // Build the flat list of slivers
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 8)),

        // ── Movies ──────────────────────────────────────────────────────
        if (results.movies.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.movie_filter_rounded,
            label: tr('movies'),
            count: results.movies.length,
            accentColor: _C.primary,
            isDark: isDark,
            textPrim: textPrim,
            textTert: textTert,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final isExp = expanded.contains(_ResultKind.movie);
                final visible = isExp
                    ? results.movies
                    : results.movies.take(sectionPreview).toList();
                if (i >= visible.length) return null;
                final m = visible[i];
                final year = m.releaseDate?.isNotEmpty == true
                    ? DateTime.tryParse(m.releaseDate!)?.year.toString()
                    : null;
                return Column(
                  children: [
                    _MediaRow(
                      heroTag: 'movie_${m.id}',
                      posterPath: m.posterPath,
                      title: m.title ?? '—',
                      subtitle: year,
                      rating: m.voteAverage,
                      typeBadge: null,
                      isDark: isDark,
                      elevated: elevated,
                      textPrim: textPrim,
                      textSec: textSec,
                      imageQuality: imageQuality,
                      proxyUrl: proxy,
                      isProxy: isProxy,
                      onTap: () {
                        onSaveQuery();
                        Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) => MovieDetailPage(
                                  movie: m, heroId: 'movie_${m.id}'),
                            ));
                      },
                    ),
                    if (i < visible.length - 1) divider,
                  ],
                );
              },
              childCount: expanded.contains(_ResultKind.movie)
                  ? results.movies.length
                  : results.movies.length.clamp(0, sectionPreview),
            ),
          ),
          if (results.movies.length > sectionPreview)
            _ShowMoreRow(
              isExpanded: expanded.contains(_ResultKind.movie),
              total: results.movies.length,
              isDark: isDark,
              textTert: textTert,
              onTap: () => onToggleExpand(_ResultKind.movie),
            ),
        ],

        // ── TV Shows ────────────────────────────────────────────────────
        if (results.shows.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: SizedBox(
              height: results.movies.isNotEmpty ? 28 : 0,
            ),
          ),
          _SectionHeader(
            icon: Icons.live_tv_rounded,
            label: tr('tv_shows'),
            count: results.shows.length,
            accentColor: const Color(0xFF7C3AED),
            isDark: isDark,
            textPrim: textPrim,
            textTert: textTert,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final isExp = expanded.contains(_ResultKind.tv);
                final visible = isExp
                    ? results.shows
                    : results.shows.take(sectionPreview).toList();
                if (i >= visible.length) return null;
                final tv = visible[i];
                final year = tv.firstAirDate?.isNotEmpty == true
                    ? DateTime.tryParse(tv.firstAirDate!)?.year.toString()
                    : null;
                return Column(
                  children: [
                    _MediaRow(
                      heroTag: 'tv_${tv.id}',
                      posterPath: tv.posterPath,
                      title: tv.name ?? '—',
                      subtitle: year,
                      rating: tv.voteAverage,
                      typeBadge: null,
                      isDark: isDark,
                      elevated: elevated,
                      textPrim: textPrim,
                      textSec: textSec,
                      imageQuality: imageQuality,
                      proxyUrl: proxy,
                      isProxy: isProxy,
                      onTap: () {
                        onSaveQuery();
                        Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) => TVDetailPage(
                                  tvSeries: tv, heroId: 'tv_${tv.id}'),
                            ));
                      },
                    ),
                    if (i < visible.length - 1) divider,
                  ],
                );
              },
              childCount: expanded.contains(_ResultKind.tv)
                  ? results.shows.length
                  : results.shows.length.clamp(0, sectionPreview),
            ),
          ),
          if (results.shows.length > sectionPreview)
            _ShowMoreRow(
              isExpanded: expanded.contains(_ResultKind.tv),
              total: results.shows.length,
              isDark: isDark,
              textTert: textTert,
              onTap: () => onToggleExpand(_ResultKind.tv),
            ),
        ],

        // ── People ──────────────────────────────────────────────────────
        if (results.people.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: SizedBox(
              height: (results.movies.isNotEmpty || results.shows.isNotEmpty)
                  ? 28
                  : 0,
            ),
          ),
          _SectionHeader(
            icon: Icons.people_rounded,
            label: tr('celebrities'),
            count: results.people.length,
            accentColor: const Color(0xFF0EA5E9),
            isDark: isDark,
            textPrim: textPrim,
            textTert: textTert,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final isExp = expanded.contains(_ResultKind.person);
                final visible = isExp
                    ? results.people
                    : results.people.take(sectionPreview).toList();
                if (i >= visible.length) return null;
                final p = visible[i];
                return Column(
                  children: [
                    _PersonRow(
                      heroTag: 'person_${p.id}',
                      profilePath: p.profilePath,
                      name: p.name ?? '—',
                      department: p.department,
                      isDark: isDark,
                      elevated: elevated,
                      textPrim: textPrim,
                      textSec: textSec,
                      imageQuality: imageQuality,
                      proxyUrl: proxy,
                      isProxy: isProxy,
                      onTap: () {
                        onSaveQuery();
                        Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) => SearchedPersonDetailPage(
                                  person: p, heroId: 'person_${p.id}'),
                            ));
                      },
                    ),
                    if (i < visible.length - 1)
                      Divider(
                        height: 1,
                        thickness: 1,
                        indent: 86,
                        color: isDark ? _C.borderDark : _C.borderLight,
                      ),
                  ],
                );
              },
              childCount: expanded.contains(_ResultKind.person)
                  ? results.people.length
                  : results.people.length.clamp(0, sectionPreview),
            ),
          ),
          if (results.people.length > sectionPreview)
            _ShowMoreRow(
              isExpanded: expanded.contains(_ResultKind.person),
              total: results.people.length,
              isDark: isDark,
              textTert: textTert,
              onTap: () => onToggleExpand(_ResultKind.person),
            ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

// ── Section header sliver ──────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color accentColor;
  final bool isDark;
  final Color textPrim;
  final Color textTert;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.count,
    required this.accentColor,
    required this.isDark,
    required this.textPrim,
    required this.textTert,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, size: 16, color: accentColor),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textPrim,
                letterSpacing: 0.3,
                fontFamily: 'PoppinsSB',
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Show more / collapse row ───────────────────────────────────────────────

class _ShowMoreRow extends StatelessWidget {
  final bool isExpanded;
  final int total;
  final bool isDark;
  final Color textTert;
  final VoidCallback onTap;

  const _ShowMoreRow({
    required this.isExpanded,
    required this.total,
    required this.isDark,
    required this.textTert,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Text(
                isExpanded ? 'Show less' : 'See all $total results',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _C.primary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: _C.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Media result row (movies + TV) ─────────────────────────────────────────

class _MediaRow extends StatelessWidget {
  final String heroTag;
  final String? posterPath;
  final String title;
  final String? subtitle;
  final num? rating;
  final String? typeBadge;
  final bool isDark;
  final Color elevated;
  final Color textPrim;
  final Color textSec;
  final String imageQuality;
  final String proxyUrl;
  final bool isProxy;
  final VoidCallback onTap;

  const _MediaRow({
    required this.heroTag,
    required this.posterPath,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.typeBadge,
    required this.isDark,
    required this.elevated,
    required this.textPrim,
    required this.textSec,
    required this.imageQuality,
    required this.proxyUrl,
    required this.isProxy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ratingStr = rating != null && rating! > 0
        ? rating!.toDouble().toStringAsFixed(1)
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: _C.primary.withValues(alpha: 0.06),
        highlightColor: _C.primary.withValues(alpha: 0.03),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 70,
                    height: 105,
                    child: posterPath == null
                        ? Container(
                            color: elevated,
                            child: Icon(Icons.image_not_supported_outlined,
                                color: isDark
                                    ? const Color(0x40FFFFFF)
                                    : const Color(0x40000000)),
                          )
                        : CachedNetworkImage(
                            cacheManager: cacheProp(),
                            imageUrl: buildImageUrl(TMDB_BASE_IMAGE_URL,
                                    proxyUrl, isProxy, context) +
                                imageQuality +
                                posterPath!,
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 280),
                            placeholder: (_, __) => Container(color: elevated),
                            errorWidget: (_, __, ___) => Container(
                              color: elevated,
                              child: Icon(Icons.image_not_supported_outlined,
                                  color: isDark
                                      ? const Color(0x40FFFFFF)
                                      : const Color(0x40000000)),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textPrim,
                          height: 1.3,
                          fontFamily: 'PoppinsSB',
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(subtitle!,
                            style: TextStyle(fontSize: 12, color: textSec)),
                      ],
                      if (ratingStr != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _C.ratingGold.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: _C.ratingGold.withValues(alpha: 0.26),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 12, color: _C.ratingGold),
                              const SizedBox(width: 3),
                              Text(ratingStr,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _C.ratingGold,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Person result row ──────────────────────────────────────────────────────

class _PersonRow extends StatelessWidget {
  final String heroTag;
  final String? profilePath;
  final String name;
  final String? department;
  final bool isDark;
  final Color elevated;
  final Color textPrim;
  final Color textSec;
  final String imageQuality;
  final String proxyUrl;
  final bool isProxy;
  final VoidCallback onTap;

  const _PersonRow({
    required this.heroTag,
    required this.profilePath,
    required this.name,
    required this.department,
    required this.isDark,
    required this.elevated,
    required this.textPrim,
    required this.textSec,
    required this.imageQuality,
    required this.proxyUrl,
    required this.isProxy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: _C.primary.withValues(alpha: 0.06),
        highlightColor: _C.primary.withValues(alpha: 0.03),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Hero(
                tag: heroTag,
                child: ClipOval(
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: profilePath == null
                        ? Container(
                            color: elevated,
                            child: Icon(Icons.person_outline_rounded,
                                color: isDark
                                    ? const Color(0x40FFFFFF)
                                    : const Color(0x40000000)))
                        : CachedNetworkImage(
                            cacheManager: cacheProp(),
                            imageUrl: buildImageUrl(TMDB_BASE_IMAGE_URL,
                                    proxyUrl, isProxy, context) +
                                imageQuality +
                                profilePath!,
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 280),
                            placeholder: (_, __) => Container(color: elevated),
                            errorWidget: (_, __, ___) => Container(
                              color: elevated,
                              child: Icon(Icons.person_outline_rounded,
                                  color: isDark
                                      ? const Color(0x40FFFFFF)
                                      : const Color(0x40000000)),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textPrim,
                        fontFamily: 'PoppinsSB',
                      ),
                    ),
                    if (department != null) ...[
                      const SizedBox(height: 3),
                      Text(department!,
                          style: TextStyle(fontSize: 12, color: textSec)),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 18,
                  color: isDark
                      ? const Color(0x50FFFFFF)
                      : const Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}
