import 'package:cached_network_image/cached_network_image.dart';
import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/models/recently_watched.dart';
import 'package:reelriot/models/tv_stream_metadata.dart';
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

class ScrollingRecentEpisodes extends StatefulWidget {
  const ScrollingRecentEpisodes(
      {required this.episodesList, required this.title, super.key});

  final List<RecentEpisode> episodesList;
  final String title;

  @override
  State<ScrollingRecentEpisodes> createState() =>
      _ScrollingRecentEpisodesState();
}

class _ScrollingRecentEpisodesState extends State<ScrollingRecentEpisodes> {
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
                        widget.title,
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
        LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = MediaQuery.sizeOf(context).height;
            final screenWidth = MediaQuery.sizeOf(context).width;
            final rowHeight = (screenHeight * 0.28).clamp(260.0, 340.0);
            final horizontalPadding = 16.0;
            final itemHeight = rowHeight - horizontalPadding;
            final cardWidth = (screenWidth * 0.22).clamp(90.0, 120.0);
            final posterHeight = itemHeight * 0.52;
            return SizedBox(
              width: double.infinity,
              height: rowHeight,
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
                              _suppressTap();
                              final ep = widget.episodesList[index];
                              MobileContextMenu.show(
                                context: context,
                                title: ep.seriesName ?? '',
                                subtitle:
                                    'S${ep.seasonNum} | E${ep.episodeNum} - ${ep.episodeName}',
                                items: [
                                  MobileContextMenuItem(
                                    label: tr("mark_as_completed"),
                                    icon: Icons.check_circle_outline,
                                    onTap: () {
                                      recentEpisodes.markEpisodeAsCompleted(ep);
                                    },
                                  ),
                                  MobileContextMenuItem(
                                    label: tr("remove_from_history"),
                                    icon: Icons.delete_outline,
                                    color: Colors.red,
                                    onTap: () {
                                      recentEpisodes.deleteEpisode(
                                          ep.id!, ep.episodeNum!, ep.seasonNum!);
                                    },
                                  ),
                                ],
                              );
                            },
                            onTap: () async {
                              if (_lockTap) return;
                              final connected = await checkConnection();
                              if (!mounted) return;
                              if (connected) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            UnifiedVideoLoader(
                                                mediaType: MediaType.tvShow,
                                                download: false,
                                                route: fetchRoute == "flixHQ"
                                                    ? StreamRoute.flixHQ
                                                    : StreamRoute.tmDB,
                                                tvMetadata: TVStreamMetadata(
                                                  elapsed: widget
                                                      .episodesList[index]
                                                      .elapsed,
                                                  episodeId: widget
                                                      .episodesList[index].id,
                                                  episodeName: widget
                                                      .episodesList[index]
                                                      .episodeName,
                                                  episodeNumber: widget
                                                      .episodesList[index]
                                                      .episodeNum,
                                                  posterPath: widget
                                                      .episodesList[index]
                                                      .posterPath,
                                                  seasonNumber: widget
                                                      .episodesList[index]
                                                      .seasonNum,
                                                  seriesName: widget
                                                      .episodesList[index]
                                                      .seriesName,
                                                  tvId: widget
                                                      .episodesList[index]
                                                      .seriesId,
                                                  airDate: null,
                                                ))));
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
                              width: cardWidth,
                              height: itemHeight,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Material(
                                    type: MaterialType.transparency,
                                    child: SizedBox(
                                      height: posterHeight,
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
                                                    'assets/images/na_logo.png',
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity)
                                                : CachedNetworkImage(
                                                    cacheManager: cacheProp(),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 300),
                                                    fadeOutCurve:
                                                        Curves.easeOut,
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 700),
                                                    fadeInCurve: Curves.easeIn,
                                                    imageUrl: widget
                                                                .episodesList[
                                                                    index]
                                                                .posterPath ==
                                                            null
                                                        ? ''
                                                        : TMDB_BASE_IMAGE_URL +
                                                            imageQuality +
                                                            widget
                                                                .episodesList[
                                                                    index]
                                                                .posterPath!,
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    placeholder: (context,
                                                            url) =>
                                                        scrollingImageShimmer(
                                                            themeMode),
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        Image.asset(
                                                            'assets/images/na_logo.png',
                                                            fit: BoxFit.cover,
                                                            width:
                                                                double.infinity,
                                                            height: double
                                                                .infinity),
                                                  ),
                                          ),
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            child: Container(
                                              margin: const EdgeInsets.all(3),
                                              alignment: Alignment.center,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withValues(alpha: 0.85)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                        '${(widget.episodesList[index].seasonNum ?? 0) <= 9 ? 'S0${widget.episodesList[index].seasonNum ?? 0}' : 'S${widget.episodesList[index].seasonNum ?? 0}'} | '
                                                        '${(widget.episodesList[index].episodeNum ?? 0) <= 9 ? 'E0${widget.episodesList[index].episodeNum ?? 0}' : 'E${widget.episodesList[index].episodeNum ?? 0}'}'
                                                        '',
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onPrimary
                                                                .withValues(alpha: 0.85)))
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(8),
                                                      bottomRight:
                                                          Radius.circular(8)),
                                              child: LinearProgressIndicator(
                                                value: ((widget.episodesList[index].elapsed ?? 0) /
                                                    ((widget.episodesList[index].remaining ?? 0) +
                                                        (widget.episodesList[index].elapsed ?? 0))),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6.0, vertical: 4.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            widget.episodesList[index]
                                                    .seriesName ??
                                                '',
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'S${(widget.episodesList[index].seasonNum ?? 0).toString().padLeft(2, '0')} E${(widget.episodesList[index].episodeNum ?? 0).toString().padLeft(2, '0')}${widget.episodesList[index].episodeName != null ? ' • ${widget.episodesList[index].episodeName}' : ''}',
                                            maxLines: 3,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 11),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
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
            );
          },
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
