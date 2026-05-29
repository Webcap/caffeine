import 'package:cached_network_image/cached_network_image.dart';
import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/models/movie_stream_metadata.dart';
import 'package:reelriot/models/recently_watched.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/utils/globals.dart';
import 'package:reelriot/provider/recently_watched_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/widgets/unified_video_loader.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/utils/globlal_methods.dart';
import 'package:reelriot/utils/theme/textStyle.dart';
import 'package:reelriot/widgets/common_widgets.dart';
import 'package:reelriot/widgets/shimmer_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reelriot/utils/constant.dart';
import 'package:reelriot/widgets/mobile_context_menu.dart';

class ScrollingRecentMovies extends StatefulWidget {
  const ScrollingRecentMovies({required this.moviesList, super.key});

  final List<RecentMovie> moviesList;

  @override
  State<ScrollingRecentMovies> createState() => _ScrollingRecentMoviesState();
}

class _ScrollingRecentMoviesState extends State<ScrollingRecentMovies> {
  final ScrollController _scrollController = ScrollController();
  bool _lockTap = false;

  void _suppressTap() {
    setState(() => _lockTap = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _lockTap = false);
    });
  }
  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final fetchRoute = Provider.of<AppDependencyProvider>(context).fetchRoute;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return Column(
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
                        tr("recently_watched"),
                        style: kTextHeaderStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Padding(
            //     padding: const EdgeInsets.all(8),
            //     child: TextButton(
            //       onPressed: () {
            //         Navigator.push(context,
            //             MaterialPageRoute(builder: (context) {
            //           return const MovieVideoLoader(
            //               download: false, metadata: []);
            //         }));
            //       },
            //       style: ButtonStyle(
            //           maximumSize:
            //               MaterialStateProperty.all(const Size(200, 60)),
            //           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            //               RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(20.0),
            //           ))),
            //       child: const Padding(
            //         padding: EdgeInsets.only(left: 8.0, right: 8.0),
            //         child: Text('View all'),
            //       ),
            //     )),
          ],
        ),
        SizedBox(
          width: double.infinity,
          height: 250,
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.moviesList.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    final prv =
                        Provider.of<RecentProvider>(context, listen: false);
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onLongPress: () {
                          _suppressTap();
                          final movie = widget.moviesList[index];
                          MobileContextMenu.show(
                            context: context,
                            title: movie.title ?? '',
                            subtitle: '${movie.releaseYear}',
                            items: [
                              MobileContextMenuItem(
                                label: tr("mark_as_completed"),
                                icon: Icons.check_circle_outline,
                                onTap: () {
                                  prv.markMovieAsCompleted(movie);
                                },
                              ),
                              MobileContextMenuItem(
                                label: tr("remove_from_history"),
                                icon: Icons.delete_outline,
                                color: Colors.red,
                                onTap: () {
                                  prv.deleteMovie(movie.id!);
                                },
                              ),
                            ],
                          );
                        },
                        onTap: () async {
                          if (_lockTap) return;
                              final connected = await checkConnection();
                              if (!context.mounted) return;
                              if (connected) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            UnifiedVideoLoader(
                                                mediaType: MediaType.movie,
                                                download: false,
                                                /* return to fetchRoute instead of hard text*/ route:
                                                    fetchRoute == "flixHQ"
                                                        ? StreamRoute.flixHQ
                                                        : StreamRoute.tmDB,
                                                movieMetadata: MovieStreamMetadata(
                                                    backdropPath: widget
                                                        .moviesList[index]
                                                        .backdropPath,
                                                    elapsed: widget
                                                        .moviesList[index]
                                                        .elapsed,
                                                    isAdult: null,
                                                    movieId: widget
                                                        .moviesList[index].id,
                                                    movieName: widget
                                                        .moviesList[index].title,
                                                    posterPath: widget
                                                        .moviesList[index]
                                                        .posterPath,
                                                    releaseYear: widget
                                                        .moviesList[index]
                                                        .releaseYear,
                                                    releaseDate: null))));
                              } else {
                                GlobalMethods.showCustomScaffoldMessage(
                                    SnackBar(
                                      content: Text(
                                        tr("check_connection"),
                                        maxLines: 3,
                                        style: kTextSmallBodyStyle,
                                      ),
                                      duration: const Duration(seconds: 3),
                                    ),
                                    context);
                              }
                        },
                        child: SizedBox(
                          width: 100,
                          child: Column(
                            children: <Widget>[
                              Material(
                                type: MaterialType.transparency,
                                child: SizedBox(
                                  height: 155,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: widget.moviesList[index]
                                                    .posterPath ==
                                                null
                                            ? Image.asset(
                                                'assets/images/na_logo.png',
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity)
                                            : CachedNetworkImage(
                                                cacheManager: cacheProp(),
                                                fadeOutDuration: const Duration(
                                                    milliseconds: 300),
                                                fadeOutCurve: Curves.easeOut,
                                                fadeInDuration: const Duration(
                                                    milliseconds: 700),
                                                fadeInCurve: Curves.easeIn,
                                                imageUrl: widget
                                                            .moviesList[index]
                                                            .posterPath ==
                                                        null
                                                    ? ''
                                                    : buildImageUrl(
                                                            tmdbBaseImageUrl,
                                                            proxyUrl,
                                                            isProxyEnabled,
                                                            context) +
                                                        imageQuality +
                                                        widget.moviesList[index]
                                                            .posterPath!,
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        Container(
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                placeholder: (context, url) =>
                                                    scrollingImageShimmer(
                                                        themeMode),
                                                errorWidget: (context, url,
                                                        error) =>
                                                    Image.asset(
                                                        'assets/images/na_logo.png',
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                        height:
                                                            double.infinity),
                                              ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8)),
                                          child: LinearProgressIndicator(
                                            value: (widget.moviesList[index]
                                                    .elapsed! /
                                                (widget.moviesList[index]
                                                        .remaining! +
                                                    widget.moviesList[index]
                                                        .elapsed!)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    widget.moviesList[index].title!,
                                    maxLines: 3,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
    );
  }
}
