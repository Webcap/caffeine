import 'package:cached_network_image/cached_network_image.dart';
import 'package:caffiene/functions/functions.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/search/searched_person.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';
import 'package:caffiene/utils/constant.dart';

class SearchedPersonQuickInfo extends StatelessWidget {
  const SearchedPersonQuickInfo({
    Key? key,
    required this.widget,
    required this.imageQuality,
  }) : super(key: key);

  final SearchedPersonDetailPage widget;
  final String imageQuality;
  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          Positioned(
            bottom: 0.0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  // poster
                  Hero(
                    tag: widget.heroId,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(150),
                            child: SizedBox(
                              width: 120,
                              height: 120,
                              child: widget.person!.profilePath == null
                                  ? Image.asset(
                                      'assets/images/na_logo.png',
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      cacheManager: cacheProp(),
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          scrollingImageShimmer(themeMode),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        'assets/images/na_logo.png',
                                        fit: BoxFit.cover,
                                      ),
                                      imageUrl: buildImageUrl(
                                              TMDB_BASE_IMAGE_URL,
                                              proxyUrl,
                                              isProxyEnabled,
                                              context) +
                                          imageQuality +
                                          widget.person!.profilePath!,
                                    ),
                            ),
                          ),
                        )),
                  ),
                  const SizedBox(width: 16),
                  //  titles
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.person!.name!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 25, fontFamily: 'PoppinsSB'),
                        ),
                        Text(
                          widget.person!.department!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15, fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
