import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/tv_api.dart';
import 'package:caffiene/models/tv.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/tv_screens/episode_detail_page.dart';
import 'package:caffiene/utils/config.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class EpisodeListWidget extends StatefulWidget {
  final int? tvId;
  final String? api;
  final String? seriesName;
  final String? posterPath;
  const EpisodeListWidget({
    Key? key,
    this.api,
    this.tvId,
    this.seriesName,
    required this.posterPath,
  }) : super(key: key);

  @override
  EpisodeListWidgetState createState() => EpisodeListWidgetState();
}

class EpisodeListWidgetState extends State<EpisodeListWidget>
    with AutomaticKeepAliveClientMixin {
  TVDetails? tvDetails;

  @override
  void initState() {
    super.initState();
    tvApi().fetchTVDetails(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          tvDetails = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return Container(
        child: tvDetails == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Episodes',
                      style: kTextHeaderStyle,
                    ),
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: 10,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 0.0,
                              bottom: 8.0,
                              left: 10,
                            ),
                            child: Column(
                              children: [
                                Shimmer.fromColors(
                                  baseColor: isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade300,
                                  highlightColor: isDark
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade100,
                                  direction: ShimmerDirection.ltr,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          color: Colors.white,
                                          width: 10,
                                          height: 15),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 10.0, left: 5.0),
                                        child: Container(
                                          height: 56.4,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6.0),
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 2.0),
                                              child: Container(
                                                  color: Colors.white,
                                                  height: 19,
                                                  width: 150),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 2.0),
                                              child: Container(
                                                  color: Colors.white,
                                                  height: 19,
                                                  width: 110),
                                            ),
                                            Row(children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 3.0),
                                                child: Container(
                                                    color: Colors.white,
                                                    height: 20,
                                                    width: 20),
                                              ),
                                              Container(
                                                  color: Colors.white,
                                                  height: 20,
                                                  width: 25),
                                            ]),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: Theme.of(context).colorScheme.primary,
                                  thickness: 1.5,
                                  endIndent: 30,
                                  indent: 5,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ],
              )
            : tvDetails!.episodes!.isEmpty
                ? const Center(
                    child: Text('No episodes found :(',
                        style: kTextSmallHeaderStyle),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Episodes',
                          style: kTextHeaderStyle,
                        ),
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: tvDetails!.episodes!.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return EpisodeDetailPage(
                                      seriesName: widget.seriesName,
                                      posterPath: widget.posterPath,
                                      tvId: widget.tvId,
                                      episodes: tvDetails!.episodes,
                                      episodeList: tvDetails!.episodes![index]);
                                }));
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 0.0,
                                    bottom: 8.0,
                                    left: 10,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(tvDetails!
                                              .episodes![index].episodeNumber!
                                              .toString()),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10.0, left: 5.0),
                                            child: SizedBox(
                                              height: 56.4,
                                              width: 100,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(6.0),
                                                child: tvDetails!
                                                                .episodes![
                                                                    index]
                                                                .stillPath ==
                                                            null ||
                                                        tvDetails!
                                                            .episodes![index]
                                                            .stillPath!
                                                            .isEmpty
                                                    ? Image.asset(
                                                        'assets/images/na_logo.png',
                                                        fit: BoxFit.cover,
                                                      )
                                                    : CachedNetworkImage(
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    300),
                                                        fadeOutCurve:
                                                            Curves.easeOut,
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    700),
                                                        fadeInCurve:
                                                            Curves.easeIn,
                                                        imageUrl:
                                                            TMDB_BASE_IMAGE_URL +
                                                                imageQuality +
                                                                tvDetails!
                                                                    .episodes![
                                                                        index]
                                                                    .stillPath!,
                                                        imageBuilder: (context,
                                                                imageProvider) =>
                                                            Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            image:
                                                                DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        placeholder: (context,
                                                                url) =>
                                                            Shimmer.fromColors(
                                                          baseColor: isDark
                                                              ? Colors
                                                                  .grey.shade800
                                                              : Colors.grey
                                                                  .shade300,
                                                          highlightColor: isDark
                                                              ? Colors
                                                                  .grey.shade700
                                                              : Colors.grey
                                                                  .shade100,
                                                          direction:
                                                              ShimmerDirection
                                                                  .ltr,
                                                          child: Container(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Image.asset(
                                                          'assets/images/na_logo.png',
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    tvDetails!
                                                        .episodes![index].name!,
                                                    style: const TextStyle(
                                                        overflow: TextOverflow
                                                            .ellipsis)),
                                                Text(
                                                  tvDetails!.episodes![index]
                                                                  .airDate ==
                                                              null ||
                                                          tvDetails!
                                                              .episodes![index]
                                                              .airDate!
                                                              .isEmpty
                                                      ? 'Air date unknown'
                                                      : '${DateTime.parse(tvDetails!.episodes![index].airDate!).day} ${DateFormat("MMMM").format(DateTime.parse(tvDetails!.episodes![index].airDate!))}, ${DateTime.parse(tvDetails!.episodes![index].airDate!).year}',
                                                  style: TextStyle(
                                                    color: isDark
                                                        ? Colors.white54
                                                        : Colors.black54,
                                                  ),
                                                ),
                                                Row(children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 3.0),
                                                    child: Icon(
                                                      Icons.star,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  Text(tvDetails!
                                                      .episodes![index]
                                                      .voteAverage!
                                                      .toStringAsFixed(1))
                                                ]),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      Divider(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        thickness: 1.5,
                                        endIndent: 30,
                                        indent: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ],
                  ));
  }

  @override
  bool get wantKeepAlive => true;
}
