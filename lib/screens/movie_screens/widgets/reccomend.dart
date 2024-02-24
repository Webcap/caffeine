import 'package:caffiene/functions/network.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/widgets/common_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
  const MovieRecommendationsTab(
      {Key? key,
      required this.api,
      required this.movieId,
      required this.includeAdult})
      : super(key: key);

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
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchMovies('${widget.api}&include_adult=${widget.includeAdult}',
            isProxyEnabled, proxyUrl)
        .then((value) {
      if (mounted) {
        setState(() {
          movieList = value;
        });
      }
    });
    getMoreData();
  }

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
                  child: Row(
                    children: [
                      const LeadingDot(),
                      Expanded(
                        child: Text(
                          tr("movie_recommendations"),
                          style: kTextHeaderStyle,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 250,
            child: movieList == null || widget.includeAdult == null
                ? scrollingMoviesAndTVShimmer(themeMode)
                : movieList!.isEmpty
                    ? Center(
                        child: Text(
                          tr("no_recommendations_movie"),
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
                              child: horizontalLoadMoreShimmer(themeMode),
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
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchMovies('${widget.api}&include_adult=${widget.includeAdult}',
            isProxyEnabled, proxyUrl)
        .then((value) {
      if (mounted) {
        setState(() {
          movieList = value;
        });
      }
    });
    getMoreData();
  }

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
                  child: Row(
                    children: [
                      const LeadingDot(),
                      Expanded(
                        child: Text(
                          tr("movies_similar_with",
                              namedArgs: {"movie": widget.movieName}),
                          style: kTextHeaderStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 250,
            child: movieList == null || widget.includeAdult == null
                ? scrollingMoviesAndTVShimmer(themeMode)
                : movieList!.isEmpty
                    ? Center(
                        child: Text(
                          tr("no_similars_movie"),
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
                              child: horizontalLoadMoreShimmer(themeMode),
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
