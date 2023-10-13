import 'package:cached_network_image/cached_network_image.dart';
import 'package:caffiene/models/watch_providers.dart';
import 'package:caffiene/widgets/common_widgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/api/movies_api.dart';
import 'package:caffiene/api/tv_api.dart';
import 'package:caffiene/models/credits.dart';
import 'package:caffiene/models/images.dart';
import 'package:caffiene/models/tv.dart';
import 'package:caffiene/models/videos.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/movie_screens/cast_details.dart';
import 'package:caffiene/screens/movie_screens/crew_detail.dart';
import 'package:caffiene/screens/tv_screens/widgets/tv_grid_view.dart';
import 'package:caffiene/screens/tv_screens/widgets/tv_list_view.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/widgets/hero_photoview.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TVShowsFromWatchProviders extends StatefulWidget {
  const TVShowsFromWatchProviders({Key? key}) : super(key: key);

  @override
  TVShowsFromWatchProvidersState createState() =>
      TVShowsFromWatchProvidersState();
}

class TVShowsFromWatchProvidersState extends State<TVShowsFromWatchProviders> {
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const LeadingDot(),
                      Expanded(
                        child: Text(
                          tr("streaming_services"),
                          style: kTextHeaderStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 75,
            child: Row(
              children: [
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/netflix.png',
                        title: 'Netflix',
                        providerID: 8,
                      ),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/amazon_prime.png',
                        title: 'Amazon Prime',
                        providerID: 9,
                      ),
                      TVStreamingServicesWidget(
                          imagePath: 'assets/images/disney_plus.png',
                          title: 'Disney plus',
                          providerID: 337),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/hulu.png',
                        title: 'hulu',
                        providerID: 15,
                      ),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/hbo_max.png',
                        title: 'HBO Max',
                        providerID: 384,
                      ),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/apple_tv.png',
                        title: 'Apple TV plus',
                        providerID: 350,
                      ),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/peacock.png',
                        title: 'Peacock',
                        providerID: 387,
                      ),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/itunes.png',
                        title: 'iTunes',
                        providerID: 2,
                      ),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/youtube.png',
                        title: 'YouTube Premium',
                        providerID: 188,
                      ),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/paramount.png',
                        title: 'Paramount Plus',
                        providerID: 531,
                      ),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/netflix.png',
                        title: 'Netflix Kids',
                        providerID: 175,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]);
  }
}

class StreamingServicesTVShows extends StatelessWidget {
  final int providerId;
  final String providerName;
  const StreamingServicesTVShows(
      {Key? key, required this.providerId, required this.providerName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            tr("streaming_service_tv", namedArgs: {"provider": providerName})),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: ParticularStreamingServiceTVShows(
          includeAdult: Provider.of<SettingsProvider>(context).isAdult,
          providerID: providerId,
          api: Endpoints.watchProvidersTVShows(providerId, 1, lang),
        ),
      ),
    );
  }
}

class TVStreamingServicesWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final int providerID;
  const TVStreamingServicesWidget({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.providerID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return StreamingServicesTVShows(
            providerId: providerID,
            providerName: title,
          );
        }));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 60,
          width: 200,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(15)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image(
                image: AssetImage(imagePath),
                height: 50,
                width: 50,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ParticularStreamingServiceTVShows extends StatefulWidget {
  final String api;
  final int providerID;
  final bool? includeAdult;
  const ParticularStreamingServiceTVShows({
    Key? key,
    required this.api,
    required this.providerID,
    required this.includeAdult,
  }) : super(key: key);
  @override
  ParticularStreamingServiceTVShowsState createState() =>
      ParticularStreamingServiceTVShowsState();
}

class ParticularStreamingServiceTVShowsState
    extends State<ParticularStreamingServiceTVShows> {
  List<TV>? tvList;
  final _scrollController = ScrollController();
  int pageNum = 2;
  bool isLoading = false;

  void getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });

        tvApi()
            .fetchTV(
                '${widget.api}&page=$pageNum&include_adult=${widget.includeAdult}')
            .then((value) {
          if (mounted) {
            setState(() {
              tvList!.addAll(value);
              isLoading = false;
              pageNum++;
            });
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    tvApi()
        .fetchTV('${widget.api}&include_adult=${widget.includeAdult}')
        .then((value) {
      if (mounted) {
        setState(() {
          tvList = value;
        });
      }
    });
    getMoreData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final viewType = Provider.of<SettingsProvider>(context).defaultView;
    return tvList == null && viewType == 'grid'
        ? moviesAndTVShowGridShimmer(isDark)
        : tvList == null && viewType == 'list'
            ? Container(
                color:
                    isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                child: mainPageVerticalScrollShimmer1(
                    isDark: isDark,
                    isLoading: isLoading,
                    scrollController: _scrollController))
            : tvList!.isEmpty
                ? Container(
                    child: const Center(
                      child: Text(
                          'Oops! TV shows for this watch provider doesn\'t exist :('),
                    ),
                  )
                : Container(
                    child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            children: [
                              Expanded(
                                child: viewType == 'grid'
                                    ? TVGridView(
                                        tvList: tvList,
                                        imageQuality: imageQuality,
                                        isDark: isDark,
                                        scrollController: _scrollController,
                                      )
                                    : TVListView(
                                        scrollController: _scrollController,
                                        tvList: tvList,
                                        isDark: isDark,
                                        imageQuality: imageQuality),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                          visible: isLoading,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: LinearProgressIndicator()),
                          )),
                    ],
                  ));
  }
}

class TVEpisodeCastTab extends StatefulWidget {
  final String? api;
  const TVEpisodeCastTab({Key? key, this.api}) : super(key: key);

  @override
  TVEpisodeCastTabState createState() => TVEpisodeCastTabState();
}

class TVEpisodeCastTabState extends State<TVEpisodeCastTab>
    with AutomaticKeepAliveClientMixin<TVEpisodeCastTab> {
  Credits? credits;
  @override
  void initState() {
    super.initState();
    moviesApi().fetchCredits(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          credits = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return credits == null
        ? Container(
            padding: const EdgeInsets.only(top: 8),
            child: movieCastAndCrewTabShimmer(isDark))
        : credits!.cast!.isEmpty
            ? Center(
                child: Text(
                  tr("no_cast"),
                  style: kTextSmallHeaderStyle,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                ),
              )
            : Container(
                child: ListView.builder(
                    itemCount: credits!.cast!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CastDetailPage(
                                cast: credits!.cast![index],
                                heroId: '${credits!.cast![index].name}');
                          }));
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              bottom: 5.0,
                              left: 10,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  // crossAxisAlignment:
                                  //     CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 20.0, left: 10),
                                      child: SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: Hero(
                                          tag: '${credits!.cast![index].name}',
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            child: credits!.cast![index]
                                                        .profilePath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_rect.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
                                                    cacheManager: cacheProp(),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 300),
                                                    fadeOutCurve:
                                                        Curves.easeOut,
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 700),
                                                    fadeInCurve: Curves.easeIn,
                                                    imageUrl:
                                                        TMDB_BASE_IMAGE_URL +
                                                            imageQuality +
                                                            credits!
                                                                .cast![index]
                                                                .profilePath!,
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    placeholder: (context,
                                                            url) =>
                                                        castAndCrewTabImageShimmer1(
                                                            isDark),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      'assets/images/na_rect.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            credits!.cast![index].name!,
                                            style: const TextStyle(
                                                fontFamily: 'PoppinsSB',
                                                fontSize: 20),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(credits!.cast![index].character!
                                                  .isEmpty
                                              ? tr("as_empty")
                                              : tr("as", namedArgs: {
                                                  "character": credits!
                                                      .cast![index].character!
                                                })),
                                          // Text(
                                          //   credits!.cast![index].roles![0]
                                          //               .episodeCount! ==
                                          //           1
                                          //       ? credits!.cast![index]
                                          //               .roles![0].episodeCount!
                                          //               .toString() +
                                          //           ' episode'
                                          //       : credits!.cast![index]
                                          //               .roles![0].episodeCount!
                                          //               .toString() +
                                          //           ' episodes',
                                          // ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Divider(
                                  color:
                                      !isDark ? Colors.black54 : Colors.white54,
                                  thickness: 1,
                                  endIndent: 20,
                                  indent: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }));
  }

  @override
  bool get wantKeepAlive => true;
}

