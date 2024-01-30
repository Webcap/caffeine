import 'package:cached_network_image/cached_network_image.dart';
import 'package:caffiene/screens/movie_screens/widgets/castButton.dart';
import 'package:caffiene/utils/app_colors.dart';
import 'package:caffiene/utils/helpers/castDeviceList.dart';
import 'package:caffiene/widgets/size_configuration.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/models/movie_models.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:caffiene/utils/constant.dart';

class MovieDetailQuickInfo extends StatelessWidget {
  const MovieDetailQuickInfo({
    Key? key,
    required this.movie,
    required this.heroId,
  }) : super(key: key);

  final Movie movie;
  final String heroId;

  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final appLang = Provider.of<SettingsProvider>(context).appLanguage;
    return SizedBox(
      height: 310,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black,
                        Colors.black,
                        Colors.black,
                        Colors.transparent
                      ],
                    ).createShader(
                        Rect.fromLTRB(0, 0, rect.width, rect.height));
                  },
                  blendMode: BlendMode.dstIn,
                  child: Container(
                    decoration: const BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: Colors.transparent)),
                    ),
                    child: SizedBox(
                      height: 220,
                      child: Stack(
                        children: [
                          PageView.builder(
                            itemBuilder: (context, index) {
                              return movie.backdropPath == null
                                  ? Image.asset(
                                      'assets/images/na_logo.png',
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      cacheManager: cacheProp(),
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          Image.asset(
                                        'assets/images/loading_5.gif',
                                        fit: BoxFit.cover,
                                      ),
                                      imageUrl:
                                          '${TMDB_BASE_IMAGE_URL}original/${movie.backdropPath!}',
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        'assets/images/na_logo.png',
                                        fit: BoxFit.cover,
                                      ),
                                    );
                            },
                          ),
                          Positioned(
                            top: -10,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: SafeArea(
                              child: Container(
                                alignment: appLang == 'ar'
                                    ? Alignment.topLeft
                                    : Alignment.topRight,
                                child: GestureDetector(child: CastButton(
                                  onTap: () {
                                    Get.bottomSheet(
                                        backgroundColor: themeMode == "dark" ||
                                                themeMode == "amoled"
                                            ? Colors.white
                                            : Colors.black,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(40),
                                            topLeft: Radius.circular(40),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                            left:
                                                SizeConfig.blockSizeHorizontal *
                                                    3,
                                            right:
                                                SizeConfig.blockSizeHorizontal *
                                                    3,
                                          ),
                                          height: SizeConfig.screenHeight / 3,
                                          decoration: BoxDecoration(
                                            color: themeMode == "dark" ||
                                                    themeMode == "amoled"
                                                ? ColorValues.darkmodesecond
                                                : ColorValues.whiteColor,
                                            borderRadius:
                                                const BorderRadius.only(
                                              topRight: Radius.circular(45),
                                              topLeft: Radius.circular(45),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Container(
                                                width: SizeConfig
                                                        .blockSizeHorizontal *
                                                    13,
                                                height: 5,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(60),
                                                  color: ColorValues.boxColor,
                                                ),
                                              ),
                                              Text(
                                                "Connect a Device",
                                                style: GoogleFonts.urbanist(
                                                  fontSize: 22,
                                                  color: ColorValues.redColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const Divider(
                                                color: Colors.grey,
                                                // thickness: 1.0,
                                                indent: 15,
                                                endIndent: 15,
                                              ),
                                              SizedBox(
                                                height: SizeConfig.blockSizeVertical * 0.06,
                                              ),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  CastDeviceList()
                                                ],
                                              )
                                            ],
                                          ),
                                        ));
                                  },
                                )
                                    // child: WatchProvidersButton(
                                    //   api: Endpoints.getMovieWatchProviders(
                                    //       movie.id!, appLang),
                                    //   country: watchCountry,
                                    //   onTap: () {
                                    // showModalBottomSheet(
                                    //       context: context,
                                    //       builder: (builder) {
                                    //         return WatchProvidersDetails(
                                    //           api: Endpoints
                                    //               .getMovieWatchProviders(
                                    //                   movie.id!, appLang),
                                    //           country: watchCountry,
                                    //         );
                                    //       },
                                    //     );
                                    //   },
                                    // ),
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // poster and title movie details
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
                    tag: heroId,
                    child: Material(
                      type: MaterialType.transparency,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 94,
                                height: 140,
                                child: movie.posterPath == null
                                    ? Image.asset(
                                        'assets/images/na_logo.png',
                                        fit: BoxFit.cover,
                                      )
                                    : CachedNetworkImage(
                                        cacheManager: cacheProp(),
                                        fit: BoxFit.fill,
                                        placeholder: (context, url) =>
                                            scrollingImageShimmer(themeMode),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                          'assets/images/na_logo.png',
                                          fit: BoxFit.cover,
                                        ),
                                        imageUrl: TMDB_BASE_IMAGE_URL +
                                            imageQuality +
                                            movie.posterPath!,
                                      ),
                              ),
                            ),
                          )),
                    ),
                  ),
                  const SizedBox(width: 16),
                  //  titles
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {
                            // _utilityController.toggleTitleVisibility();
                          },
                          child: Text(
                            movie.releaseDate == null
                                ? movie.title!
                                : movie.releaseDate == ""
                                    ? movie.title!
                                    : '${movie.title!} (${DateTime.parse(movie.releaseDate!).year})',
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 18, fontFamily: 'PoppinsSB'),
                          ),
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
