import 'package:cached_network_image/cached_network_image.dart';
import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/models/tv.dart';
import 'package:reelriot/screens/tv_screens/tv_detail_page.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/widgets/shimmer_widget.dart';
import 'package:reelriot/utils/constant.dart';
import 'package:provider/provider.dart';

class TVListView extends StatelessWidget {
  const TVListView({
    super.key,
    required ScrollController scrollController,
    required this.tvList,
    required this.themeMode,
    required this.imageQuality,
    this.heroPrefix = 'tv',
  }) : _scrollController = scrollController;

  final ScrollController _scrollController;
  final List<TV>? tvList;
  final String themeMode;
  final String imageQuality;
  final String heroPrefix;

  @override
  Widget build(BuildContext context) {
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        itemCount: tvList!.length,
        itemBuilder: (BuildContext context, int index) {
          final heroId = '${heroPrefix}_${tvList![index].id}';
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return TVDetailPage(
                  tvSeries: tvList![index],
                  heroId: heroId,
                );
              }));
            },
            child: Container(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 0.0,
                  bottom: 3.0,
                  left: 10,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: SizedBox(
                            width: 85,
                            height: 130,
                            child: Hero(
                              tag: heroId,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: tvList![index].posterPath == null
                                    ? Image.asset(
                                        'assets/images/na_logo.png',
                                        fit: BoxFit.cover,
                                      )
                                    : CachedNetworkImage(
                                        cacheManager: cacheProp(),
                                        fadeOutDuration:
                                            const Duration(milliseconds: 300),
                                        fadeOutCurve: Curves.easeOut,
                                        fadeInDuration:
                                            const Duration(milliseconds: 700),
                                        fadeInCurve: Curves.easeIn,
                                        imageUrl: buildImageUrl(
                                                tmdbBaseImageUrl,
                                                proxyUrl,
                                                isProxyEnabled,
                                                context) +
                                            imageQuality +
                                            tvList![index].posterPath!,
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
                                            mainPageVerticalScrollImageShimmer(
                                                themeMode),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                          'assets/images/na_logo.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tvList![index].name!,
                                style: const TextStyle(
                                    fontFamily: 'PoppinsSB',
                                    fontSize: 15,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.star_rounded,
                                  ),
                                  Text(
                                    tvList![index]
                                        .voteAverage!
                                        .toStringAsFixed(1),
                                    style:
                                        const TextStyle(fontFamily: 'Poppins'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Divider(
                      color: themeMode == "light"
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
        });
  }
}