class TopButton extends StatefulWidget {
  final String buttonText;
  const TopButton({
    Key? key,
    required this.buttonText,
  }) : super(key: key);

  @override
  TopButtonState createState() => TopButtonState();
}

class TopButtonState extends State<TopButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color(0x26F57C00)),
            maximumSize: MaterialStateProperty.all(const Size(200, 60)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: const BorderSide(color: maincolor)))),
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          widget.buttonText,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class TVImagesDisplay extends StatefulWidget {
  final String? api, title, name;
  const TVImagesDisplay({Key? key, this.api, this.name, this.title})
      : super(key: key);

  @override
  TVImagesDisplayState createState() => TVImagesDisplayState();
}

class TVImagesDisplayState extends State<TVImagesDisplay> {
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
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
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
                          style: kTextHeaderStyle,
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
              height: 260,
              child: tvImages == null
                  ? detailImageShimmer1(isDark)
                  : CarouselSlider(
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
                                child: tvImages!.poster!.isEmpty
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
                                                    child: tvImages!.poster![0]
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
                                                                Curves.easeOut,
                                                            fadeInDuration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        700),
                                                            fadeInCurve:
                                                                Curves.easeIn,
                                                            imageUrl: TMDB_BASE_IMAGE_URL +
                                                                imageQuality +
                                                                tvImages!
                                                                    .poster![0]
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
                                                                        tvImages!
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
                                                                    tvImages!
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
                                                                detailImageImageSimmer1(
                                                                    isDark),
                                                            errorWidget:
                                                                (context, url,
                                                                        error) =>
                                                                    Image.asset(
                                                              'assets/images/na_logo.png',
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    color: Colors.black38,
                                                    child: Text(tvImages!
                                                                .poster!
                                                                .length ==
                                                            1
                                                        ? tr("poster_singular",
                                                            namedArgs: {
                                                                "poster": tvImages!
                                                                    .poster!
                                                                    .length
                                                                    .toString()
                                                              })
                                                        : tr("poster_plural",
                                                            namedArgs: {
                                                                "poster": tvImages!
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
                                child: tvImages!.backdrop!.isEmpty
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
                                                    child: tvImages!
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
                                                                Curves.easeOut,
                                                            fadeInDuration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        700),
                                                            fadeInCurve:
                                                                Curves.easeIn,
                                                            imageUrl: TMDB_BASE_IMAGE_URL +
                                                                imageQuality +
                                                                tvImages!
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
                                                                        tvImages!
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
                                                                    tvImages!
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
                                                                detailImageImageSimmer1(
                                                                    isDark),
                                                            errorWidget:
                                                                (context, url,
                                                                        error) =>
                                                                    Image.asset(
                                                              'assets/images/na_logo.png',
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    color: Colors.black38,
                                                    child: Text(tvImages!
                                                                .backdrop!
                                                                .length ==
                                                            1
                                                        ? tr(
                                                            "backdrop_singular",
                                                            namedArgs: {
                                                                "backdrop": tvImages!
                                                                    .backdrop!
                                                                    .length
                                                                    .toString()
                                                              })
                                                        : tr("backdrop_plural",
                                                            namedArgs: {
                                                                "backdrop": tvImages!
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
        ],
      ),
    );
  }
}

class TVVideosDisplay extends StatefulWidget {
  final String? api, title, api2;
  const TVVideosDisplay({Key? key, this.api, this.title, this.api2})
      : super(key: key);

  @override
  TVVideosDisplayState createState() => TVVideosDisplayState();
}

class TVVideosDisplayState extends State<TVVideosDisplay> {
  Videos? tvVideos;

  @override
  void initState() {
    super.initState();
    moviesApi().fetchVideos(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          tvVideos = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool playButtonVisibility = true;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Column(
      children: [
        tvVideos == null
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
            height: 230,
            child: tvVideos == null
                ? detailVideoShimmer1(isDark)
                : tvVideos!.result!.isEmpty
                    ? SizedBox(
                        width: double.infinity,
                        height: 100,
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              Text(tr("no_video"), textAlign: TextAlign.center),
                        )),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: CarouselSlider.builder(
                          options: CarouselOptions(
                            disableCenter: true,
                            viewportFraction: 0.8,
                            enlargeCenterPage: false,
                            autoPlay: true,
                          ),
                          itemBuilder:
                              (BuildContext context, int index, pageViewIndex) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  launchUrl(
                                      Uri.parse(YOUTUBE_BASE_URL +
                                          tvVideos!.result![index].videoLink!),
                                      mode: LaunchMode.externalApplication);
                                },
                                child: SizedBox(
                                  height: 150,
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 130,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  CachedNetworkImage(
                                                    cacheManager: cacheProp(),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 300),
                                                    fadeOutCurve:
                                                        Curves.easeOut,
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 700),
                                                    fadeInCurve: Curves.easeIn,
                                                    imageUrl:
                                                        '$YOUTUBE_THUMBNAIL_URL${tvVideos!.result![index].videoLink!}/hqdefault.jpg',
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    placeholder: (context,
                                                            url) =>
                                                        detailVideoImageShimmer1(
                                                            isDark),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      'assets/images/na_logo.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        playButtonVisibility,
                                                    child: const SizedBox(
                                                      height: 90,
                                                      width: 90,
                                                      child: Icon(
                                                        Icons.play_arrow,
                                                        size: 90,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          tvVideos!.result![index].name!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: tvVideos!.result!.length,
                        ),
                      ),
          ),
        ),
      ],
    );
  }
}

class TVInfoTable extends StatefulWidget {
  final String? api;
  const TVInfoTable({Key? key, this.api}) : super(key: key);

