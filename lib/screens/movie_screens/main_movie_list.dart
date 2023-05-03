import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dpad_container/dpad_container.dart';
import 'package:flutter/material.dart';
import 'package:login/api/movies_api.dart';
import 'package:login/models/movie_models.dart';
import 'package:login/provider/settings_provider.dart';
import 'package:login/screens/movie_screens/movie_details.dart';
import 'package:login/screens/movie_screens/widgets/movie_grid_view.dart';
import 'package:login/screens/movie_screens/widgets/movie_list_view.dart';
import 'package:login/utils/config.dart';
import 'package:http/http.dart' as http;
import 'package:login/widgets/shimmer_widget.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} movies'),
      ),
      body: moviesList == null && viewType == 'grid'
          ? moviesAndTVShowGridShimmer(isDark)
          : moviesList == null && viewType == 'list'
              ? mainPageVerticalScrollShimmer1(
                  isDark: isDark,
                  isLoading: isLoading,
                  scrollController: _scrollController)
              : moviesList!.isEmpty
                  ? const Center(
                      child: Text('Oops! the movies don\'t exist :('),
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
                                            isDark: isDark)
                                        : MovieListView(
                                            scrollController: _scrollController,
                                            moviesList: moviesList,
                                            isDark: isDark,
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
