
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/movies_api.dart';
import 'package:caffiene/models/movie_models.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/movie_screens/widgets/movie_grid_view.dart';
import 'package:caffiene/screens/movie_screens/widgets/movie_list_view.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';

class MainMoviesList extends StatefulWidget {
  final String api;
  final bool? includeAdult;
  final String discoverType;
  final bool isTrending;
  final String title;
  const MainMoviesList({
    Key? key,
    required this.api,
    required this.discoverType,
    required this.isTrending,
    required this.includeAdult,
    required this.title,
  }) : super(key: key);
  @override
  MainMoviesListState createState() => MainMoviesListState();
}

class MainMoviesListState extends State<MainMoviesList> {
  List<Movie>? moviesList;
  final _scrollController = ScrollController();
  int pageNum = 2;
  bool isLoading = false;

  void getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });
        if (mounted) {
          moviesApi().fetchMovies(
                  '${widget.api}&include_adult=${widget.includeAdult}&page=$pageNum')
              .then((value) {
            if (mounted) {
              setState(() {
                moviesList!.addAll(value);
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
    moviesApi()
        .fetchMovies('${widget.api}&include_adult=${widget.includeAdult}')
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
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("movie_type", namedArgs: {"t": widget.title})),
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
                      child: Text(tr("movie_404")),
                    )
                  : Column(
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
                                            imageQuality: imageQuality)),
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
                    ),
    );
  }
}