  @override
  TVInfoTableState createState() => TVInfoTableState();
}

class TVInfoTableState extends State<TVInfoTable> {
  TVDetails? tvDetails;

  @override
  void initState() {
    super.initState();
    tvApi().fetchTVDetails(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          tvDetails = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LeadingDot(),
              Expanded(
                child: Text(
                  tr("tv_series_info"),
                  style: kTextHeaderStyle,
                ),
              ),
            ],
          ),
          Container(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: tvDetails == null
                    ? detailInfoTableShimmer1(isDark)
                    : DataTable(dataRowMinHeight: 40, columns: [
                        DataColumn(
                            label: Text(
                          tr("original_title"),
                          style: kTableLeftStyle,
                        )),
                        DataColumn(
                          label: Text(
                            tvDetails!.originalTitle!,
                            style: kTableLeftStyle,
                          ),
                        ),
                      ], rows: [
                        DataRow(cells: [
                          DataCell(Text(
                            tr("status"),
                            style: kTableLeftStyle,
                          )),
                          DataCell(Text(tvDetails!.status!.isEmpty
                              ? tr("unknown")
                              : tvDetails!.status!)),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            tr("runtime"),
                            style: kTableLeftStyle,
                          )),
                          DataCell(Text(tvDetails!.runtime!.isEmpty
                              ? '-'
                              : tvDetails!.runtime![0] == 0
                                  ? tr("not_available")
                                  : tr("runtime_mins", namedArgs: {
                                      "mins": tvDetails!.runtime![0].toString()
                                    }))),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            tr("spoken_language"),
                            style: kTableLeftStyle,
                          )),
                          DataCell(SizedBox(
                            height: 20,
                            width: 200,
                            child: tvDetails!.spokenLanguages!.isEmpty
                                ? const Text('-')
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        tvDetails!.spokenLanguages!.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5.0),
                                        child: Text(tvDetails!
                                                .spokenLanguages!.isEmpty
                                            ? tr("not_available")
                                            : '${tvDetails!.spokenLanguages![index].englishName},'),
                                      );
                                    },
                                  ),
                          )),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            tr("total_seasons"),
                            style: kTableLeftStyle,
                          )),
                          DataCell(Text(tvDetails!.numberOfSeasons! == 0
                              ? '-'
                              : '${tvDetails!.numberOfSeasons!}')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            tr("total_episodes"),
                            style: kTableLeftStyle,
                          )),
                          DataCell(Text(tvDetails!.numberOfEpisodes! == 0
                              ? '-'
                              : '${tvDetails!.numberOfEpisodes!}')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            tr("tagline"),
                            style: kTableLeftStyle,
                          )),
                          DataCell(
                            Text(
                              tvDetails!.tagline!.isEmpty
                                  ? '-'
                                  : tvDetails!.tagline!,
                              style: const TextStyle(
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            tr("production_companies"),
                            style: kTableLeftStyle,
                          )),
                          DataCell(SizedBox(
                            height: 20,
                            width: 200,
                            child: tvDetails!.productionCompanies!.isEmpty
                                ? const Text('-')
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        tvDetails!.productionCompanies!.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5.0),
                                        child: Text(tvDetails!
                                                .productionCompanies!.isEmpty
                                            ? tr("not_available")
                                            : '${tvDetails!.productionCompanies![index].name},'),
                                      );
                                    },
                                  ),
                          )),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            tr("production_countries"),
                            style: kTableLeftStyle,
                          )),
                          DataCell(SizedBox(
                            height: 20,
                            width: 200,
                            child: tvDetails!.productionCountries!.isEmpty
                                ? const Text('-')
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        tvDetails!.productionCountries!.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5.0),
                                        child: Text(tvDetails!
                                                .productionCountries!.isEmpty
                                            ? tr("not_available")
                                            : '${tvDetails!.productionCountries![index].name},'),
                                      );
                                    },
                                  ),
                          )),
                        ]),
                      ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class TVSeasonsTab extends StatefulWidget {
//   final String? api;
//   final int? tvId;
//   final String? seriesName;
//   final bool? adult;
//   const TVSeasonsTab(
//       {Key? key, this.api, this.tvId, this.seriesName, required this.adult})
//       : super(key: key);

//   @override
//   TVSeasonsTabState createState() => TVSeasonsTabState();
// }

// class TVSeasonsTabState extends State<TVSeasonsTab>
//     with AutomaticKeepAliveClientMixin<TVSeasonsTab> {
//   TVDetails? tvDetails;
//   bool requestFailed = false;

//   @override
//   void initState() {
//     super.initState();
//     getData();
//   }

//   void getData() {
//     tvApi().fetchTVDetails(widget.api!).then((value) {
//       setState(() {
//         tvDetails = value;
//       });
//     });
//     Future.delayed(const Duration(seconds: 11), () {
//       if (tvDetails == null) {
//         setState(() {
//           requestFailed = true;
//           tvDetails = TVDetails(seasons: [Seasons()]);
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
//     super.build(context);
//     final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
//     return tvDetails == null
//         ? Container(
//             color: const Color(0xFFFFFFFF), child: tvDetailsSeasonsTabShimmer())
//         : tvDetails!.seasons!.isEmpty
//             ? Container(
//                 color: const Color(0xFFFFFFFF),
//                 child: const Center(
//                   child: Text('There is no season available for this TV show',
//                       style: kTextSmallHeaderStyle),
//                 ),
//               )
//             : requestFailed == true
//                 ? retryWidget()
//                 : Container(
//                     color: const Color(0xFFFFFFFF),
//                     child: Column(
//                       children: [
//                         Expanded(
//                           child: ListView.builder(
//                               itemCount: tvDetails!.seasons!.length,
//                               itemBuilder: (BuildContext context, int index) {
//                                 return GestureDetector(
//                                   onTap: () {
//                                     Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                             builder: (context) => SeasonsDetail(
//                                                 adult: widget.adult,
//                                                 seriesName: widget.seriesName,
//                                                 tvId: widget.tvId,
//                                                 tvDetails: tvDetails!,
//                                                 seasons:
//                                                     tvDetails!.seasons![index],
//                                                 heroId:
//                                                     '${tvDetails!.seasons![index].seasonId}')));
//                                   },
//                                   child: Container(
//                                     color: const Color(0xFFFFFFFF),
//                                     child: Padding(
//                                       padding: const EdgeInsets.only(
//                                         top: 0.0,
//                                         bottom: 5.0,
//                                         left: 15,
//                                       ),
//                                       child: Column(
//                                         children: [
//                                           Row(
//                                             // crossAxisAlignment:
//                                             //     CrossAxisAlignment.start,
//                                             children: [
//                                               Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     right: 30.0),
//                                                 child: SizedBox(
//                                                   width: 85,
//                                                   height: 130,
//                                                   child: Hero(
//                                                     tag:
//                                                         '${tvDetails!.seasons![index].seasonId}',
//                                                     child: ClipRRect(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               10.0),
//                                                       child: tvDetails!
//                                                                   .seasons![
//                                                                       index]
//                                                                   .posterPath ==
//                                                               null
//                                                           ? Image.asset(
//                                                               'assets/images/na_logo.png',
//                                                               fit: BoxFit.cover,
//                                                             )
//                                                           : CachedNetworkImage(
//                                                               fadeOutDuration:
//                                                                   const Duration(
//                                                                       milliseconds:
//                                                                           300),
//                                                               fadeOutCurve:
//                                                                   Curves
//                                                                       .easeOut,
//                                                               fadeInDuration:
//                                                                   const Duration(
//                                                                       milliseconds:
//                                                                           700),
//                                                               fadeInCurve:
//                                                                   Curves.easeIn,
//                                                               imageUrl: TMDB_BASE_IMAGE_URL +
//                                                                   imageQuality +
//                                                                   tvDetails!
//                                                                       .seasons![
//                                                                           index]
//                                                                       .posterPath!,
//                                                               imageBuilder:
//                                                                   (context,
//                                                                           imageProvider) =>
//                                                                       Container(
//                                                                 decoration:
//                                                                     BoxDecoration(
//                                                                   image:
//                                                                       DecorationImage(
//                                                                     image:
//                                                                         imageProvider,
//                                                                     fit: BoxFit
//                                                                         .cover,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                               placeholder: (context,
//                                                                       url) =>
//                                                                   recommendationAndSimilarTabImageShimmer(),
//                                                               errorWidget: (context,
//                                                                       url,
//                                                                       error) =>
//                                                                   Image.asset(
//                                                                 'assets/images/na_logo.png',
//                                                                 fit: BoxFit
//                                                                     .cover,
//                                                               ),
//                                                             ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                               Expanded(
//                                                 child: Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     Text(
//                                                       tvDetails!.seasons![index]
//                                                           .name!,
//                                                       style: const TextStyle(
//                                                           fontSize: 20,
//                                                           fontFamily:
//                                                               'PoppinsSB',
//                                                           overflow: TextOverflow
//                                                               .ellipsis),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               )
//                                             ],
//                                           ),
//                                           Divider(
//                                             color: Colors.white54,
//                                             thickness: 1,
//                                             endIndent: 20,
//                                             indent: 10,
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               }),
//                         ),
//                       ],
//                     ));
//   }

