import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:reelriot/api/endpoints.dart';
import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/functions/network.dart';
import 'package:reelriot/models/genre_movies.dart';
import 'package:reelriot/models/genres.dart';
import 'package:reelriot/models/movie_models.dart';
import 'package:reelriot/models/person.dart';
import 'package:reelriot/models/tv.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/movie_screens/movie_details.dart';
import 'package:reelriot/screens/search/searched_person.dart';
import 'package:reelriot/screens/tv_screens/tv_detail_page.dart';
import 'package:reelriot/services/analytics_service.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/utils/constant.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
class _C {
  static const primary = Color(0xFFDC2626);
  static const primaryGlow = Color(0x33DC2626);
  static const ratingGold = Color(0xFFEAB308);

  static const bgCanvasDark = Color(0xFF030712);
  static const bgElevatedDark = Color(0xFF111827);
  static const bgCardDark = Color(0xFF1F2937);
  static const bgCanvasLight = Color(0xFFF8FAFC);
  static const bgElevatedLight = Color(0xFFF1F5F9);
  static const bgCardLight = Color(0xFFE2E8F0);

  static const borderDark = Color(0x14FFFFFF);
  static const borderLight = Color(0x140F172A);

  static const textPrimDark = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
  static const textSecDark = Color(0xB8FFFFFF);
  static const textSecLight = Color(0xFF475569);
  static const textTertDark = Color(0x80FFFFFF);
  static const textTertLight = Color(0xFF64748B);
}

// ── Result union type & filter categories ─────────────────────────────────

enum _SearchCategory { all, movies, tv, people }

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
  int get totalCount => movies.length + shows.length + people.length;
}

// ── Popular explore genres ────────────────────────────────────────────────
class _GenreItem {
  final int id;
  final String name;
  final String icon;
  final List<Color> gradient;
  const _GenreItem(this.id, this.name, this.icon, this.gradient);
}

const _popularGenres = [
  _GenreItem(28, 'Action', '💥', [Color(0xFFE11D48), Color(0xFF9F1239)]),
  _GenreItem(878, 'Sci-Fi', '🛸', [Color(0xFF0284C7), Color(0xFF0369A1)]),
  _GenreItem(35, 'Comedy', '😂', [Color(0xFFD97706), Color(0xFFB45309)]),
  _GenreItem(16, 'Animation', '🎨', [Color(0xFF7C3AED), Color(0xFF5B21B6)]),
  _GenreItem(27, 'Horror', '👻', [Color(0xFF475569), Color(0xFF1E293B)]),
  _GenreItem(18, 'Drama', '🎭', [Color(0xFF0D9488), Color(0xFF0F766E)]),
  _GenreItem(53, 'Thriller', '⚡', [Color(0xFFBE123C), Color(0xFF881337)]),
  _GenreItem(12, 'Adventure', '🗺️', [Color(0xFF059669), Color(0xFF047857)]),
  _GenreItem(14, 'Fantasy', '🔮', [Color(0xFF9333EA), Color(0xFF6B21A8)]),
  _GenreItem(10749, 'Romance', '❤️', [Color(0xFFDB2777), Color(0xFF9D174D)]),
  _GenreItem(99, 'Documentary', '🎥', [Color(0xFF4F46E5), Color(0xFF3730A3)]),
  _GenreItem(80, 'Crime', '🕵️', [Color(0xFF334155), Color(0xFF0F172A)]),
];

const _trendingTags = [
  'Trending Movies',
  'Top Series',
  'Anime',
  'Marvel',
  'Star Wars',
  'Cyberpunk',
  'True Crime',
  'Sitcoms',
];

