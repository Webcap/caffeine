import 'package:cached_network_image/cached_network_image.dart';
import 'package:caffiene/functions/functions.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/models/tv.dart';
import 'package:caffiene/screens/tv_screens/tv_detail_page.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:caffiene/utils/constant.dart';
import 'package:provider/provider.dart';

class TVGridView extends StatelessWidget {
  const TVGridView({
    Key? key,
    required this.tvList,
    required this.imageQuality,
    required this.themeMode,
    required this.scrollController,
  }) : super(key: key);

  final List<TV>? tvList;
  final String imageQuality;
  final String themeMode;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return GridView.builder(
        controller: scrollController,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
          childAspectRatio: 0.48,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
        itemCount: tvList!.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return TVDetailPage(
                    tvSeries: tvList![index], heroId: '${tvList![index].id}');
              }));
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  Expanded(
                    flex: 6,
                    child: Hero(
                      tag: '${tvList![index].id}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: tvList![index].posterPath == null
                                  ? Image.asset('assets/images/na_logo.png',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity)
                                  : CachedNetworkImage(
                                      cacheManager: cacheProp(),
                                      fadeOutDuration:
                                          const Duration(milliseconds: 300),
                                      fadeOutCurve: Curves.easeOut,
                                      fadeInDuration:
                                          const Duration(milliseconds: 700),
                                      fadeInCurve: Curves.easeIn,
                                      imageUrl: buildImageUrl(
                                              TMDB_BASE_IMAGE_URL,
                                              proxyUrl,
                                              isProxyEnabled,
                                              context) +
                                          imageQuality +
                                          tvList![index].posterPath!,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      placeholder: (context, url) =>
                                          scrollingImageShimmer(themeMode),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                              'assets/images/na_logo.png',
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity),
                                    ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                margin: const EdgeInsets.all(3),
                                alignment: Alignment.topLeft,
                                width: 50,
                                height: 25,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: themeMode == "dark" ||
                                            themeMode == "amoled"
                                        ? Colors.black45
                                        : Colors.white60),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                    ),
                                    Text(tvList![index]
                                        .voteAverage!
                                        .toStringAsFixed(1))
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Expanded(
                      flex: 2,
                      child: Text(
                        tvList![index].name!,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )),
                ],
              ),
            ),
          );
        });
  }
}