//   Widget retryWidget() {
//     return Center(
//       child: Container(
//           width: double.infinity,
//           color: const Color(0xFFFFFFFF),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset('assets/images/network-signal.png',
//                   width: 60, height: 60),
//               const Padding(
//                 padding: EdgeInsets.only(top: 8.0),
//                 child: Text('Please connect to the Internet and try again',
//                     textAlign: TextAlign.center),
//               ),
//               TextButton(
//                   style: ButtonStyle(
//                       backgroundColor:
//                           MaterialStateProperty.all(const Color(0x0DF57C00)),
//                       maximumSize:
//                           MaterialStateProperty.all(const Size(200, 60)),
//                       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                           RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(5.0),
//                               side:
//                                   const BorderSide(color: Color(0xFFF57C00))))),
//                   onPressed: () {
//                     setState(() {
//                       requestFailed = false;
//                       tvDetails = null;
//                     });
//                     getData();
//                   },
//                   child: const Text('Retry')),
//             ],
//           )),
//     );
//   }

//   @override
//   bool get wantKeepAlive => true;
// }

class TVCastTab extends StatefulWidget {
  final String? api;
  const TVCastTab({
    Key? key,
    this.api,
  }) : super(key: key);

  @override
  TVCastTabState createState() => TVCastTabState();
}

