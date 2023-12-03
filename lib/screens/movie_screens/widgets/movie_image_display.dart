import 'package:cached_network_image/cached_network_image.dart';
import 'package:caffiene/screens/common/photoview.dart';
import 'package:caffiene/widgets/common_widgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/movies_api.dart';
import 'package:caffiene/models/images.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';
import 'package:caffiene/utils/constant.dart';


class MovieImagesDisplay extends StatefulWidget {
  final String? api, title, name;
  const MovieImagesDisplay({Key? key, this.api, this.name, this.title})
      : super(key: key);

  @override
  MovieImagesState createState() => MovieImagesState();
}

class MovieImagesState extends State<MovieImagesDisplay> {
  Images? movieImages;
  @override
  void initState() {
    super.initState();
    moviesApi().fetchImages(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          movieImages = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return SizedBox(
      height: 260,
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const LeadingDot(),
                      Expanded(
                        child: Text(
                          widget.title!,
                          style:
                              kTextHeaderStyle, /*style: widget.themeData!.textTheme.bodyText1*/
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              height: 220,
              child: movieImages == null
                  ? detailImageShimmer(themeMode)
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          enableInfiniteScroll: false,
                          viewportFraction: 1,
                        ),
                        items: [
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  child: movieImages!.poster!.isEmpty
                                      ? SizedBox(
                                          width: 120,
                                          height: 180,
                                          child: Center(
                                            child: Image.asset(
                                              'assets/images/na_logo.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Stack(
                                                alignment: AlignmentDirectional
                                                    .bottomStart,
                                                children: [
                                                  SizedBox(
                                                    height: 180,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      child: movieImages!
                                                                  .poster![0]
                                                                  .posterPath ==
                                                              null
                                                          ? Image.asset(
                                                              'assets/images/na_logo.png',
                                                              fit: BoxFit.cover,
                                                            )
                                                          : CachedNetworkImage(
                                                              cacheManager:
                                                                  cacheProp(),
                                                              fadeOutDuration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          300),
                                                              fadeOutCurve:
                                                                  Curves
                                                                      .easeOut,
                                                              fadeInDuration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          700),
                                                              fadeInCurve:
                                                                  Curves.easeIn,
                                                              imageUrl: TMDB_BASE_IMAGE_URL +
                                                                  imageQuality +
                                                                  movieImages!
                                                                      .poster![
                                                                          0]
                                                                      .posterPath!,
                                                              imageBuilder: (context,
                                                                      imageProvider) =>
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder:
                                                                              ((context) {
                                                                    return HeroPhotoView(
                                                                      posters:
                                                                          movieImages!
                                                                              .poster!,
                                                                      name: widget
                                                                          .name,
                                                                      imageType:
                                                                          'poster',
                                                                    );
                                                                  })));
                                                                },
                                                                child: Hero(
                                                                  tag: TMDB_BASE_IMAGE_URL +
                                                                      imageQuality +
                                                                      movieImages!
                                                                          .poster![
                                                                              0]
                                                                          .posterPath!,
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      image:
                                                                          DecorationImage(
                                                                        image:
                                                                            imageProvider,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              placeholder: (context,
                                                                      url) =>
                                                                  detailImageImageSimmer(
                                                                      themeMode),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  Image.asset(
                                                                'assets/images/na_logo.png',
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      color: Colors.black38,
                                                      child: Text(movieImages!
                                                                  .poster!
                                                                  .length ==
                                                              1
                                                          ? tr(
                                                              "poster_singular",
                                                              namedArgs: {
                                                                  "poster": movieImages!
                                                                      .poster!
                                                                      .length
                                                                      .toString()
                                                                })
                                                          : tr("poster_plural",
                                                              namedArgs: {
                                                                  "poster": movieImages!
                                                                      .poster!
                                                                      .length
                                                                      .toString()
                                                                })),
                                                    ),
                                                  )
                                                ]),
                                          ),
                                        ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  child: movieImages!.backdrop!.isEmpty
                                      ? SizedBox(
                                          width: 120,
                                          height: 180,
                                          child: Center(
                                            child: Image.asset(
                                              'assets/images/na_logo.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Stack(
                                                alignment: AlignmentDirectional
                                                    .bottomStart,
                                                children: [
                                                  SizedBox(
                                                    height: 180,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      child: movieImages!
                                                                  .backdrop![0]
                                                                  .filePath ==
                                                              null
                                                          ? Image.asset(
                                                              'assets/images/na_logo.png',
                                                              fit: BoxFit.cover,
                                                            )
                                                          : CachedNetworkImage(
                                                              cacheManager:
                                                                  cacheProp(),
                                                              fadeOutDuration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          300),
                                                              fadeOutCurve:
                                                                  Curves
                                                                      .easeOut,
                                                              fadeInDuration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          700),
                                                              fadeInCurve:
                                                                  Curves.easeIn,
                                                              imageUrl: TMDB_BASE_IMAGE_URL +
                                                                  imageQuality +
                                                                  movieImages!
                                                                      .backdrop![
                                                                          0]
                                                                      .filePath!,
                                                              imageBuilder: (context,
                                                                      imageProvider) =>
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder:
                                                                              ((context) {
                                                                    return HeroPhotoView(
                                                                      backdrops:
                                                                          movieImages!
                                                                              .backdrop!,
                                                                      name: widget
                                                                          .name,
                                                                      imageType:
                                                                          'backdrop',
                                                                    );
                                                                  })));
                                                                },
                                                                child: Hero(
                                                                  tag: TMDB_BASE_IMAGE_URL +
                                                                      imageQuality +
                                                                      movieImages!
                                                                          .backdrop![
                                                                              0]
                                                                          .filePath!,
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      image:
                                                                          DecorationImage(
                                                                        image:
                                                                            imageProvider,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              placeholder: (context,
                                                                      url) =>
                                                                  detailImageImageSimmer(
                                                                      themeMode),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  Image.asset(
                                                                'assets/images/na_logo.png',
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      color: Colors.black38,
                                                      child: Text(movieImages!
                                                                  .backdrop!
                                                                  .length ==
                                                              1
                                                          ? tr(
                                                              "backdrop_singular",
                                                              namedArgs: {
                                                                  "backdrop": movieImages!
                                                                      .backdrop!
                                                                      .length
                                                                      .toString()
                                                                })
                                                          : tr(
                                                              "backdrop_plural",
                                                              namedArgs: {
                                                                  "backdrop": movieImages!
                                                                      .backdrop!
                                                                      .length
                                                                      .toString()
                                                                })),
                                                    ),
                                                  )
                                                ]),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
