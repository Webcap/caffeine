import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/widgets/cached_image.dart';
import 'package:reelriot/functions/network.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/utils/constant.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/models/movie_models.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

// Design tokens for streaming service cards (design.json)
const _wpBgSurfaceDark = Color(0xFF0B0F14);
const _wpBgSurfaceLight = Color(0xFFFFFFFF);
const _wpTextPrimDark = Color(0xFFFFFFFF);
const _wpTextPrimLight = Color(0xFF0B0F14);
const _wpTextSecDark = Color(0xB8FFFFFF);
const _wpTextSecLight = Color(0xFF64748B);
const _wpBorderDark = Color(0x14FFFFFF);
const _wpBorderLight = Color(0x140F172A);
const _wpRadiusMd = 16.0;
const _wpSpace = 8.0;
const _wpSpace2 = 12.0;
const _wpShadowCard = BoxShadow(
  color: Color(0x38000000),
  blurRadius: 30,
  offset: Offset(0, 10),
);

Widget watchProvidersTabData(
    {required String themeMode,
    required String imageQuality,
    required String noOptionMessage,
    required List? watchOptions,
    required BuildContext context}) {
  final isProxyEnabled = context.read<SettingsProvider>().enableProxy;
  final proxyUrl = context.read<AppDependencyProvider>().tmdbProxy;
  final isDark = themeMode == 'dark' || themeMode == 'amoled';
  final textPrim = isDark ? _wpTextPrimDark : _wpTextPrimLight;
  final textSec = isDark ? _wpTextSecDark : _wpTextSecLight;
  final surface = isDark ? _wpBgSurfaceDark : _wpBgSurfaceLight;
  final border = isDark ? _wpBorderDark : _wpBorderLight;

  return Padding(
    padding: const EdgeInsets.all(_wpSpace2),
    child: watchOptions == null
        ? Center(
            child: Text(
              noOptionMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textSec,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        : GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 112,
              childAspectRatio: 0.72,
              crossAxisSpacing: _wpSpace2,
              mainAxisSpacing: _wpSpace2,
            ),
            itemCount: watchOptions.length,
            itemBuilder: (BuildContext context, int index) {
              final option = watchOptions[index];
              final imageUrl = option.logoPath == null
                  ? null
                  : buildImageUrl(TMDB_BASE_IMAGE_URL, proxyUrl, isProxyEnabled,
                          context) +
                      imageQuality +
                      option.logoPath!;
              return _StreamingServiceCard(
                surface: surface,
                border: border,
                textPrim: textPrim,
                themeMode: themeMode,
                providerName: option.providerName!,
                imageUrl: imageUrl,
              );
            },
          ),
  );
}

class _StreamingServiceCard extends StatelessWidget {
  final Color surface;
  final Color border;
  final Color textPrim;
  final String themeMode;
  final String providerName;
  final String? imageUrl;

  const _StreamingServiceCard({
    required this.surface,
    required this.border,
    required this.textPrim,
    required this.themeMode,
    required this.providerName,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(_wpRadiusMd),
        border: Border.all(color: border),
        boxShadow: const [_wpShadowCard],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(_wpRadiusMd - 1),
              ),
              child: imageUrl == null
                  ? Image.asset(
                      'assets/images/na_logo.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : CachedPosterImage(
                      cacheManager: cacheProp(),
                      preset: CachePreset.logo,
                      imageUrl: imageUrl!,
                      themeMode: themeMode,
                      placeholder: (context, url) =>
                          watchProvidersImageShimmer(themeMode),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/na_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(_wpSpace, 6, _wpSpace, _wpSpace),
            child: Text(
              providerName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textPrim,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DidYouKnow extends StatefulWidget {
  const DidYouKnow({super.key, required this.api});

  final String? api;

  @override
  State<DidYouKnow> createState() => _DidYouKnowState();
}

class _DidYouKnowState extends State<DidYouKnow> {
  ExternalLinks? externalLinks;

  @override
  void initState() {
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;

    fetchSocialLinks(widget.api!, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          externalLinks = value;
        });
      }
    });
    super.initState();
  }