class TVCastTabState extends State<TVCastTab>
    with AutomaticKeepAliveClientMixin<TVCastTab> {
  Credits? credits;

  @override
  void initState() {
    super.initState();
    moviesApi().fetchCredits(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          credits = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return credits == null
        ? Container(child: tvCastAndCrewTabShimmer1(isDark))
        : credits!.cast!.isEmpty
            ? Center(
                child: Text(
                  tr("no_cast_tv"),
                  style: kTextSmallHeaderStyle,
                  textAlign: TextAlign.center,
                ),
              )
            : Container(
                child: ListView.builder(
                    itemCount: credits!.cast!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CastDetailPage(
                                cast: credits!.cast![index],
                                heroId: '${credits!.cast![index].name}');
                          }));
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              bottom: 5.0,
                              left: 10,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  // crossAxisAlignment:
                                  //     CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 20.0, left: 10),
                                      child: SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: Hero(
                                          tag: '${credits!.cast![index].name}',
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            child: credits!.cast![index]
                                                        .profilePath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_rect.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
                                                    cacheManager: cacheProp(),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 300),
                                                    fadeOutCurve:
                                                        Curves.easeOut,
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 700),
                                                    fadeInCurve: Curves.easeIn,
                                                    imageUrl:
                                                        TMDB_BASE_IMAGE_URL +
                                                            imageQuality +
                                                            credits!
                                                                .cast![index]
                                                                .profilePath!,
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    placeholder: (context,
                                                            url) =>
                                                        castAndCrewTabImageShimmer1(
                                                            isDark),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      'assets/images/na_rect.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            credits!.cast![index].name!,
                                            style: const TextStyle(
                                                fontFamily: 'PoppinsSB',
                                                fontSize: 20),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(credits!.cast![index].roles![0]
                                                  .character!.isEmpty
                                              ? tr("as_empty")
                                              : tr("as", namedArgs: {
                                                  "character": credits!
                                                      .cast![index]
                                                      .roles![0]
                                                      .character!
                                                })),
                                          Text(
                                            credits!.cast![0].roles == null
                                                ? ''
                                                : credits!
                                                            .cast![index]
                                                            .roles![0]
                                                            .episodeCount! ==
                                                        1
                                                    ? tr("single_episode",
                                                        namedArgs: {
                                                            "count": credits!
                                                                .cast![index]
                                                                .roles![0]
                                                                .episodeCount!
                                                                .toString()
                                                          })
                                                    : tr("multi_episode",
                                                        namedArgs: {
                                                            "count": credits!
                                                                .cast![index]
                                                                .roles![0]
                                                                .episodeCount!
                                                                .toString()
                                                          }),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Divider(
                                  color:
                                      !isDark ? Colors.black54 : Colors.white54,
                                  thickness: 1,
                                  endIndent: 20,
                                  indent: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }));
  }

  @override
  bool get wantKeepAlive => true;
}
class TVCrewTab extends StatefulWidget {
  final String? api;
  const TVCrewTab({Key? key, this.api}) : super(key: key);

