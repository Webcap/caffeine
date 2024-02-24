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

class ParticularStreamingServiceMovies extends StatefulWidget {
  final String api;
  final int providerID;
  final bool? includeAdult;
  final String watchRegion;
  const ParticularStreamingServiceMovies({
    Key? key,
    required this.api,
    required this.providerID,
    required this.includeAdult,
    required this.watchRegion,
  }) : super(key: key);
  @override
  ParticularStreamingServiceMoviesState createState() =>
      ParticularStreamingServiceMoviesState();
}

class ParticularStreamingServiceMoviesState
    extends State<ParticularStreamingServiceMovies> {
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
                ? Container(
                    child: Center(
                      child: Text(tr("no_watchprovider_movie")),
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
                  ));
  }
}