// ── Search Page ───────────────────────────────────────────────────────────

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
  static const _sectionPreview = 6;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  String _query = '';
  List<String> _history = [];
  Future<_SearchResults>? _resultsFuture;
  _SearchCategory _selectedCategory = _SearchCategory.all;

  // Track which sections are expanded beyond preview in "All" view
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
    _debounce = Timer(const Duration(milliseconds: 380), () {
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
        _selectedCategory = _SearchCategory.all;
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

  void _applySearch(String term) {
    _controller.text = term;
    _controller.selection = TextSelection.collapsed(offset: term.length);
    _saveToHistory(term);
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
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
                      ? _InitialExploreView(
                          history: _history,
                          isDark: isDark,
                          elevated: elevated,
                          border: border,
                          textPrim: textPrim,
                          textSec: textSec,
                          textTert: textTert,
                          onApplyTag: _applySearch,
                          onRemoveHistory: _removeHistoryItem,
                          onClearHistory: _clearHistory,
                        )
                      : FutureBuilder<_SearchResults>(
                          future: _resultsFuture,
                          builder: (ctx, snap) {
                            if (snap.connectionState == ConnectionState.waiting) {
                              return _ResponsiveSearchShimmer(isDark: isDark);
                            }
                            final results = snap.data;
                            if (results == null || results.isEmpty) {
                              return _EmptyResults(
                                isDark: isDark,
                                textTert: textTert,
                                textPrim: textPrim,
                                query: _query,
                                onClear: () {
                                  _controller.clear();
                                  _runSearch('');
                                },
                              );
                            }
                            return Column(
                              children: [
                                _CategoryFilterBar(
                                  selected: _selectedCategory,
                                  results: results,
                                  isDark: isDark,
                                  elevated: elevated,
                                  border: border,
                                  textPrim: textPrim,
                                  textTert: textTert,
                                  onSelect: (cat) => setState(() => _selectedCategory = cat),
                                ),
                                Expanded(
                                  child: _ResponsiveSearchResultsView(
                                    results: results,
                                    category: _selectedCategory,
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
                                    onSwitchCategory: (cat) => setState(() => _selectedCategory = cat),
                                  ),
                                ),
                              ],
                            );
                          },
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: elevated,
                  border: Border.all(color: border, width: 1),
                ),
                child: Icon(Icons.arrow_back_rounded, size: 20, color: textPrim),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: elevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border, width: 1),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: _C.primary,
                  ),
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
                          color: textTert,
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
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: textTert.withValues(alpha: 0.2),
                                ),
                                child: Icon(Icons.close_rounded, size: 14, color: textPrim),
                              ),
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

// ── Category Filter Bar ────────────────────────────────────────────────────

class _CategoryFilterBar extends StatelessWidget {
  final _SearchCategory selected;
  final _SearchResults results;
  final bool isDark;
  final Color elevated;
  final Color border;
  final Color textPrim;
  final Color textTert;
  final ValueChanged<_SearchCategory> onSelect;

  const _CategoryFilterBar({
    required this.selected,
    required this.results,
    required this.isDark,
    required this.elevated,
    required this.border,
    required this.textPrim,
    required this.textTert,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Row(
        children: [
          _buildChip(_SearchCategory.all, 'All', results.totalCount),
          const SizedBox(width: 8),
          _buildChip(_SearchCategory.movies, tr('movies'), results.movies.length),
          const SizedBox(width: 8),
          _buildChip(_SearchCategory.tv, tr('tv_shows'), results.shows.length),
          const SizedBox(width: 8),
          _buildChip(_SearchCategory.people, tr('celebrities'), results.people.length),
        ],
      ),
    );
  }