  @override
  TVCrewTabState createState() => TVCrewTabState();
}

class TVCrewTabState extends State<TVCrewTab>
    with AutomaticKeepAliveClientMixin<TVCrewTab> {
  Credits? credits;

  @override
  void initState() {
    super.initState();
    moviesApi().fetchCredits(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          credits = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return credits == null
        ? Container(
            padding: const EdgeInsets.only(top: 8),
            child: movieCastAndCrewTabShimmer(isDark))
        : credits!.crew!.isEmpty
            ? Center(
                child: Text(
                  tr("no_cast_tv"),
                  style: kTextSmallHeaderStyle,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                ),
              )
            : Container(
                child: ListView.builder(
                    itemCount: credits!.crew!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CrewDetailPage(
                                crew: credits!.crew![index],
                                heroId: '${credits!.crew![index].name}');
                          }));
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              bottom: 5.0,
                              left: 10,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  // crossAxisAlignment:
                                  //     CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 20.0, left: 10),
                                      child: SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: Hero(
                                          tag: '${credits!.crew![index].name}',
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            child: credits!.crew![index]
                                                        .profilePath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_rect.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
                                                    cacheManager: cacheProp(),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 300),
                                                    fadeOutCurve:
                                                        Curves.easeOut,
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 700),
                                                    fadeInCurve: Curves.easeIn,
                                                    imageUrl:
                                                        TMDB_BASE_IMAGE_URL +
                                                            imageQuality +
                                                            credits!
                                                                .crew![index]
                                                                .profilePath!,
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    placeholder: (context,
                                                            url) =>
                                                        castAndCrewTabImageShimmer1(
                                                            isDark),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      'assets/images/na_rect.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            credits!.crew![index].name!,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontFamily: 'PoppinsSB',
                                                fontSize: 20),
                                          ),
                                          Text(credits!.crew![index].department!
                                                  .isEmpty
                                              ? tr("job_empty")
                                              : tr("job", namedArgs: {
                                                  "job": credits!
                                                      .crew![index].department!
                                                })),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Divider(
                                  color:
                                      !isDark ? Colors.black54 : Colors.white54,
                                  thickness: 1,
                                  endIndent: 20,
                                  indent: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }));
  }

  @override
  bool get wantKeepAlive => true;
}

