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

class ParticularGenreMovies extends StatefulWidget {
  final String api;
  final int genreId;
  final String watchRegion;
  final bool? includeAdult;
  const ParticularGenreMovies(
      {super.key,
      required this.api,
      required this.genreId,
      required this.includeAdult,
      required this.watchRegion});
  @override
  ParticularGenreMoviesState createState() => ParticularGenreMoviesState();
}

class ParticularGenreMoviesState extends State<ParticularGenreMovies> {
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
                final newMovies =
                    value.where((m) => !existingIds.contains(m.id)).toList();
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
          moviesList = value;
        });
      }
    });
    getMoreData();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final viewType = Provider.of<SettingsProvider>(context).defaultView;
    return moviesList == null && viewType == 'grid'
        ? moviesAndTVShowGridShimmer(themeMode)
        : moviesList == null && viewType == 'list'
            ? mainPageVerticalScrollShimmer(
                themeMode: themeMode,
                isLoading: isLoading,
                scrollController: _scrollController)
            : moviesList!.isEmpty
                ? Center(
                    child: _EmptyGenreCard(message: tr("no_genre_movie")),
                  )
                : Container(
                    child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
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
                                        imageQuality: imageQuality),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                          visible: isLoading,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: LinearProgressIndicator()),
                          )),
                    ],
                  ));
  }
}

// ─── Design tokens (design.json) ─────────────────────────────────────────────
class _EmptyGenreCard extends StatelessWidget {
  final String message;

  const _EmptyGenreCard({required this.message});

  static const _surfaceDark = Color(0xFF0B0F14);
  static const _surfaceLight = Color(0xFFFFFFFF);
  static const _textSecDark = Color(0xB8FFFFFF);
  static const _textSecLight = Color(0xFF64748B);
  static const _borderDark = Color(0x14FFFFFF);
  static const _borderLight = Color(0x140F172A);
  static const _radiusMd = 16.0;
  static const _shadowCard = BoxShadow(
    color: Color(0x38000000),
    blurRadius: 30,
    offset: Offset(0, 10),
  );

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isDark = themeMode == 'dark' || themeMode == 'amoled';
    final surface = isDark ? _surfaceDark : _surfaceLight;
    final textSec = isDark ? _textSecDark : _textSecLight;
    final border = isDark ? _borderDark : _borderLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(_radiusMd),
          border: Border.all(color: border),
          boxShadow: const [_shadowCard],
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: textSec, fontSize: 15),
        ),
      ),
    );
  }
}
