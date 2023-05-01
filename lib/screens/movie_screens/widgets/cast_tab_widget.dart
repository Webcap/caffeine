import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:login/api/movies_api.dart';
import 'package:login/models/credits.dart';
import 'package:login/provider/imagequality_provider.dart';
import 'package:login/provider/settings_provider.dart';
import 'package:login/screens/movie_screens/cast_details.dart';
import 'package:login/screens/movie_screens/crew_detail.dart';
import 'package:login/utils/config.dart';
import 'package:login/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';

class CastTab extends StatefulWidget {
  final Credits credits;
  const CastTab({Key? key, required this.credits}) : super(key: key);

  @override
  CastTabState createState() => CastTabState();
}

class CastTabState extends State<CastTab>
    with AutomaticKeepAliveClientMixin<CastTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    super.build(context);
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return widget.credits.cast!.isEmpty
        ? Container(
            child: const Center(
              child: Text('There is no cast available for this movie'),
            ),
          )
        : Container(
            padding: const EdgeInsets.only(top: 8),
            child: ListView.builder(
                shrinkWrap: false,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.credits.cast!.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return CastDetailPage(
                            cast: widget.credits.cast![index],
                            heroId: '${widget.credits.cast![index].creditId}');
                      }));
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 0.0,
                          bottom: 5.0,
                          left: 10,
                        ),
                        child: Column(
                          children: [
                            Row(
                              // crossAxisAlignment:
                              //     CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 20.0, left: 10),
                                  child: SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: Hero(
                                      tag:
                                          '${widget.credits.cast![index].creditId}',
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        child: widget.credits.cast![index]
                                                    .profilePath ==
                                                null
                                            ? Image.asset(
                                                'assets/images/na_rect.png',
                                                fit: BoxFit.cover,
                                              )
                                            : CachedNetworkImage(
                                                fadeOutDuration: const Duration(
                                                    milliseconds: 300),
                                                fadeOutCurve: Curves.easeOut,
                                                fadeInDuration: const Duration(
                                                    milliseconds: 700),
                                                fadeInCurve: Curves.easeIn,
                                                imageUrl: TMDB_BASE_IMAGE_URL +
                                                    imageQuality +
                                                    widget.credits.cast![index]
                                                        .profilePath!,
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
                                                    castAndCrewTabImageShimmer1(
                                                        isDark),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  'assets/images/na_rect.png',
                                                  fit: BoxFit.cover,
                                                ),
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
                                        widget.credits.cast![index].name!,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontFamily: 'PoppinsSB',
                                            fontSize: 20),
                                      ),
                                      Text(
                                        'As : '
                                        '${widget.credits.cast![index].character!.isEmpty ? 'N/A' : widget.credits.cast![index].character!}',
                                      ),
                                      Visibility(
                                        visible:
                                            widget.credits.cast![0].roles ==
                                                    null
                                                ? false
                                                : true,
                                        child: Text(
                                          widget.credits.cast![0].roles == null
                                              ? ''
                                              : widget
                                                          .credits
                                                          .cast![index]
                                                          .roles![0]
                                                          .episodeCount! ==
                                                      1
                                                  ? '${widget.credits.cast![index].roles![0].episodeCount!} episode'
                                                  : '${widget.credits.cast![index].roles![0].episodeCount!} episodes',
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Divider(
                              color: !isDark ? Colors.black54 : Colors.white54,
                              thickness: 1,
                              endIndent: 20,
                              indent: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }));
  }

  @override
  bool get wantKeepAlive => true;
}

class CrewTab extends StatefulWidget {
  const CrewTab({Key? key, required this.credits}) : super(key: key);
  final Credits credits;

  @override
  CrewTabState createState() => CrewTabState();
}

class CrewTabState extends State<CrewTab>
    with AutomaticKeepAliveClientMixin<CrewTab> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return widget.credits.crew!.isEmpty
        ? Container(
            color: const Color(0xFF000000),
            child: const Center(
              child: Text('There is no data available for this TV show cast'),
            ),
          )
        : Container(
            padding: const EdgeInsets.only(top: 8),
            child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: widget.credits.crew!.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return CrewDetailPage(
                            crew: widget.credits.crew![index],
                            heroId: '${widget.credits.crew![index].creditId}');
                      }));
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 0.0,
                          bottom: 5.0,
                          left: 10,
                        ),
                        child: Column(
                          children: [
                            Row(
                              // crossAxisAlignment:
                              //     CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 20.0, left: 10),
                                  child: SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: Hero(
                                      tag:
                                          '${widget.credits.crew![index].creditId}',
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        child: widget.credits.crew![index]
                                                    .profilePath ==
                                                null
                                            ? Image.asset(
                                                'assets/images/na_rect.png',
                                                fit: BoxFit.cover,
                                              )
                                            : CachedNetworkImage(
                                                fadeOutDuration: const Duration(
                                                    milliseconds: 300),
                                                fadeOutCurve: Curves.easeOut,
                                                fadeInDuration: const Duration(
                                                    milliseconds: 700),
                                                fadeInCurve: Curves.easeIn,
                                                imageUrl: TMDB_BASE_IMAGE_URL +
                                                    imageQuality +
                                                    widget.credits.crew![index]
                                                        .profilePath!,
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
                                                    castAndCrewTabImageShimmer1(
                                                        isDark),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  'assets/images/na_rect.png',
                                                  fit: BoxFit.cover,
                                                ),
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
                                        widget.credits.crew![index].name!,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontFamily: 'PoppinsSB',
                                            fontSize: 20),
                                      ),
                                      Text(
                                        'Job : '
                                        '${widget.credits.crew![index].department!.isEmpty ? 'N/A' : widget.credits.crew![index].department!}',
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Divider(
                              color: !isDark ? Colors.black54 : Colors.white54,
                              thickness: 1,
                              endIndent: 20,
                              indent: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          );
  }

  @override
  bool get wantKeepAlive => true;
}