class TVWatchProvidersDetails extends StatefulWidget {
  final String api;
  final String country;
  const TVWatchProvidersDetails(
      {Key? key, required this.api, required this.country})
      : super(key: key);

  @override
  State<TVWatchProvidersDetails> createState() =>
      _TVWatchProvidersDetailsState();
}

class _TVWatchProvidersDetailsState extends State<TVWatchProvidersDetails>
    with SingleTickerProviderStateMixin {
  WatchProviders? watchProviders;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
    moviesApi().fetchWatchProviders(widget.api, widget.country).then((value) {
      if (mounted) {
        setState(() {
          watchProviders = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return Container(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2b2c30) : const Color(0xFFDFDEDE),
            ),
            child: Center(
              child: TabBar(
                controller: tabController,
                isScrollable: true,
                indicatorWeight: 3,
                unselectedLabelColor: Colors.white54,
                labelColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(
                    child: Text(tr("buy"),
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white : Colors.black)),
                  ),
                  Tab(
                    child: Text(tr("stream"),
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white : Colors.black)),
                  ),
                  Tab(
                    child: Text(tr("ads"),
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white : Colors.black)),
                  ),
                  Tab(
                    child: Text(tr("rent"),
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white : Colors.black)),
                  ),
                  Tab(
                    child: Text(tr("free"),
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white : Colors.black)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: watchProviders == null
                  ? [
                      watchProvidersShimmer(isDark),
                      watchProvidersShimmer(isDark),
                      watchProvidersShimmer(isDark),
                      watchProvidersShimmer(isDark),
                      watchProvidersShimmer(isDark),
                    ]
                  : [
                      watchProvidersTabData(
                          isDark: isDark,
                          imageQuality: imageQuality,
                          noOptionMessage: tr("no_buy_tv"),
                          watchOptions: watchProviders!.buy),
                      watchProvidersTabData(
                          isDark: isDark,
                          imageQuality: imageQuality,
                          noOptionMessage: tr("no_stream_tv"),
                          watchOptions: watchProviders!.flatRate),
                      watchProvidersTabData(
                          isDark: isDark,
                          imageQuality: imageQuality,
                          noOptionMessage: tr("no_ads_tv"),
                          watchOptions: watchProviders!.ads),
                      watchProvidersTabData(
                          isDark: isDark,
                          imageQuality: imageQuality,
                          noOptionMessage: tr("no_rent_tv"),
                          watchOptions: watchProviders!.rent),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 100,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                            ),
                            itemCount: 1,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: const FadeInImage(
                                          image: AssetImage(
                                              'assets/images/logo_shadow.png'),
                                          fit: BoxFit.cover,
                                          placeholder: AssetImage(
                                              'assets/images/loading_5.gif'),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                          tr("caffiene"),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                  ],
                                ),
                              );
                            }),
                      ),
                    ],
            ),
          )
        ],
      ),
    );
  }
}