  // void navToDYK(String dataType, String dataName, String imdbId) {
  //   Navigator.push(context, MaterialPageRoute(builder: ((context) {
  //     return DidYouKnowScreen(
  //       dataType: dataType,
  //       dataName: dataName,
  //       imdbId: imdbId,
  //     );
  //   })));
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Did You Know',
            style: kTextHeaderStyle,
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
              child: externalLinks == null
                  ? const Center(child: CircularProgressIndicator())
                  : externalLinks!.imdbId == null ||
                          externalLinks!.imdbId!.isEmpty
                      ? const Center(
                          child: Text(
                          'This movie doesn\'t have IMDB id therefore additional data can\'t be fetched.',
                          textAlign: TextAlign.center,
                        ))
                      : const Wrap(
                          spacing: 5,
                          // children: [
                          //   ElevatedButton(
                          //     onPressed: () {
                          //       navToDYK(
                          //           'trivia', 'Trivia', externalLinks!.imdbId!);
                          //     },
                          //     child: const Text('Trivia'),
                          //   ),
                          //   ElevatedButton(
                          //     onPressed: () {
                          //       navToDYK(
                          //           'quotes', 'Quotes', externalLinks!.imdbId!);
                          //     },
                          //     child: const Text('Quotes'),
                          //   ),
                          //   ElevatedButton(
                          //     onPressed: () {
                          //       navToDYK(
                          //           'goofs', 'Goofs', externalLinks!.imdbId!);
                          //     },
                          //     child: const Text('Goofs'),
                          //   ),
                          //   ElevatedButton(
                          //     onPressed: () {
                          //       navToDYK('crazycredits', 'Crazy Credits',
                          //           externalLinks!.imdbId!);
                          //     },
                          //     child: const Text('Crazy Credits'),
                          //   ),
                          //   ElevatedButton(
                          //     onPressed: () {
                          //       navToDYK(
                          //           'alternateversions',
                          //           'Alternate Versions',
                          //           externalLinks!.imdbId!);
                          //     },
                          //     child: const Text('Alternate Versions'),
                          //   ),
                          //   ElevatedButton(
                          //     onPressed: () {
                          //       navToDYK('soundtrack', 'Soundtrack',
                          //           externalLinks!.imdbId!);
                          //     },
                          //     child: const Text('Soundtrack'),
                          //   ),
                          //   ElevatedButton(
                          //     onPressed: () {
                          //       Navigator.push(context,
                          //           MaterialPageRoute(builder: ((context) {
                          //         return TitleReviews(
                          //             imdbId: externalLinks!.imdbId!);
                          //       })));
                          //     },
                          //     child: const Text('Reviews'),
                          //   ),
                          // ],
                        )),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}

class ShimmerBase extends StatelessWidget {
  const ShimmerBase({super.key, required this.child, required this.themeMode});

  final Widget child;
  final String themeMode;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: themeMode == "dark" || themeMode == "amoled"
          ? Colors.grey.shade900
          : Colors.grey.shade300,
      highlightColor: themeMode == "dark" || themeMode == "amoled"
          ? Colors.grey.shade800.withOpacity(0.1)
          : Colors.grey.shade200,
      child: child,
    );
  }
}

class LeadingDot extends StatelessWidget {
  const LeadingDot({super.key});

  @override
  Widget build(BuildContext context) {
    String appLang = Provider.of<SettingsProvider>(context).appLanguage;
    return Container(
      color: Theme.of(context).primaryColor,
      width: 10,
      height: 25,
      margin: appLang == 'ar'
          ? const EdgeInsets.only(left: 8)
          : const EdgeInsets.only(right: 8),
    );
  }
}

class SocialIconWidget extends StatelessWidget {
  const SocialIconWidget({
    super.key,
    this.url,
    this.icon,
    this.isNull,
  });

  final String? url;
  final Widget? icon;
  final bool? isNull;

  @override
  Widget build(BuildContext context) {
    return isNull == true
        ? Container()
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                launchUrl(Uri.parse(url!),
                    mode: LaunchMode.externalApplication);
              },
              child: Container(
                height: 50,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                ),
                child: icon,
              ),
            ),
          );
  }
}
