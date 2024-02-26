import 'package:cached_network_image/cached_network_image.dart';
import 'package:caffiene/functions/functions.dart';
import 'package:caffiene/functions/network.dart';
import 'package:caffiene/models/images.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/common/photoview.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/widgets/common_widgets.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caffiene/utils/constant.dart';


class TVSeasonImagesDisplay extends StatefulWidget {
  final String? api, title, name;
  const TVSeasonImagesDisplay({Key? key, this.api, this.name, this.title})
      : super(key: key);

  @override
  TVSeasonImagesDisplayState createState() => TVSeasonImagesDisplayState();
}

class TVSeasonImagesDisplayState extends State<TVSeasonImagesDisplay> {
  Images? tvImages;
  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchImages(widget.api!, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          tvImages = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return Column(
      children: [
        tvImages == null
            ? Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const LeadingDot(),
                          Expanded(
                            child: Text(widget.title!,
                                style:
                                    kTextHeaderStyle /* style: widget.themeData!.textTheme.bodyText1*/
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const LeadingDot(),
                          Expanded(
                            child: Text(widget.title!,
                                style:
                                    kTextHeaderStyle /*style: widget.themeData!.textTheme.bodyText1*/
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        Container(
          child: SizedBox(
            width: double.infinity,
            height: 200,
            child: tvImages == null
                ? detailImageShimmer(themeMode)
                : CarouselSlider(
                    options: CarouselOptions(
                      disableCenter: false,
                      viewportFraction: 0.4,
                      enlargeCenterPage: false,
                      autoPlay: false,
                      enableInfiniteScroll: false,
                    ),
                    items: [
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            alignment: Alignment.bottomLeft,
                            children: [
                              SizedBox(
                                width: 125,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: tvImages!.poster!.isEmpty
                                      ? Image.asset('assets/images/na_logo.png',
                                          fit: BoxFit.cover,
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
                                              tvImages!.poster![0].posterPath!,
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  GestureDetector(
                                            onTap: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return HeroPhotoView(
                                                  posters: tvImages!.poster!,
                                                  name: widget.name,
                                                  imageType: 'poster',
                                                );
                                              }));
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          placeholder: (context, url) =>
                                              scrollingImageShimmer(themeMode),
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                                  'assets/images/na_logo.png',
                                                  fit: BoxFit.cover,
                                                  height: double.infinity),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  color: Colors.black38,
                                  child: Text(tvImages!.poster!.length == 1
                                      ? tr("poster_singular", namedArgs: {
                                          "poster": tvImages!.poster!.length
                                              .toString()
                                        })
                                      : tr("poster_plural", namedArgs: {
                                          "poster": tvImages!.poster!.length
                                              .toString()
                                        })),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