  Widget _buildChip(_SearchCategory cat, String label, int count) {
    final isSel = selected == cat;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelect(cat),
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? _C.primary : elevated,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSel ? _C.primary : border,
              width: 1,
            ),
            boxShadow: isSel
                ? [
                    BoxShadow(
                      color: _C.primary.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  color: isSel ? Colors.white : textPrim,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSel
                        ? Colors.white.withValues(alpha: 0.25)
                        : textTert.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSel ? Colors.white : textTert,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Initial explore / history view ─────────────────────────────────────────

class _InitialExploreView extends StatelessWidget {
  final List<String> history;
  final bool isDark;
  final Color elevated;
  final Color border;
  final Color textPrim;
  final Color textSec;
  final Color textTert;
  final ValueChanged<String> onApplyTag;
  final ValueChanged<String> onRemoveHistory;
  final VoidCallback onClearHistory;

  const _InitialExploreView({
    required this.history,
    required this.isDark,
    required this.elevated,
    required this.border,
    required this.textPrim,
    required this.textSec,
    required this.textTert,
    required this.onApplyTag,
    required this.onRemoveHistory,
    required this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final screenW = constraints.maxWidth;
        // Responsive columns for genres: 2 columns on phone, 3 on small tablet, 4 on large tablet
        final genreCols = screenW > 900 ? 4 : (screenW > 600 ? 3 : 2);

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
          children: [
            // ── Recent searches ──────────────────────────────────────────
            if (history.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history_rounded, size: 16, color: _C.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Recent Searches',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrim,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: onClearHistory,
                    behavior: HitTestBehavior.opaque,
                    child: const Text(
                      'Clear all',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _C.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: history.map((term) {
                  return Container(
                    decoration: BoxDecoration(
                      color: elevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border, width: 1),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onApplyTag(term),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                term,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: textPrim,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => onRemoveHistory(term),
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Icon(Icons.close_rounded, size: 14, color: textTert),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // ── Trending tags ────────────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.local_fire_department_rounded, size: 17, color: Color(0xFFF97316)),
                const SizedBox(width: 8),
                Text(
                  'Trending Searches',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrim,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _trendingTags.map((tag) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onApplyTag(tag),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: elevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.trending_up_rounded, size: 14, color: textTert),
                          const SizedBox(width: 6),
                          Text(
                            tag,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: textPrim,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // ── Explore by genre ─────────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.explore_rounded, size: 16, color: Color(0xFF0EA5E9)),
                const SizedBox(width: 8),
                Text(
                  'Explore by Genre',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrim,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: genreCols,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: screenW > 600 ? 2.4 : 2.0,
              ),
              itemCount: _popularGenres.length,
              itemBuilder: (ctx, idx) {
                final g = _popularGenres[idx];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) => GenreMovies(
                            genres: Genres(genreID: g.id, genreName: g.name),
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: g.gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: g.gradient.first.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Text(
                            g.icon,
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              g.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// ── Search results view (responsive grid & sections) ───────────────────────

class _ResponsiveSearchResultsView extends StatelessWidget {
  final _SearchResults results;
  final _SearchCategory category;
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
  final ValueChanged<_SearchCategory> onSwitchCategory;

  const _ResponsiveSearchResultsView({
    required this.results,
    required this.category,
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
    required this.onSwitchCategory,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final appDep = Provider.of<AppDependencyProvider>(context, listen: false);
    final imageQuality = settings.imageQuality;
    final proxy = appDep.tmdbProxy;
    final isProxy = settings.enableProxy;

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final screenW = constraints.maxWidth;
        // Responsive poster grid column count:
        // Phone (< 500): 3 cols
        // Phablet (500-700): 3-4 cols
        // Tablet (700-1000): 4-5 cols
        // Large Tablet / Desktop (> 1000): 6 cols
        final int posterCols = screenW > 1050
            ? 6
            : (screenW > 800
                ? 5
                : (screenW > 560
                    ? 4
                    : 3));

        final int personCols = screenW > 1050
            ? 6
            : (screenW > 800
                ? 5
                : (screenW > 560
                    ? 4
                    : 3));

        // Poster aspect ratio ~ 0.60 (poster + text below)
        final double posterAspectRatio = screenW > 600 ? 0.58 : 0.55;
        final double personAspectRatio = screenW > 600 ? 0.78 : 0.74;

        if (category == _SearchCategory.movies) {
          return _buildDedicatedGrid(
            items: results.movies,
            posterCols: posterCols,
            aspectRatio: posterAspectRatio,
            imageQuality: imageQuality,
            proxy: proxy,
            isProxy: isProxy,
            isMovie: true,
          );
        }

        if (category == _SearchCategory.tv) {
          return _buildDedicatedGrid(
            items: results.shows,
            posterCols: posterCols,
            aspectRatio: posterAspectRatio,
            imageQuality: imageQuality,
            proxy: proxy,
            isProxy: isProxy,
            isMovie: false,
          );
        }

        if (category == _SearchCategory.people) {
          return _buildDedicatedPeopleGrid(
            people: results.people,
            personCols: personCols,
            aspectRatio: personAspectRatio,
            imageQuality: imageQuality,
            proxy: proxy,
            isProxy: isProxy,
          );
        }

        // ── "All" Mode: Sectioned with responsive grids ──────────────────
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // ── Movies Section ───────────────────────────────────────────
            if (results.movies.isNotEmpty) ...[
              _SectionHeaderSliver(
                icon: Icons.movie_filter_rounded,
                label: tr('movies'),
                count: results.movies.length,
                accentColor: _C.primary,
                isDark: isDark,
                textPrim: textPrim,
                textTert: textTert,
                onSeeAll: () => onSwitchCategory(_SearchCategory.movies),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: posterCols,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                    childAspectRatio: posterAspectRatio,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (c, i) {
                      final isExp = expanded.contains(_ResultKind.movie);
                      final visible = isExp
                          ? results.movies
                          : results.movies.take(posterCols * 2).toList();
                      if (i >= visible.length) return null;
                      final m = visible[i];
                      return _ResponsiveMovieCard(
                        movie: m,
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
                            c,
                            MaterialPageRoute(
                              builder: (_) => MovieDetailPage(
                                movie: m,
                                heroId: 'movie_search_${m.id}',
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: expanded.contains(_ResultKind.movie)
                        ? results.movies.length
                        : results.movies.length.clamp(0, posterCols * 2),
                  ),
                ),
              ),
              if (results.movies.length > posterCols * 2)
                _ShowMoreSliver(
                  isExpanded: expanded.contains(_ResultKind.movie),
                  total: results.movies.length,
                  onTap: () => onToggleExpand(_ResultKind.movie),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],

            // ── TV Shows Section ─────────────────────────────────────────
            if (results.shows.isNotEmpty) ...[
              _SectionHeaderSliver(
                icon: Icons.live_tv_rounded,
                label: tr('tv_shows'),
                count: results.shows.length,
                accentColor: const Color(0xFF8B5CF6),
                isDark: isDark,
                textPrim: textPrim,
                textTert: textTert,
                onSeeAll: () => onSwitchCategory(_SearchCategory.tv),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: posterCols,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                    childAspectRatio: posterAspectRatio,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (c, i) {
                      final isExp = expanded.contains(_ResultKind.tv);
                      final visible = isExp
                          ? results.shows
                          : results.shows.take(posterCols * 2).toList();
                      if (i >= visible.length) return null;
                      final tv = visible[i];
                      return _ResponsiveTVCard(
                        tv: tv,
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
                            c,
                            MaterialPageRoute(
                              builder: (_) => TVDetailPage(
                                tvSeries: tv,
                                heroId: 'tv_search_${tv.id}',
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: expanded.contains(_ResultKind.tv)
                        ? results.shows.length
                        : results.shows.length.clamp(0, posterCols * 2),
                  ),
                ),
              ),
              if (results.shows.length > posterCols * 2)
                _ShowMoreSliver(
                  isExpanded: expanded.contains(_ResultKind.tv),
                  total: results.shows.length,
                  onTap: () => onToggleExpand(_ResultKind.tv),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],

            // ── People Section ───────────────────────────────────────────
            if (results.people.isNotEmpty) ...[
              _SectionHeaderSliver(
                icon: Icons.people_alt_rounded,
                label: tr('celebrities'),
                count: results.people.length,
                accentColor: const Color(0xFF0EA5E9),
                isDark: isDark,
                textPrim: textPrim,
                textTert: textTert,
                onSeeAll: () => onSwitchCategory(_SearchCategory.people),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: personCols,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                    childAspectRatio: personAspectRatio,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (c, i) {
                      final isExp = expanded.contains(_ResultKind.person);
                      final visible = isExp
                          ? results.people
                          : results.people.take(personCols * 2).toList();
                      if (i >= visible.length) return null;
                      final p = visible[i];
                      return _ResponsivePersonCard(
                        person: p,
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
                            c,
                            MaterialPageRoute(
                              builder: (_) => SearchedPersonDetailPage(
                                person: p,
                                heroId: 'person_search_${p.id}',
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: expanded.contains(_ResultKind.person)
                        ? results.people.length
                        : results.people.length.clamp(0, personCols * 2),
                  ),
                ),
              ),
              if (results.people.length > personCols * 2)
                _ShowMoreSliver(
                  isExpanded: expanded.contains(_ResultKind.person),
                  total: results.people.length,
                  onTap: () => onToggleExpand(_ResultKind.person),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDedicatedGrid({
    required List<dynamic> items,
    required int posterCols,
    required double aspectRatio,
    required String imageQuality,
    required String proxy,
    required bool isProxy,
    required bool isMovie,
  }) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: posterCols,
        crossAxisSpacing: 10,
        mainAxisSpacing: 14,
        childAspectRatio: aspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        if (isMovie) {
          final m = items[i] as Movie;
          return _ResponsiveMovieCard(
            movie: m,
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
                    movie: m,
                    heroId: 'movie_search_grid_${m.id}',
                  ),
                ),
              );
            },
          );
        } else {
          final tv = items[i] as TV;
          return _ResponsiveTVCard(
            tv: tv,
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
                    tvSeries: tv,
                    heroId: 'tv_search_grid_${tv.id}',
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildDedicatedPeopleGrid({
    required List<Person> people,
    required int personCols,
    required double aspectRatio,
    required String imageQuality,
    required String proxy,
    required bool isProxy,
  }) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: personCols,
        crossAxisSpacing: 10,
        mainAxisSpacing: 14,
        childAspectRatio: aspectRatio,
      ),
      itemCount: people.length,
      itemBuilder: (ctx, i) {
        final p = people[i];
        return _ResponsivePersonCard(
          person: p,
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
                  person: p,
                  heroId: 'person_search_grid_${p.id}',
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Section Header Sliver ──────────────────────────────────────────────────

class _SectionHeaderSliver extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color accentColor;
  final bool isDark;
  final Color textPrim;
  final Color textTert;
  final VoidCallback onSeeAll;

  const _SectionHeaderSliver({
    required this.icon,
    required this.label,
    required this.count,
    required this.accentColor,
    required this.isDark,
    required this.textPrim,
    required this.textTert,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            Container(
              width: 3.5,
              height: 18,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 16, color: accentColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textPrim,
                letterSpacing: 0.2,
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
            const Spacer(),
            GestureDetector(
              onTap: onSeeAll,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_forward_ios_rounded, size: 10, color: accentColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Show More Sliver ───────────────────────────────────────────────────────

class _ShowMoreSliver extends StatelessWidget {
  final bool isExpanded;
  final int total;
  final VoidCallback onTap;

  const _ShowMoreSliver({
    required this.isExpanded,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Center(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isExpanded ? 'Show less' : 'Expand ($total results)',
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
        ),
      ),
    );
  }
}

// ── Responsive Movie Card ──────────────────────────────────────────────────

class _ResponsiveMovieCard extends StatelessWidget {
  final Movie movie;
  final bool isDark;
  final Color elevated;
  final Color textPrim;
  final Color textSec;
  final String imageQuality;
  final String proxyUrl;
  final bool isProxy;
  final VoidCallback onTap;

  const _ResponsiveMovieCard({
    required this.movie,
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
    final year = movie.releaseDate?.isNotEmpty == true
        ? DateTime.tryParse(movie.releaseDate!)?.year.toString()
        : null;
    final rating = movie.voteAverage != null && movie.voteAverage! > 0
        ? movie.voteAverage!.toDouble().toStringAsFixed(1)
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: elevated,
                      child: movie.posterPath == null
                          ? Center(
                              child: Icon(
                                Icons.movie_outlined,
                                color: isDark ? Colors.white24 : Colors.black26,
                                size: 28,
                              ),
                            )
                          : CachedNetworkImage(
                              cacheManager: cacheProp(),
                              imageUrl: buildImageUrl(tmdbBaseImageUrl, proxyUrl, isProxy, context) +
                                  imageQuality +
                                  movie.posterPath!,
                              fit: BoxFit.cover,
                              fadeInDuration: const Duration(milliseconds: 240),
                              placeholder: (_, __) => Container(color: elevated),
                              errorWidget: (_, __, ___) => Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: isDark ? Colors.white24 : Colors.black26,
                                  size: 28,
                                ),
                              ),
                            ),
                    ),
                  ),
                  if (rating != null)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _C.ratingGold.withValues(alpha: 0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 11, color: _C.ratingGold),
                            const SizedBox(width: 2),
                            Text(
                              rating,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _C.ratingGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              movie.title ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textPrim,
              ),
            ),
            if (year != null)
              Text(
                year,
                style: TextStyle(
                  fontSize: 11,
                  color: textSec,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Responsive TV Card ─────────────────────────────────────────────────────

class _ResponsiveTVCard extends StatelessWidget {
  final TV tv;
  final bool isDark;
  final Color elevated;
  final Color textPrim;
  final Color textSec;
  final String imageQuality;
  final String proxyUrl;
  final bool isProxy;
  final VoidCallback onTap;

  const _ResponsiveTVCard({
    required this.tv,
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
    final year = tv.firstAirDate?.isNotEmpty == true
        ? DateTime.tryParse(tv.firstAirDate!)?.year.toString()
        : null;
    final rating = tv.voteAverage != null && tv.voteAverage! > 0
        ? tv.voteAverage!.toDouble().toStringAsFixed(1)
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: elevated,
                      child: tv.posterPath == null
                          ? Center(
                              child: Icon(
                                Icons.tv_rounded,
                                color: isDark ? Colors.white24 : Colors.black26,
                                size: 28,
                              ),
                            )
                          : CachedNetworkImage(
                              cacheManager: cacheProp(),
                              imageUrl: buildImageUrl(tmdbBaseImageUrl, proxyUrl, isProxy, context) +
                                  imageQuality +
                                  tv.posterPath!,
                              fit: BoxFit.cover,
                              fadeInDuration: const Duration(milliseconds: 240),
                              placeholder: (_, __) => Container(color: elevated),
                              errorWidget: (_, __, ___) => Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: isDark ? Colors.white24 : Colors.black26,
                                  size: 28,
                                ),
                              ),
                            ),
                    ),
                  ),
                  if (rating != null)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _C.ratingGold.withValues(alpha: 0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 11, color: _C.ratingGold),
                            const SizedBox(width: 2),
                            Text(
                              rating,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _C.ratingGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              tv.name ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textPrim,
              ),
            ),
            if (year != null)
              Text(
                year,
                style: TextStyle(
                  fontSize: 11,
                  color: textSec,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Responsive Person Card ─────────────────────────────────────────────────

class _ResponsivePersonCard extends StatelessWidget {
  final Person person;
  final bool isDark;
  final Color elevated;
  final Color textPrim;
  final Color textSec;
  final String imageQuality;
  final String proxyUrl;
  final bool isProxy;
  final VoidCallback onTap;

  const _ResponsivePersonCard({
    required this.person,
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
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: elevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? _C.borderDark : _C.borderLight,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipOval(
                      child: Container(
                        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
                        child: person.profilePath == null
                            ? Icon(
                                Icons.person_rounded,
                                size: 36,
                                color: isDark ? Colors.white24 : Colors.black26,
                              )
                            : CachedNetworkImage(
                                cacheManager: cacheProp(),
                                imageUrl: buildImageUrl(tmdbBaseImageUrl, proxyUrl, isProxy, context) +
                                    imageQuality +
                                    person.profilePath!,
                                fit: BoxFit.cover,
                                fadeInDuration: const Duration(milliseconds: 240),
                                placeholder: (_, __) => Container(
                                  color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
                                ),
                                errorWidget: (_, __, ___) => Icon(
                                  Icons.person_rounded,
                                  size: 36,
                                  color: isDark ? Colors.white24 : Colors.black26,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                person.name ?? '—',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textPrim,
                ),
              ),
              if (person.department != null)
                Text(
                  person.department!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: textSec,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Responsive search shimmer loader ───────────────────────────────────────

class _ResponsiveSearchShimmer extends StatelessWidget {
  final bool isDark;
  const _ResponsiveSearchShimmer({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final base = isDark ? const Color(0xFF111827) : const Color(0xFFE2E8F0);
    final hi = isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9);

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final screenW = constraints.maxWidth;
        final int cols = screenW > 1050
            ? 6
            : (screenW > 800
                ? 5
                : (screenW > 560
                    ? 4
                    : 3));

        return Shimmer.fromColors(
          baseColor: base,
          highlightColor: hi,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 10,
                mainAxisSpacing: 14,
                childAspectRatio: 0.58,
              ),
              itemCount: cols * 3,
              itemBuilder: (_, __) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 10,
                    width: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Empty results ──────────────────────────────────────────────────────────

class _EmptyResults extends StatelessWidget {
  final bool isDark;
  final Color textTert;
  final Color textPrim;
  final String query;
  final VoidCallback onClear;

  const _EmptyResults({
    required this.isDark,
    required this.textTert,
    required this.textPrim,
    required this.query,
    required this.onClear,
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
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0x18FFFFFF) : const Color(0x0A000000),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 36,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tr('no_result'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textPrim,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No results found for "$query". Check for spelling or try searching for another title.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: textTert,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onClear,
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Clear search', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
