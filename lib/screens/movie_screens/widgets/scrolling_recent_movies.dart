import 'package:cached_network_image/cached_network_image.dart';
import 'package:caffiene/functions/functions.dart';
import 'package:caffiene/models/recently_watched.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/provider/recently_watched_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/movie_screens/widgets/movie_video_loader.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/widgets/common_widgets.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScrollingRecentMovies extends StatefulWidget {
  const ScrollingRecentMovies({required this.moviesList, Key? key})
      : super(key: key);

  final List<RecentMovie> moviesList;

  @override
  State<ScrollingRecentMovies> createState() => _ScrollingRecentMoviesState();
}

class _ScrollingRecentMoviesState extends State<ScrollingRecentMovies> {
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final fetchRoute = Provider.of<AppDependencyProvider>(context).fetchRoute;
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
                          prv.deleteMovie(widget.moviesList[index].id!);
                        },
                        onTap: () async {
                          await checkConnection().then((value) {
                            value
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MovieVideoLoader(
                                              download: false,
                                              /* return to fetchRoute instead of hard text*/ route:
                                                  fetchRoute == "flixHQ"
                                                      ? StreamRoute.flixHQ
                                                      : StreamRoute.tmDB,
                                              metadata: [
                                                widget.moviesList[index].id,
                                                widget.moviesList[index].title,
                                                widget.moviesList[index]
                                                    .posterPath,
                                                widget.moviesList[index]
                                                    .releaseYear,
                                                widget.moviesList[index]
                                                    .backdropPath,
                                                widget.moviesList[index].elapsed
                                              ],
                                            )))
                                : ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        tr("check_connection"),
                                        maxLines: 3,
                                        style: kTextSmallBodyStyle,
                                      ),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                          });
                        },
                        child: SizedBox(
                          width: 100,
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                flex: 6,
                                child: Material(
                                  type: MaterialType.transparency,
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
                                                'assets/images/na_rect.png',
                                                fit: BoxFit.cover,
                                              )
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
                                                    : TMDB_BASE_IMAGE_URL +
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
                                                    scrollingImageShimmer1(
                                                        themeMode),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  'assets/images/na_rect.png',
                                                  fit: BoxFit.cover,
                                                ),
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
                                      Positioned(
                                        top: -15,
                                        right: 8,
                                        child: Container(
                                            alignment: Alignment.topRight,
                                            child: IconButton(
                                              alignment: Alignment.topRight,
                                              onPressed: () async {
                                                prv.deleteMovie(widget
                                                    .moviesList[index].id!);
                                              },
                                              icon: const Icon(
                                                  Icons.bookmark_remove,
                                                  size: 60),
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    widget.moviesList[index].title!,
                                    maxLines: 2,
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
