import 'package:cached_network_image/cached_network_image.dart';
import 'package:caffiene/functions/functions.dart';
import 'package:caffiene/functions/network.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/widgets/common_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/models/tv.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/tv_screens/episode_detail_page.dart';
import 'package:caffiene/utils/config.dart';
import 'package:provider/provider.dart';
import 'package:caffiene/utils/constant.dart';

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
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchTVDetails(widget.api!, isProxyEnabled, proxyUrl).then((value) {
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
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return Container(
        child: tvDetails == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, left: 8.0, right: 8.0),
                          child: Row(
                            children: [
                              const LeadingDot(),
                              Expanded(
                                child: Text(
                                  tr("episodes"),
                                  style: kTextHeaderStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: 10,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          padding: const EdgeInsets.only(right: 10),
                          child: Column(
                            children: [
                              ShimmerBase(
                                themeMode: themeMode,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 10.0, left: 5.0),
                                      child: Container(
                                        height: 90.0,
                                        width: 160,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(3.0),
                                          color: Colors.grey.shade600,
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
                                                color: Colors.grey.shade600,
                                                height: 19,
                                                width: 150),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 2.0),
                                            child: Container(
                                                color: Colors.grey.shade600,
                                                height: 19,
                                                width: 110),
                                          ),
                                          Row(children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 3.0),
                                              child: Container(
                                                  color: Colors.grey.shade600,
                                                  height: 20,
                                                  width: 20),
                                            ),
                                            Container(
                                                color: Colors.grey.shade600,
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
                                thickness: 0.5,
                                endIndent: 5,
                                indent: 5,
                              ),
                            ],
                          ),
                        );
                      }),
                ],
              )
            : tvDetails!.episodes!.isEmpty
                ? Center(
                    child:
                        Text(tr("no_episodes"), style: kTextSmallHeaderStyle),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 8.0, left: 8.0, right: 8.0),
                              child: Row(
                                children: [
                                  const LeadingDot(),
                                  Expanded(
                                    child: Text(
                                      tr("episodes"),
                                      style: kTextHeaderStyle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10.0, left: 5.0),
                                            child: SizedBox(
                                              height: 90,
                                              width: 160,
                                              child: Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3.0),
                                                    child: tvDetails!
                                                                    .episodes![
                                                                        index]
                                                                    .stillPath ==
                                                                null ||
                                                            tvDetails!
                                                                .episodes![
                                                                    index]
                                                                .stillPath!
                                                                .isEmpty
                                                        ? Image.asset(
                                                            'assets/images/na_logo.png',
                                                            fit: BoxFit.cover,
                                                            width:
                                                                double.infinity,
                                                          )
                                                        : CachedNetworkImage(
                                                            cacheManager:
                                                                cacheProp(),
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
                                                            imageUrl: buildImageUrl(
                                                                    TMDB_BASE_IMAGE_URL,
                                                                    proxyUrl,
                                                                    isProxyEnabled,
                                                                    context) +
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
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                            placeholder:
                                                                (context,
                                                                        url) =>
                                                                    ShimmerBase(
                                                              themeMode:
                                                                  themeMode,
                                                              child: Container(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade600),
                                                            ),
                                                            errorWidget:
                                                                (context, url,
                                                                        error) =>
                                                                    Image.asset(
                                                              'assets/images/na_logo.png',
                                                              fit: BoxFit.cover,
                                                              width: double
                                                                  .infinity,
                                                            ),
                                                          ),
                                                  ),
                                                  Positioned(
                                                      bottom: 0,
                                                      left: 0,
                                                      child: Container(
                                                        color: Colors.black54,
                                                        margin: const EdgeInsets
                                                            .only(
                                                            left: 4, bottom: 4),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 0.7,
                                                                horizontal: 6),
                                                        child: Text(
                                                            '${tvDetails!.episodes![index].episodeNumber! <= 9 ? tvDetails!.episodes![index].episodeNumber.toString().padLeft(2, '0') : tvDetails!.episodes![index].episodeNumber!}',
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 17)),
                                                      ))
                                                ],
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
                                                          .ellipsis),
                                                  maxLines: 2,
                                                ),
                                                Text(
                                                  tvDetails!.episodes![index]
                                                                  .airDate ==
                                                              null ||
                                                          tvDetails!
                                                              .episodes![index]
                                                              .airDate!
                                                              .isEmpty
                                                      ? tr("air_date_unknown")
                                                      : '${DateTime.parse(tvDetails!.episodes![index].airDate!).day} ${DateFormat("MMMM").format(DateTime.parse(tvDetails!.episodes![index].airDate!))}, ${DateTime.parse(tvDetails!.episodes![index].airDate!).year}',
                                                  style: TextStyle(
                                                    color:
                                                        themeMode == "dark" ||
                                                                themeMode ==
                                                                    "amoled"
                                                            ? Colors.white54
                                                            : Colors.black54,
                                                  ),
                                                ),
                                                Row(children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 3.0),
                                                    child: Icon(
                                                      Icons.star_rounded,
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
                                        thickness: 0.5,
                                        endIndent: 5,
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
