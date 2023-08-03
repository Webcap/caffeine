
import 'package:flutter/material.dart';
import 'package:caffiene/api/movies_api.dart';
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
      {Key? key,
      required this.api,
      required this.genreId,
      required this.includeAdult,
      required this.watchRegion})
      : super(key: key);
  @override
  ParticularGenreMoviesState createState() => ParticularGenreMoviesState();
}

class ParticularGenreMoviesState extends State<ParticularGenreMovies> {
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
          moviesApi()
              .fetchMovies(
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
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final viewType = Provider.of<SettingsProvider>(context).defaultView;
    return moviesList == null && viewType == 'grid'
        ? moviesAndTVShowGridShimmer(isDark)
        : moviesList == null && viewType == 'list'
            ? mainPageVerticalScrollShimmer1(
                isDark: isDark,
                isLoading: isLoading,
                scrollController: _scrollController)
            : moviesList!.isEmpty
                ? Container(
                    child: const Center(
                      child:
                          Text('Oops! movies for this genre doesn\'t exist :('),
                    ),
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
                                        isDark: isDark)
                                    : MovieListView(
                                        scrollController: _scrollController,
                                        moviesList: moviesList,
                                        isDark: isDark,
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
