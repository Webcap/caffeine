import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/widgets/cached_image.dart';
import 'package:reelriot/models/tv.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/tv_screens/tv_detail_page.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/utils/constant.dart';
import 'package:provider/provider.dart';

class HorizontalScrollingTVList extends StatelessWidget {
  const HorizontalScrollingTVList({
    super.key,
    required ScrollController scrollController,
    required this.tvList,
    required this.imageQuality,
    required this.themeMode,
    this.heroPrefix = 'tv',
  }) : _scrollController = scrollController;

  final ScrollController _scrollController;
  final List<TV>? tvList;
  final String imageQuality;
  final String themeMode;
  final String heroPrefix;

  @override
  Widget build(BuildContext context) {
    final isProxyEnabled = context.read<SettingsProvider>().enableProxy;
    final proxyUrl = context.read<AppDependencyProvider>().tmdbProxy;
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: tvList!.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) => HorizontalTVListItem(
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

/// Extracted list item to avoid parent rebuilds triggering all items.
class HorizontalTVListItem extends StatelessWidget {
  const HorizontalTVListItem({
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
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final cardWidth = isTablet ? 140.0 : 115.0;
    final posterHeight = cardWidth * 1.5;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 6.0 : 4.0,
        vertical: 2.0,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      TVDetailPage(tvSeries: tv, heroId: heroId)));
        },
        child: SizedBox(
          width: cardWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: cardWidth,
                height: posterHeight,
                child: Hero(
                  tag: heroId,
                  child: Material(
                    type: MaterialType.transparency,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
                          child: tv.posterPath == null
                              ? Image.asset('assets/images/na_logo.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity)
                              : CachedPosterImage(
                                  cacheManager: cacheProp(),
                                  imageUrl: tv.posterPath == null
                                      ? ''
                                      : buildImageUrl(
                                              tmdbBaseImageUrl,
                                              proxyUrl,
                                              isProxyEnabled,
                                              context) +
                                          imageQuality +
                                          tv.posterPath!,
                                  themeMode: themeMode,
                                  placeholder: (context, url) =>
                                      scrollingImageShimmer(themeMode),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    'assets/images/na_logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        if (tv.voteAverage != null)
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.black.withValues(alpha: 0.65)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 11,
                                    color: Color(0xFFFACC15),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    (tv.voteAverage ?? 0.0).toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 6, 2, 0),
                child: Text(
                  tv.name ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
