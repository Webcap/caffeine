import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:login/api/movies_api.dart';
import 'package:login/models/movie_models.dart';
import 'package:login/provider/imagequality_provider.dart';
import 'package:login/provider/settings_provider.dart';
import 'package:login/screens/movie_screens/movie_details.dart';
import 'package:login/screens/movie_screens/widgets/movie_ui_componets.dart';
import 'package:login/utils/config.dart';
import 'package:http/http.dart' as http;
import 'package:login/widgets/shimmer_widget.dart';
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
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const <Widget>[
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
                ? scrollingMoviesAndTVShimmer1(isDark)
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
                                isDark: isDark),
                          ),
                          Visibility(
                            visible: isLoading,
                            child: SizedBox(
                              width: 110,
                              child: horizontalLoadMoreShimmer1(isDark),
                            ),
                          ),
                        ],
                      ),
          ),
          Divider(
            color: !isDark ? Colors.black54 : Colors.white54,
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
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
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
                ? scrollingMoviesAndTVShimmer1(isDark)
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
                            isDark: isDark,
                            movieList: movieList,
                            scrollController: _scrollController,
                          )),
                          Visibility(
                            visible: isLoading,
                            child: SizedBox(
                              width: 110,
                              child: horizontalLoadMoreShimmer1(isDark),
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
