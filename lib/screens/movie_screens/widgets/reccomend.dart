import 'package:flutter/material.dart';
import 'package:caffiene/api/movies_api.dart';
import 'package:caffiene/models/movie_models.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/movie_screens/widgets/horizontal_scrolling_movie_list.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';

class MovieRecommendationsTab extends StatefulWidget {
  final String api;
  final int movieId;
  final bool? includeAdult;
  const MovieRecommendationsTab({
    Key? key,
    required this.api,
    required this.movieId,
    required this.includeAdult,
  }) : super(key: key);

  @override
  MovieRecommendationsTabState createState() => MovieRecommendationsTabState();
}

class MovieRecommendationsTabState extends State<MovieRecommendationsTab>
    with AutomaticKeepAliveClientMixin {
  List<Movie>? movieList;
  final _scrollController = ScrollController();
  int pageNum = 2;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    moviesApi().fetchMovies('${widget.api}&include_adult=false').then((value) {
      if (mounted) {
        setState(() {
          movieList = value;
        });
      }
    });
    getMoreData();
  }

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
                movieList!.addAll(value);
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
  Widget build(BuildContext context) {
    super.build(context);
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return Container(
      child: Column(
        children: <Widget>[
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Movie recommendations',
                  style: kTextHeaderStyle,
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 250,
            child: movieList == null || widget.includeAdult == null
                ? scrollingMoviesAndTVShimmer1(themeMode)
                : movieList!.isEmpty
                    ? const Center(
                        child: Text(
                          'There are no recommendations available for this movie',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: HorizontalScrollingMoviesList(
                                scrollController: _scrollController,
                                movieList: movieList,
                                imageQuality: imageQuality,
                                themeMode: themeMode),
                          ),
                          Visibility(
                            visible: isLoading,
                            child: SizedBox(
                              width: 110,
                              child: horizontalLoadMoreShimmer1(themeMode),
                            ),
                          ),
                        ],
                      ),
          ),
          Divider(
            color: themeMode == "light" ? Colors.black54 : Colors.white54,
            thickness: 1,
            endIndent: 20,
            indent: 10,
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SimilarMoviesTab extends StatefulWidget {
  final String api;
  final int movieId;
  final String movieName;
  final bool? includeAdult;
  const SimilarMoviesTab(
      {Key? key,
      required this.api,
      required this.movieId,
      required this.movieName,
      required this.includeAdult})
      : super(key: key);

  @override
  SimilarMoviesTabState createState() => SimilarMoviesTabState();
}

class SimilarMoviesTabState extends State<SimilarMoviesTab>
    with AutomaticKeepAliveClientMixin {
  List<Movie>? movieList;
  final _scrollController = ScrollController();
  int pageNum = 2;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    moviesApi().fetchMovies('${widget.api}&include_adult=false').then((value) {
      if (mounted) {
        setState(() {
          movieList = value;
        });
      }
    });
    getMoreData();
  }

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
                movieList!.addAll(value);
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
  Widget build(BuildContext context) {
    super.build(context);
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Movies similar with ${widget.movieName}',
                    style: kTextHeaderStyle,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 250,
            child: movieList == null || widget.includeAdult == null
                ? scrollingMoviesAndTVShimmer1(themeMode)
                : movieList!.isEmpty
                    ? const Center(
                        child: Text(
                          'There are no similars available for this movie',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                              child: HorizontalScrollingMoviesList(
                            imageQuality: imageQuality,
                            themeMode: themeMode,
                            movieList: movieList,
                            scrollController: _scrollController,
                          )),
                          Visibility(
                            visible: isLoading,
                            child: SizedBox(
                              width: 110,
                              child: horizontalLoadMoreShimmer1(themeMode),
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
