import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/widgets/cached_image.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/models/tv.dart';
import 'package:reelriot/screens/tv_screens/tv_detail_page.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/widgets/shimmer_widget.dart';
import 'package:reelriot/utils/constant.dart';
import 'package:provider/provider.dart';

class TVGridView extends StatelessWidget {
  const TVGridView({
    super.key,
    required this.tvList,
    required this.imageQuality,
    required this.themeMode,
    required this.scrollController,
    this.heroPrefix = 'tv',
  });

  final List<TV>? tvList;
  final String imageQuality;
  final String themeMode;
  final ScrollController scrollController;
  final String heroPrefix;

  @override
  Widget build(BuildContext context) {
    final isProxyEnabled = context.read<SettingsProvider>().enableProxy;
    final proxyUrl = context.read<AppDependencyProvider>().tmdbProxy;
    return GridView.builder(
      controller: scrollController,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150,
        childAspectRatio: 0.48,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemCount: tvList!.length,
      itemBuilder: (BuildContext context, int index) => TVGridItem(
        tv: tvList![index],
        imageQuality: imageQuality,
        themeMode: themeMode,
        proxyUrl: proxyUrl,
        isProxyEnabled: isProxyEnabled,
        heroPrefix: heroPrefix,
      ),
    );
  }
}

/// Extracted grid item to avoid parent rebuilds triggering all items.
class TVGridItem extends StatelessWidget {
  const TVGridItem({
    super.key,
    required this.tv,
    required this.imageQuality,
    required this.themeMode,
    required this.proxyUrl,
    required this.isProxyEnabled,
    this.heroPrefix = 'tv',
  });

  final TV tv;
  final String imageQuality;
  final String themeMode;
  final String proxyUrl;
  final bool isProxyEnabled;
  final String heroPrefix;

  @override
  Widget build(BuildContext context) {
    final heroId = '${heroPrefix}_${tv.id}';
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return TVDetailPage(tvSeries: tv, heroId: heroId);
        }));
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: Hero(
                tag: heroId,
                child: Material(
                  type: MaterialType.transparency,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: tv.posterPath == null
                            ? Image.asset('assets/images/na_logo.png',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity)
                            : CachedPosterImage(
                                cacheManager: cacheProp(),
                                imageUrl: buildImageUrl(TMDB_BASE_IMAGE_URL,
                                        proxyUrl, isProxyEnabled, context) +
                                    imageQuality +
                                    tv.posterPath!,
                                themeMode: themeMode,
                                placeholder: (context, url) =>
                                    scrollingImageShimmer(themeMode),
                                errorWidget: (context, url, error) =>
                                    Image.asset('assets/images/na_logo.png',
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
                              color:
                                  themeMode == "dark" || themeMode == "amoled"
                                      ? Colors.black45
                                      : Colors.white60),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                              ),
                              Text(tv.voteAverage!.toStringAsFixed(1))
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
                  tv.name!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )),
          ],
        ),
      ),
    );
  }
}
