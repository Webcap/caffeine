import 'package:cached_network_image/cached_network_image.dart';
import 'package:caffiene/models/recently_watched.dart';
import 'package:caffiene/provider/recently_watched_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/tv_screens/tv_video_loader.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScrollingRecentEpisodes extends StatefulWidget {
  const ScrollingRecentEpisodes({required this.episodesList, Key? key})
      : super(key: key);

  final List<RecentEpisode> episodesList;

  @override
  State<ScrollingRecentEpisodes> createState() =>
      _ScrollingRecentEpisodesState();
}

class _ScrollingRecentEpisodesState extends State<ScrollingRecentEpisodes> {
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Column(
      children: <Widget>[
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Recently Watched',
                style: kTextHeaderStyle,
              ),
            ),
            // Padding(
            //     padding: const EdgeInsets.all(8),
            //     child: TextButton(
            //       onPressed: () {
            //         Navigator.push(context,
            //             MaterialPageRoute(builder: (context) {
            //           return const TVVideoLoader(download: false, metadata: []);
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
          height: 280,
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.episodesList.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    final recentEpisodes =
                        Provider.of<RecentProvider>(context, listen: false);
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onLongPress: () {
                          recentEpisodes.deleteEpisode(
                              widget.episodesList[index].id!,
                              widget.episodesList[index].episodeNum!,
                              widget.episodesList[index].seasonNum!);
                        },
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TVVideoLoader(
                                        download: false,
                                        metadata: [
                                          widget.episodesList[index].id,
                                          widget.episodesList[index].seriesName,
                                          widget
                                              .episodesList[index].episodeName,
                                          widget.episodesList[index].episodeNum,
                                          widget.episodesList[index].seasonNum,
                                          widget
                                              .episodesList[index].totalSeasons,
                                          widget
                                              .episodesList[index].backdropPath,
                                          widget.episodesList[index].posterPath,
                                          widget.episodesList[index].elapsed
                                        ],
                                      )));
                        },
                        child: SizedBox(
                          width: 100,
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                flex: 8,
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: widget.episodesList[index]
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
                                                            .episodesList[index]
                                                            .posterPath ==
                                                        null
                                                    ? ''
                                                    : TMDB_BASE_IMAGE_URL +
                                                        imageQuality +
                                                        widget
                                                            .episodesList[index]
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
                                                        isDark),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  'assets/images/na_rect.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        child: Container(
                                          margin: const EdgeInsets.all(3),
                                          alignment: Alignment.center,
                                          width: 70,
                                          height: 22,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.85)),
                                          child: Row(
                                            children: [
                                              Text(
                                                  '${widget.episodesList[index].seasonNum! <= 9 ? 'S0${widget.episodesList[index].seasonNum!}' : 'S${widget.episodesList[index].seasonNum!}'} | '
                                                  '${widget.episodesList[index].episodeNum! <= 9 ? 'E0${widget.episodesList[index].episodeNum!}' : 'E${widget.episodesList[index].episodeNum!}'}'
                                                  '',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary
                                                          .withOpacity(0.85)))
                                            ],
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
                                            value: (widget.episodesList[index]
                                                    .elapsed! /
                                                (widget.episodesList[index]
                                                        .remaining! +
                                                    widget.episodesList[index]
                                                        .elapsed!)),
                                          ),
                                        ),
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
                                    widget.episodesList[index].seriesName!,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Text(
                                    widget.episodesList[index].episodeName!,
                                    maxLines: 2,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900),
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
          color: !isDark ? Colors.black54 : Colors.white54,
          thickness: 1,
          endIndent: 20,
          indent: 10,
        ),
      ],
    );
  }
}
