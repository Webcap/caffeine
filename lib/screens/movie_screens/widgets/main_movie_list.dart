import 'package:caffiene/functions/network.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/models/movie_models.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/movie_screens/widgets/movie_grid_view.dart';
import 'package:caffiene/screens/movie_screens/widgets/movie_list_view.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';

// ── Design tokens (design.json) ─────────────────────────────────────────────
class _ViewAllDesign {
  static const primary = Color(0xFFDC2626);
  static const bgCanvasDark = Color(0xFF030712);
  static const bgSurfaceDark = Color(0xFF0B0F14);
  static const bgCanvasLight = Color(0xFFF8FAFC);
  static const bgSurfaceLight = Color(0xFFFFFFFF);
  static const textPrimDark = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
  static const textSecDark = Color(0xB8FFFFFF);
  static const textSecLight = Color(0xFF64748B);
  static const spaceH = 16.0;
  static const spaceV = 12.0;
  static const sectionTitleSize = 20.0;
  static const sectionTitleWeight = FontWeight.w600;
}

class MainMoviesList extends StatefulWidget {
  final String api;
  final bool? includeAdult;
  final String discoverType;
  final bool isTrending;
  final String title;
  const MainMoviesList({
    super.key,
    required this.api,
    required this.discoverType,
    required this.isTrending,
    required this.includeAdult,
    required this.title,
  });
  @override
  MainMoviesListState createState() => MainMoviesListState();
}

class MainMoviesListState extends State<MainMoviesList> {
  List<Movie>? moviesList;
  final _scrollController = ScrollController();
  int pageNum = 2;
  bool isLoading = false;

  void getMoreData() async {
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });
        if (mounted) {
          fetchMovies(
                  '${widget.api}&include_adult=${widget.includeAdult}&page=$pageNum',
                  isProxyEnabled,
                  proxyUrl)
              .then((value) {
            if (mounted) {
              setState(() {
                final existingIds = moviesList!.map((m) => m.id).toSet();
                var filteredValue = value;
                if (widget.discoverType == 'upcoming') {
                  filteredValue = value.where((m) {
                    if (m.releaseDate == null || m.releaseDate!.isEmpty) {
                      return true;
                    }
                    return DateTime.tryParse(m.releaseDate!)
                            ?.isAfter(DateTime.now()) ??
                        true;
                  }).toList();
                }

                final newMovies = filteredValue
                    .where((m) => !existingIds.contains(m.id))
                    .toList();
                moviesList!.addAll(newMovies);
                isLoading = false;
                pageNum++;
              });
            }
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchMovies('${widget.api}&include_adult=${widget.includeAdult}',
            isProxyEnabled, proxyUrl)
        .then((value) {
      if (mounted) {
        setState(() {
          if (widget.discoverType == 'upcoming') {
            moviesList = value.where((m) {
              if (m.releaseDate == null || m.releaseDate!.isEmpty) return true;
              return DateTime.tryParse(m.releaseDate!)
                      ?.isAfter(DateTime.now()) ??
                  true;
            }).toList();
          } else {
            moviesList = value;
          }
        });
      }
    });
    getMoreData();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<SettingsProvider>().appTheme;
    final imageQuality = context.watch<SettingsProvider>().imageQuality;
    final viewType = context.watch<SettingsProvider>().defaultView;
    final isDark = themeMode == 'dark' || themeMode == 'amoled';
    final bg =
        isDark ? _ViewAllDesign.bgCanvasDark : _ViewAllDesign.bgCanvasLight;
    final surface =
        isDark ? _ViewAllDesign.bgSurfaceDark : _ViewAllDesign.bgSurfaceLight;
    final textPrim =
        isDark ? _ViewAllDesign.textPrimDark : _ViewAllDesign.textPrimLight;
    final textSec =
        isDark ? _ViewAllDesign.textSecDark : _ViewAllDesign.textSecLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        foregroundColor: textPrim,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          tr("movie_type", namedArgs: {"t": widget.title}),
          style: TextStyle(
            color: textPrim,
            fontSize: _ViewAllDesign.sectionTitleSize,
            fontWeight: _ViewAllDesign.sectionTitleWeight,
          ),
        ),
        iconTheme: IconThemeData(color: textPrim),
      ),
      body: moviesList == null && viewType == 'grid'
          ? moviesAndTVShowGridShimmer(themeMode)
          : moviesList == null && viewType == 'list'
              ? mainPageVerticalScrollShimmer(
                  themeMode: themeMode,
                  isLoading: isLoading,
                  scrollController: _scrollController)
              : moviesList!.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: _ViewAllDesign.spaceH),
                        child: Text(
                          tr("movie_404"),
                          style: TextStyle(
                            color: textSec,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: _ViewAllDesign.spaceH,
                              right: _ViewAllDesign.spaceH,
                              top: _ViewAllDesign.spaceV,
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                    child: viewType == 'grid'
                                        ? MovieGridView(
                                            scrollController: _scrollController,
                                            moviesList: moviesList,
                                            imageQuality: imageQuality,
                                            themeMode: themeMode)
                                        : MovieListView(
                                            scrollController: _scrollController,
                                            moviesList: moviesList,
                                            themeMode: themeMode,
                                            imageQuality: imageQuality)),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: isLoading,
                          child: Padding(
                            padding:
                                const EdgeInsets.all(_ViewAllDesign.spaceH),
                            child: LinearProgressIndicator(
                              backgroundColor: isDark
                                  ? _ViewAllDesign.bgSurfaceDark
                                  : _ViewAllDesign.bgCanvasLight,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  _ViewAllDesign.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}
