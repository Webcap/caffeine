import 'package:reelriot/functions/network.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/widgets/common_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reelriot/models/movie_models.dart';
import 'package:reelriot/models/social_icons_icons.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';
import 'package:reelriot/utils/constant.dart';

class MovieSocialLinks extends StatefulWidget {
  final String? api;
  const MovieSocialLinks({
    super.key,
    this.api,
  });

  @override
  MovieSocialLinksState createState() => MovieSocialLinksState();
}

class MovieSocialLinksState extends State<MovieSocialLinks> {
  ExternalLinks? externalLinks;
  bool? isAllNull;
  @override
  void initState() {
    super.initState();
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
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const LeadingDot(),
                Expanded(
                  child: Text(
                    tr("social_media_links"),
                    style: kTextHeaderStyle,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 55,
              width: double.infinity,
              child: externalLinks == null
                  ? socialMediaShimmer(themeMode)
                  : externalLinks?.facebookUsername == null &&
                          externalLinks?.instagramUsername == null &&
                          externalLinks?.twitterUsername == null &&
                          externalLinks?.imdbId == null
                      ? Center(
                          child: Text(
                            tr("no_social_link_movie"),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: themeMode == "dark" || themeMode == "amoled"
                                ? Colors.transparent
                                : const Color(0xFFDFDEDE),
                          ),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              SocialIconWidget(
                                isNull: externalLinks?.facebookUsername == null,
                                url: externalLinks?.facebookUsername == null
                                    ? ''
                                    : facebookBaseUrl +
                                        externalLinks!.facebookUsername!,
                                icon: const Icon(
                                  SocialIcons.facebook_f,
                                ),
                              ),
                              SocialIconWidget(
                                isNull:
                                    externalLinks?.instagramUsername == null,
                                url: externalLinks?.instagramUsername == null
                                    ? ''
                                    : instagramBaseUrl +
                                        externalLinks!.instagramUsername!,
                                icon: const Icon(
                                  SocialIcons.instagram,
                                ),
                              ),
                              SocialIconWidget(
                                isNull: externalLinks?.twitterUsername == null,
                                url: externalLinks?.twitterUsername == null
                                    ? ''
                                    : twitterBaseUrl +
                                        externalLinks!.twitterUsername!,
                                icon: const Icon(
                                  SocialIcons.twitter,
                                ),
                              ),
                              SocialIconWidget(
                                isNull: externalLinks?.imdbId == null,
                                url: externalLinks?.imdbId == null
                                    ? ''
                                    : imdbBaseUrl + externalLinks!.imdbId!,
                                icon: const Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.imdb,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
