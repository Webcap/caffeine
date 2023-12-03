import 'package:cached_network_image/cached_network_image.dart';
import 'package:caffiene/api/movies_api.dart';
import 'package:caffiene/models/images.dart';
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
    moviesApi().fetchImages(widget.api!).then((value) {
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
                : tvImages!.poster!.isEmpty
                    ? SizedBox(
                        width: double.infinity,
                        height: 130,
                        child: Center(
                          child: Text(
                            tr("no_season_image"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : CarouselSlider(
                        options: CarouselOptions(
                          disableCenter: true,
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
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: CachedNetworkImage(
                                      cacheManager: cacheProp(),
                                      fadeOutDuration:
                                          const Duration(milliseconds: 300),
                                      fadeOutCurve: Curves.easeOut,
                                      fadeInDuration:
                                          const Duration(milliseconds: 700),
                                      fadeInCurve: Curves.easeIn,
                                      imageUrl: TMDB_BASE_IMAGE_URL +
                                          imageQuality +
                                          tvImages!.poster![0].posterPath!,
                                      imageBuilder: (context, imageProvider) =>
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
