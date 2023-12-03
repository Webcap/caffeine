import 'package:cached_network_image/cached_network_image.dart';
import 'package:caffiene/controller/bookmark_database_controller.dart';
import 'package:caffiene/models/tv.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/tv_screens/tv_detail_page.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caffiene/utils/constant.dart';


class tvWatchHistory extends StatefulWidget {
  const tvWatchHistory({Key? key, required this.tvList}) : super(key: key);

  final List<TV>? tvList;

  @override
  State<tvWatchHistory> createState() => _tvWatchHistoryState();
}

class _tvWatchHistoryState extends State<tvWatchHistory> {
  int count = 0;
  TVDatabaseController tvDatabaseController = TVDatabaseController();
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final viewType = Provider.of<SettingsProvider>(context).defaultView;
    return widget.tvList == null && viewType == 'grid'
        ? moviesAndTVShowGridShimmer(themeMode)
        : widget.tvList == null && viewType == 'list'
            ? mainPageVerticalScrollShimmer(
                themeMode: themeMode,
                scrollController: _scrollController,
                isLoading: false)
            : widget.tvList!.isEmpty
                ? Center(
                    child: Text(
                      tr("no_tv_watched"),
                      textAlign: TextAlign.center,
                      style: kTextSmallHeaderStyle,
                      maxLines: 4,
                    ),
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
                                      ? GridView.builder(
                                          controller: _scrollController,
                                          gridDelegate:
                                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                            maxCrossAxisExtent: 150,
                                            childAspectRatio: 0.48,
                                            crossAxisSpacing: 5,
                                            mainAxisSpacing: 5,
                                          ),
                                          itemCount: widget.tvList!.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return TVDetailPage(
                                                      tvSeries:
                                                          widget.tvList![index],
                                                      heroId:
                                                          '${widget.tvList![index].id}');
                                                }));
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                      flex: 6,
                                                      child: Hero(
                                                        tag:
                                                            '${widget.tvList![index].id}',
                                                        child: Material(
                                                          type: MaterialType
                                                              .transparency,
                                                          child: Stack(
                                                            alignment: Alignment
                                                                .center,
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                                child: widget
                                                                            .tvList![
                                                                                index]
                                                                            .posterPath ==
                                                                        null
                                                                    ? Image
                                                                        .asset(
                                                                        'assets/images/na_rect.png',
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      )
                                                                    : CachedNetworkImage(
                                                                        cacheManager:
                                                                            cacheProp(),
                                                                        fadeOutDuration:
                                                                            const Duration(milliseconds: 300),
                                                                        fadeOutCurve:
                                                                            Curves.easeOut,
                                                                        fadeInDuration:
                                                                            const Duration(milliseconds: 700),
                                                                        fadeInCurve:
                                                                            Curves.easeIn,
                                                                        imageUrl: TMDB_BASE_IMAGE_URL +
                                                                            imageQuality +
                                                                            widget.tvList![index].posterPath!,
                                                                        imageBuilder:
                                                                            (context, imageProvider) =>
                                                                                Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            image:
                                                                                DecorationImage(
                                                                              image: imageProvider,
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        placeholder:
                                                                            (context, url) =>
                                                                                scrollingImageShimmer(themeMode),
                                                                        errorWidget: (context,
                                                                                url,
                                                                                error) =>
                                                                            Image.asset(
                                                                          'assets/images/na_rect.png',
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                              ),
                                                              Positioned(
                                                                top: -15,
                                                                right: 8,
                                                                child:
                                                                    Container(
                                                                        alignment:
                                                                            Alignment
                                                                                .topRight,
                                                                        child:
                                                                            IconButton(
                                                                          alignment:
                                                                              Alignment.topRight,
                                                                          onPressed:
                                                                              () async {
                                                                            tvDatabaseController.deleteTV(widget.tvList![index].id!);
                                                                            //  movieList[index].favorite = false;
                                                                            if (mounted) {
                                                                              setState(() {
                                                                                widget.tvList!.removeAt(index);
                                                                              });
                                                                            }
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
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    // Positioned(
                                                    //   top: 0,
                                                    //   left: 5,
                                                    //   child: Container(
                                                    //     margin: const EdgeInsets
                                                    //         .all(3),
                                                    //     alignment:
                                                    //         Alignment.center,
                                                    //     width: 80,
                                                    //     height: 22,
                                                    //     decoration: BoxDecoration(
                                                    //         borderRadius:
                                                    //             BorderRadius
                                                    //                 .circular(
                                                    //                     8),
                                                    //         color: Theme.of(
                                                    //                 context)
                                                    //             .primaryColor
                                                    //             .withOpacity(
                                                    //                 0.85)),
                                                    //     child: Row(
                                                    //       children: [
                                                    //         Text(
                                                    //             // '${widget.tvList![index].seasonNumber! <= 9 ? 'S0${widget.tvList![index].seasonNumber!}' : 'S${widget.tvList![index].seasonNumber!}'} | '
                                                    //             // '${widget.tvList![index].episodeNumber! <= 9 ? 'E0${widget.tvList![index].episodeNumber!}' : 'E${widget.tvList![index].episodeNumber!}'}'
                                                    //             // '',
                                                    //             'EpName',
                                                    //             style: TextStyle(
                                                    //                 color: Theme.of(
                                                    //                         context)
                                                    //                     .colorScheme
                                                    //                     .onPrimary
                                                    //                     .withOpacity(
                                                    //                         0.85)))
                                                    //       ],
                                                    //     ),
                                                    //   ),
                                                    // ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                        '${widget.tvList![index].seasonNumber! <= 9 ? 'S0${widget.tvList![index].seasonNumber!}' : 'S${widget.tvList![index].seasonNumber!}'} | '
                                                        '${widget.tvList![index].episodeNumber! <= 9 ? 'E0${widget.tvList![index].episodeNumber!}' : 'E${widget.tvList![index].episodeNumber!}'}'
                                                        '',
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 1,
                                                        child: Text(
                                                          widget.tvList![index]
                                                              .seriesName!,
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                                  ],
                                                ),
                                              ),
                                            );
                                          })
                                      : ListView.builder(
                                          controller: _scrollController,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount: widget.tvList!.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return TVDetailPage(
                                                    tvSeries:
                                                        widget.tvList![index],
                                                    heroId:
                                                        '${widget.tvList![index].id}',
                                                  );
                                                }));
                                              },
                                              child: Container(
                                                color: Colors.transparent,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    top: 0.0,
                                                    bottom: 3.0,
                                                    left: 10,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right:
                                                                        10.0),
                                                            child: SizedBox(
                                                              width: 85,
                                                              height: 130,
                                                              child: Hero(
                                                                tag:
                                                                    '${widget.tvList![index].id}',
                                                                child: Material(
                                                                  type: MaterialType
                                                                      .transparency,
                                                                  child: ClipRRect(
                                                                      borderRadius: BorderRadius.circular(10.0),
                                                                      child: Stack(children: [
                                                                        widget.tvList![index].posterPath ==
                                                                                null
                                                                            ? Image.asset(
                                                                                'assets/images/na_logo.png',
                                                                                fit: BoxFit.cover,
                                                                              )
                                                                            : CachedNetworkImage(
                                                                                cacheManager: cacheProp(),
                                                                                fadeOutDuration: const Duration(milliseconds: 300),
                                                                                fadeOutCurve: Curves.easeOut,
                                                                                fadeInDuration: const Duration(milliseconds: 700),
                                                                                fadeInCurve: Curves.easeIn,
                                                                                imageUrl: TMDB_BASE_IMAGE_URL + imageQuality + widget.tvList![index].posterPath!,
                                                                                imageBuilder: (context, imageProvider) => Container(
                                                                                  decoration: BoxDecoration(
                                                                                    image: DecorationImage(
                                                                                      image: imageProvider,
                                                                                      fit: BoxFit.cover,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                placeholder: (context, url) => mainPageVerticalScrollImageShimmer(themeMode),
                                                                                errorWidget: (context, url, error) => Image.asset(
                                                                                  'assets/images/na_logo.png',
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                        Positioned(
                                                                          left:
                                                                              -18,
                                                                          top:
                                                                              -15,
                                                                          child: Container(
                                                                              alignment: Alignment.topLeft,
                                                                              child: IconButton(
                                                                                onPressed: () async {
                                                                                  tvDatabaseController.deleteTV(widget.tvList![index].id!);
                                                                                  //  movieList[index].favorite = false;
                                                                                  if (mounted) {
                                                                                    setState(() {
                                                                                      widget.tvList!.removeAt(index);
                                                                                    });
                                                                                  }
                                                                                },
                                                                                icon: const Icon(Icons.bookmark_remove, size: 50),
                                                                              )),
                                                                        ),
                                                                      ])),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  widget
                                                                      .tvList![
                                                                          index]
                                                                      .name!,
                                                                  style: const TextStyle(
                                                                      fontFamily:
                                                                          'PoppinsSB',
                                                                      fontSize:
                                                                          15,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis),
                                                                ),
                                                                Row(
                                                                  children: <Widget>[
                                                                    const Icon(
                                                                      Icons
                                                                          .star,
                                                                    ),
                                                                    Text(
                                                                      widget
                                                                          .tvList![
                                                                              index]
                                                                          .voteAverage!
                                                                          .toStringAsFixed(
                                                                              1),
                                                                      style: const TextStyle(
                                                                          fontFamily:
                                                                              'Poppins'),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      Divider(
                                                        color: themeMode ==
                                                                "light"
                                                            ? Colors.black54
                                                            : Colors.white54,
                                                        thickness: 1,
                                                        endIndent: 20,
                                                        indent: 10,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          })),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
  }
}
