import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:login/api/endpoints.dart';
import 'package:login/api/movies_api.dart';
import 'package:login/api/tv_api.dart';
import 'package:login/models/credits.dart';
import 'package:login/models/images.dart';
import 'package:login/models/movie_models.dart';
import 'package:login/models/social_icons_icons.dart';
import 'package:login/models/tv.dart';
import 'package:login/models/videos.dart';
import 'package:login/provider/adultmode_provider.dart';
import 'package:login/provider/imagequality_provider.dart';
import 'package:login/screens/movie_screens/widgets/cast_details.dart';
import 'package:login/screens/movie_screens/widgets/crew_detail.dart';
import 'package:login/screens/movie_screens/widgets/movie_social_links.dart';
import 'package:login/screens/tv_screens/episode_detail_page.dart';
import 'package:login/screens/tv_screens/seasons_detail.dart';
import 'package:login/screens/tv_screens/tv_detail_page.dart';
import 'package:login/utils/config.dart';
import 'package:login/widgets/hero_photoview.dart';
import 'package:login/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
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
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Streaming services',
              style: kTextHeaderStyle,
            ),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TV shows from $providerName',
        ),
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
          includeAdult: Provider.of<AdultmodeProvider>(context).isAdult,
          providerID: providerId,
          api: Endpoints.watchProvidersTVShows(providerId, 1),
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
              color: maincolor2,
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
                child: Text(title, style: const TextStyle(color: Colors.white)),
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
  bool requestFailed = false;

  Future<String> getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });

        var response = await http.get(Uri.parse('$TMDB_API_BASE_URL'
            '/discover/tv?api_key='
            '$TMDB_API_KEY'
            '&language=en-US&sort_by=popularity&include_adult=${widget.includeAdult}'
            '.desc&include_adult=false&include_video=false&page=$pageNum'
            '&with_watch_providers=${widget.providerID}'
            '&watch_region=US'));
        setState(() {
          pageNum++;
          isLoading = false;
          var newlistTV = (json.decode(response.body)['results'] as List)
              .map((i) => TV.fromJson(i))
              .toList();
          tvList!.addAll(newlistTV);
        });
      }
    });

    return "success";
  }

  @override
  void initState() {
    super.initState();
    getData();
    getMoreData();
  }

  void getData() {
    tvApi().fetchTV('${widget.api}&include_adult=${widget.includeAdult}').then((value) {
      setState(() {
        tvList = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (tvList == null) {
        setState(() {
          requestFailed = true;
          tvList = [TV()];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    return tvList == null
        ? Container(
            color:const Color(0xFFFFFFFF),
            child: mainPageVerticalScrollShimmer(
                isLoading, _scrollController))
        : tvList!.isEmpty
            ? Container(
                color:
                    const Color(0xFFFFFFFF),
                child: const Center(
                  child: Text(
                      'Oops! TV shows for this watch provider doesn\'t exist :('),
                ),
              )
            : requestFailed == true
                ? retryWidget()
                : Container(
                    color: const Color(0xFFFFFFFF),
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                      controller: _scrollController,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: tvList!.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return GestureDetector(
                                          onTap: () {
                                            //TODO: add tv detail
                                            // Navigator.push(context,
                                            //     MaterialPageRoute(
                                            //         builder: (context) {
                                            //   return TVDetailPage(
                                            //     tvSeries: tvList![index],
                                            //     heroId: '${tvList![index].id}',
                                            //   );
                                            // }));
                                          },
                                          child: Container(
                                            color:const Color(0xFFFFFFFF),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 0.0,
                                                bottom: 3.0,
                                                left: 10,
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                right: 10.0),
                                                        child: SizedBox(
                                                          width: 85,
                                                          height: 130,
                                                          child: Hero(
                                                            tag:
                                                                '${tvList![index].id}',
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                              child: tvList![index]
                                                                          .posterPath ==
                                                                      null
                                                                  ? Image.asset(
                                                                      'assets/images/na_logo.png',
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    )
                                                                  : CachedNetworkImage(
                                                                      fadeOutDuration:
                                                                          const Duration(
                                                                              milliseconds: 300),
                                                                      fadeOutCurve:
                                                                          Curves
                                                                              .easeOut,
                                                                      fadeInDuration:
                                                                          const Duration(
                                                                              milliseconds: 700),
                                                                      fadeInCurve:
                                                                          Curves
                                                                              .easeIn,
                                                                      imageUrl: TMDB_BASE_IMAGE_URL +
                                                                          imageQuality +
                                                                          tvList![index]
                                                                              .posterPath!,
                                                                      imageBuilder:
                                                                          (context, imageProvider) =>
                                                                              Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          image:
                                                                              DecorationImage(
                                                                            image:
                                                                                imageProvider,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      placeholder: (context,
                                                                              url) =>
                                                                          mainPageVerticalScrollImageShimmer(
                                                                              ),
                                                                      errorWidget: (context,
                                                                              url,
                                                                              error) =>
                                                                          Image
                                                                              .asset(
                                                                        'assets/images/na_logo.png',
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              tvList![index]
                                                                  .name!,
                                                              style: const TextStyle(
                                                                  fontFamily:
                                                                      'PoppinsSB',
                                                                  fontSize: 15,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis),
                                                            ),
                                                            Row(
                                                              children: <
                                                                  Widget>[
                                                                const Icon(
                                                                    Icons.star,
                                                                    color: Color(
                                                                        0xFFF57C00)),
                                                                Text(
                                                                  tvList![index]
                                                                      .voteAverage!
                                                                      .toStringAsFixed(
                                                                          1),
                                                                  style: const TextStyle(
                                                                      fontFamily:
                                                                          'Poppins'),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Divider(
                                                    color:Colors.white54,
                                                    thickness: 1,
                                                    endIndent: 20,
                                                    indent: 10,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                            visible: isLoading,
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: CircularProgressIndicator()),
                            )),
                      ],
                    ));
  }

  Widget retryWidget() {
    return Center(
      child: Container(
          width: double.infinity,
          color:const Color(0xFFFFFFFF),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/network-signal.png',
                  width: 60, height: 60),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('Please connect to the Internet and try again',
                    textAlign: TextAlign.center),
              ),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0x0DF57C00)),
                      maximumSize:
                          MaterialStateProperty.all(const Size(200, 60)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side:
                                  const BorderSide(color: Color(0xFFF57C00))))),
                  onPressed: () {
                    setState(() {
                      requestFailed = false;
                      tvList = null;
                    });
                    getData();
                  },
                  child: const Text('Retry')),
            ],
          )),
    );
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
  bool requestFailed = false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    moviesApi().fetchCredits(widget.api!).then((value) {
      setState(() {
        credits = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (credits == null) {
        setState(() {
          requestFailed = true;
          credits = Credits(cast: [Cast()]);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    return credits == null
        ? Container(
            color:const Color(0xFFFFFFFF),
            child: movieCastAndCrewTabShimmer())
        : credits!.cast!.isEmpty
            ? Container(
                color:
                  const Color(0xFFFFFFFF),
                child: const Center(
                  child: Text('No cast available :(',
                      style: kTextSmallHeaderStyle),
                ),
              )
            : requestFailed == true
                ? retryWidget()
                : Container(
                    color:const Color(0xFFFFFFFF),
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
                              color:const Color(0xFFFFFFFF),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 0.0,
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
                                              tag:
                                                  '${credits!.cast![index].name}',
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0),
                                                child: credits!.cast![index]
                                                            .profilePath ==
                                                        null
                                                    ? Image.asset(
                                                        'assets/images/na_square.png',
                                                        fit: BoxFit.cover,
                                                      )
                                                    : CachedNetworkImage(
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
                                                        imageUrl:
                                                            TMDB_BASE_IMAGE_URL +
                                                                imageQuality +
                                                                credits!
                                                                    .cast![
                                                                        index]
                                                                    .profilePath!,
                                                        imageBuilder: (context,
                                                                imageProvider) =>
                                                            Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            image:
                                                                DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        placeholder: (context,
                                                                url) =>
                                                            castAndCrewTabImageShimmer(
                                                                ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Image.asset(
                                                          'assets/images/na_square.png',
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
                                                    fontFamily: 'PoppinsSB'),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                'As : '
                                                '${credits!.cast![index].character!.isEmpty ? 'N/A' : credits!.cast![index].character!}',
                                              ),
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
                                      color: Colors.white54,
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

  Widget retryWidget() {
    return Center(
      child: Container(
          width: double.infinity,
          color:const Color(0xFFFFFFFF),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/network-signal.png',
                  width: 60, height: 60),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('Please connect to the Internet and try again',
                    textAlign: TextAlign.center),
              ),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0x0DF57C00)),
                      maximumSize:
                          MaterialStateProperty.all(const Size(200, 60)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side:
                                  const BorderSide(color: Color(0xFFF57C00))))),
                  onPressed: () {
                    setState(() {
                      requestFailed = false;
                      credits = null;
                    });
                    getData();
                  },
                  child: const Text('Retry')),
            ],
          )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SeasonsList extends StatefulWidget {
  final String? api;
  final String? title;
  final int? tvId;
  final String? seriesName;
  final bool? adult;

  const SeasonsList(
      {Key? key,
      this.api,
      this.title,
      this.tvId,
      this.seriesName,
      required this.adult})
      : super(key: key);

  @override
  SeasonsListState createState() => SeasonsListState();
}

class SeasonsListState extends State<SeasonsList> {
  TVDetails? tvDetails;
  @override
  void initState() {
    super.initState();
    tvApi().fetchTVDetails(widget.api!).then((value) {
      setState(() {
        tvDetails = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    // final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.title!,
                style: kTextHeaderStyle,
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          height: 250,
          child: tvDetails == null
              ? horizontalScrollingSeasonsList()
              : tvDetails!.seasons!.isEmpty
                  ? Container(
                      color: const Color(0xFF202124),
                      child: const Center(
                        child: Text(
                            'There is no season available for this TV show',
                            textAlign: TextAlign.center),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: tvDetails!.seasons!.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SeasonsDetail(
                                                tvId: widget.tvId,
                                                adult: widget.adult,
                                                seriesName: widget.seriesName,
                                                tvDetails: tvDetails!,
                                                seasons:
                                                    tvDetails!.seasons![index],
                                                heroId:
                                                    '${tvDetails!.seasons![index].seasonNumber}')));
                                  },
                                  child: SizedBox(
                                    width: 105,
                                    child: Column(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 6,
                                          child: Hero(
                                            tag:
                                                '${tvDetails!.seasons![index].seasonNumber}',
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: tvDetails!.seasons![index]
                                                          .posterPath ==
                                                      null
                                                  ? Image.asset(
                                                      'assets/images/na_logo.png',
                                                      fit: BoxFit.cover,
                                                    )
                                                  : CachedNetworkImage(
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
                                                      imageUrl:
                                                          TMDB_BASE_IMAGE_URL +
                                                              imageQuality +
                                                              tvDetails!
                                                                  .seasons![
                                                                      index]
                                                                  .posterPath!,
                                                      imageBuilder: (context,
                                                              imageProvider) =>
                                                          Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                            image:
                                                                imageProvider,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      placeholder: (context,
                                                              url) =>
                                                          scrollingImageShimmer(
                                                              ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Image.asset(
                                                        'assets/images/na_logo.png',
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              tvDetails!.seasons![index].name!,
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
        ),
      ],
    );
  }
}

class EpisodeListWidget extends StatefulWidget {
  final int? tvId;
  final String? api;
  final String? seriesName;
  final bool? adult;
  const EpisodeListWidget(
      {Key? key, this.api, this.tvId, this.seriesName, required this.adult})
      : super(key: key);

  @override
  EpisodeListWidgetState createState() => EpisodeListWidgetState();
}

class EpisodeListWidgetState extends State<EpisodeListWidget>
    with AutomaticKeepAliveClientMixin {
  TVDetails? tvDetails;
  bool requestFailed = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    tvApi().fetchTVDetails(widget.api!).then((value) {
      setState(() {
        tvDetails = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (tvDetails == null) {
        setState(() {
          requestFailed = true;
          tvDetails = TVDetails(episodes: [EpisodeList()]);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    return Container(
        color:const Color(0xFFFFFFFF),
        child: tvDetails == null
            ? ListView.builder(
                itemCount: 10,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    color:const Color(0xFFFFFFFF),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 0.0,
                        bottom: 8.0,
                        left: 10,
                      ),
                      child: Column(
                        children: [
                          Shimmer.fromColors(
                            baseColor:Colors.grey.shade300,
                            highlightColor:Colors.grey.shade100,
                            direction: ShimmerDirection.ltr,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    color: Colors.white, width: 10, height: 15),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 10.0, left: 5.0),
                                  child: Container(
                                    height: 56.4,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.0),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 2.0),
                                        child: Container(
                                            color: Colors.white,
                                            height: 19,
                                            width: 150),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 2.0),
                                        child: Container(
                                            color: Colors.white,
                                            height: 19,
                                            width: 110),
                                      ),
                                      Row(children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 3.0),
                                          child: Container(
                                              color: Colors.white,
                                              height: 20,
                                              width: 20),
                                        ),
                                        Container(
                                            color: Colors.white,
                                            height: 20,
                                            width: 25),
                                      ]),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          const Divider(
                            color: Color(0xFFF57C00),
                            thickness: 1.5,
                            endIndent: 30,
                            indent: 5,
                          ),
                        ],
                      ),
                    ),
                  );
                })
            : requestFailed == true
                ? retryWidget()
                : tvDetails!.episodes!.isEmpty
                    ? const Center(
                        child: Text('No episodes found :(',
                            style: kTextSmallHeaderStyle),
                      )
                    : ListView.builder(
                        itemCount: tvDetails!.episodes!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return EpisodeDetailPage(
                                    adult: widget.adult,
                                    seriesName: widget.seriesName,
                                    tvId: widget.tvId,
                                    episodes: tvDetails!.episodes,
                                    episodeList: tvDetails!.episodes![index]);
                              }));
                            },
                            child: Container(
                              color:const Color(0xFFFFFFFF),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 0.0,
                                  bottom: 8.0,
                                  left: 10,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(tvDetails!
                                            .episodes![index].episodeNumber!
                                            .toString()),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10.0, left: 5.0),
                                          child: SizedBox(
                                            height: 56.4,
                                            width: 100,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(6.0),
                                              child: tvDetails!.episodes![index]
                                                              .stillPath ==
                                                          null ||
                                                      tvDetails!
                                                          .episodes![index]
                                                          .stillPath!
                                                          .isEmpty
                                                  ? Image.asset(
                                                      'assets/images/na_logo.png',
                                                      fit: BoxFit.cover,
                                                    )
                                                  : CachedNetworkImage(
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
                                                      imageUrl:
                                                          TMDB_BASE_IMAGE_URL +
                                                              imageQuality +
                                                              tvDetails!
                                                                  .episodes![
                                                                      index]
                                                                  .stillPath!,
                                                      imageBuilder: (context,
                                                              imageProvider) =>
                                                          Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                            image:
                                                                imageProvider,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      placeholder: (context,
                                                              url) =>
                                                          Shimmer.fromColors(
                                                        baseColor: 
                                                           Colors
                                                                .grey.shade300,
                                                        highlightColor: Colors
                                                                .grey.shade100,
                                                        direction:
                                                            ShimmerDirection
                                                                .ltr,
                                                        child: Container(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Image.asset(
                                                        'assets/images/na_logo.png',
                                                        fit: BoxFit.cover,
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
                                                  tvDetails!
                                                      .episodes![index].name!,
                                                  style: const TextStyle(
                                                      overflow: TextOverflow
                                                          .ellipsis)),
                                              Text(
                                                tvDetails!.episodes![index]
                                                                .airDate ==
                                                            null ||
                                                        tvDetails!
                                                            .episodes![index]
                                                            .airDate!
                                                            .isEmpty
                                                    ? 'Air date unknown'
                                                    : '${DateTime.parse(tvDetails!.episodes![index].airDate!).day} ${DateFormat("MMMM").format(DateTime.parse(tvDetails!.episodes![index].airDate!))}, ${DateTime.parse(tvDetails!.episodes![index].airDate!).year}',
                                                style: TextStyle(
                                                  color:Colors.black54,
                                                ),
                                              ),
                                              Row(children: [
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 3.0),
                                                  child: Icon(
                                                    Icons.star,
                                                    size: 20,
                                                  ),
                                                ),
                                                Text(tvDetails!.episodes![index]
                                                    .voteAverage!
                                                    .toStringAsFixed(1))
                                              ]),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    const Divider(
                                      color: Color(0xFFF57C00),
                                      thickness: 1.5,
                                      endIndent: 30,
                                      indent: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }));
  }

  Widget retryWidget() {
    return Center(
      child: Container(
          width: double.infinity,
          color: const Color(0xFFFFFFFF),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/network-signal.png',
                  width: 60, height: 60),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('Please connect to the Internet and try again',
                    textAlign: TextAlign.center),
              ),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0x0DF57C00)),
                      maximumSize:
                          MaterialStateProperty.all(const Size(200, 60)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side:
                                  const BorderSide(color: Color(0xFFF57C00))))),
                  onPressed: () {
                    setState(() {
                      requestFailed = false;
                      tvDetails = null;
                    });
                    getData();
                  },
                  child: const Text('Retry')),
            ],
          )),
    );
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
                    side: const BorderSide(color: Color(0xFFF57C00))))),
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
      setState(() {
        tvImages = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    // final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.title!,
                  style: kTextHeaderStyle,
                ),
              ),
            ],
          ),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              height: 220,
              child: tvImages == null
                  ? detailImageShimmer()
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
                                                                detailImageImageSimmer(
                                                                    ),
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
                                                        ? '${tvImages!.poster!.length} Poster'
                                                        : '${tvImages!.poster!.length} Posters'),
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
                                                                detailImageImageSimmer(
                                                                    ),
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
                                                        ? '${tvImages!.backdrop!.length} Backdrop'
                                                        : '${tvImages!.backdrop!.length} Backdrops'),
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
      setState(() {
        tvVideos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool playButtonVisibility = true;
    // final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return Column(
      children: [
        tvVideos == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(widget.title!,
                        style:
                            kTextHeaderStyle /* style: widget.themeData!.textTheme.bodyText1*/
                        ),
                  ],
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(widget.title!,
                        style:
                            kTextHeaderStyle /*style: widget.themeData!.textTheme.bodyText1*/
                        ),
                  ),
                ],
              ),
        Container(
          child: SizedBox(
            width: double.infinity,
            height: 230,
            child: tvVideos == null
                ? detailVideoShimmer()
                : tvVideos!.result!.isEmpty
                    ? const SizedBox(
                        width: double.infinity,
                        height: 100,
                        child: Center(
                            child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No video found :(',
                              textAlign: TextAlign.center),
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
                                                        detailVideoImageShimmer(
                                                            ),
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

class TVSocialLinks extends StatefulWidget {
  final String? api;
  const TVSocialLinks({
    Key? key,
    this.api,
  }) : super(key: key);

  @override
  TVSocialLinksState createState() => TVSocialLinksState();
}

class TVSocialLinksState extends State<TVSocialLinks> {
  ExternalLinks? externalLinks;
  bool? isAllNull;
  @override
  void initState() {
    super.initState();
    moviesApi().fetchSocialLinks(widget.api!).then((value) {
      setState(() {
        externalLinks = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Social media links',
              style: kTextHeaderStyle,
            ),
            SizedBox(
              height: 55,
              width: double.infinity,
              child: externalLinks == null
                  ? socialMediaShimmer()
                  : externalLinks?.facebookUsername == null &&
                          externalLinks?.instagramUsername == null &&
                          externalLinks?.twitterUsername == null &&
                          externalLinks?.imdbId == null
                      ? const Center(
                          child: Text(
                            'This tv show doesn\'t have social media links provided :(',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color:const Color(0xFFDFDEDE),
                          ),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              SocialIconWidget(
                                isNull: externalLinks?.facebookUsername == null,
                                url: externalLinks?.facebookUsername == null
                                    ? ''
                                    : FACEBOOK_BASE_URL +
                                        externalLinks!.facebookUsername!,
                                icon: const Icon(
                                  SocialIcons.facebook_f,
                                  color: Color(0xFFF57C00),
                                ),
                              ),
                              SocialIconWidget(
                                isNull:
                                    externalLinks?.instagramUsername == null,
                                url: externalLinks?.instagramUsername == null
                                    ? ''
                                    : INSTAGRAM_BASE_URL +
                                        externalLinks!.instagramUsername!,
                                icon: const Icon(
                                  SocialIcons.instagram,
                                  color: Color(0xFFF57C00),
                                ),
                              ),
                              SocialIconWidget(
                                isNull: externalLinks?.twitterUsername == null,
                                url: externalLinks?.twitterUsername == null
                                    ? ''
                                    : TWITTER_BASE_URL +
                                        externalLinks!.twitterUsername!,
                                icon: const Icon(
                                  SocialIcons.twitter,
                                  color: Color(0xFFF57C00),
                                ),
                              ),
                              SocialIconWidget(
                                isNull: externalLinks?.imdbId == null,
                                url: externalLinks?.imdbId == null
                                    ? ''
                                    : IMDB_BASE_URL + externalLinks!.imdbId!,
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
      setState(() {
        tvDetails = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return Column(
      children: [
        const Text(
          'TV series Info',
          style: kTextHeaderStyle,
        ),
        Container(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: tvDetails == null
                  ? detailInfoTableShimmer()
                  : DataTable(dataRowHeight: 40, columns: [
                      const DataColumn(
                          label: Text(
                        'Original Title',
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
                        const DataCell(Text(
                          'Status',
                          style: kTableLeftStyle,
                        )),
                        DataCell(Text(tvDetails!.status!.isEmpty
                            ? 'unknown'
                            : tvDetails!.status!)),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text(
                          'Runtime',
                          style: kTableLeftStyle,
                        )),
                        DataCell(Text(tvDetails!.runtime!.isEmpty
                            ? '-'
                            : tvDetails!.runtime![0] == 0
                                ? 'N/A'
                                : '${tvDetails!.runtime![0]} mins')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text(
                          'Spoken languages',
                          style: kTableLeftStyle,
                        )),
                        DataCell(SizedBox(
                          height: 20,
                          width: 200,
                          child: tvDetails!.spokenLanguages!.isEmpty
                              ? const Text('-')
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: tvDetails!.spokenLanguages!.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 5.0),
                                      child: Text(tvDetails!
                                              .spokenLanguages!.isEmpty
                                          ? 'N/A'
                                          : '${tvDetails!.spokenLanguages![index].englishName},'),
                                    );
                                  },
                                ),
                        )),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text(
                          'Total seasons',
                          style: kTableLeftStyle,
                        )),
                        DataCell(Text(tvDetails!.numberOfSeasons! == 0
                            ? '-'
                            : '${tvDetails!.numberOfSeasons!}')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text(
                          'Total episodes',
                          style: kTableLeftStyle,
                        )),
                        DataCell(Text(tvDetails!.numberOfEpisodes! == 0
                            ? '-'
                            : '${tvDetails!.numberOfEpisodes!}')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text(
                          'Tagline',
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
                        const DataCell(Text(
                          'Production companies',
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
                                          ? 'N/A'
                                          : '${tvDetails!.productionCompanies![index].name},'),
                                    );
                                  },
                                ),
                        )),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text(
                          'Production countries',
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
                                          ? 'N/A'
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
    );
  }
}

class TVSeasonsTab extends StatefulWidget {
  final String? api;
  final int? tvId;
  final String? seriesName;
  final bool? adult;
  const TVSeasonsTab(
      {Key? key, this.api, this.tvId, this.seriesName, required this.adult})
      : super(key: key);

  @override
  TVSeasonsTabState createState() => TVSeasonsTabState();
}

class TVSeasonsTabState extends State<TVSeasonsTab>
    with AutomaticKeepAliveClientMixin<TVSeasonsTab> {
  TVDetails? tvDetails;
  bool requestFailed = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    tvApi().fetchTVDetails(widget.api!).then((value) {
      setState(() {
        tvDetails = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (tvDetails == null) {
        setState(() {
          requestFailed = true;
          tvDetails = TVDetails(seasons: [Seasons()]);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    super.build(context);
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    return tvDetails == null
        ? Container(
            color:const Color(0xFFFFFFFF),
            child: tvDetailsSeasonsTabShimmer())
        : tvDetails!.seasons!.isEmpty
            ? Container(
                color:
                    const Color(0xFFFFFFFF),
                child: const Center(
                  child: Text('There is no season available for this TV show',
                      style: kTextSmallHeaderStyle),
                ),
              )
            : requestFailed == true
                ? retryWidget()
                : Container(
                    color:const Color(0xFFFFFFFF),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                              itemCount: tvDetails!.seasons!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SeasonsDetail(
                                                adult: widget.adult,
                                                seriesName: widget.seriesName,
                                                tvId: widget.tvId,
                                                tvDetails: tvDetails!,
                                                seasons:
                                                    tvDetails!.seasons![index],
                                                heroId:
                                                    '${tvDetails!.seasons![index].seasonId}')));
                                  },
                                  child: Container(
                                    color:const Color(0xFFFFFFFF),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 0.0,
                                        bottom: 5.0,
                                        left: 15,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            // crossAxisAlignment:
                                            //     CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 30.0),
                                                child: SizedBox(
                                                  width: 85,
                                                  height: 130,
                                                  child: Hero(
                                                    tag:
                                                        '${tvDetails!.seasons![index].seasonId}',
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      child: tvDetails!
                                                                  .seasons![
                                                                      index]
                                                                  .posterPath ==
                                                              null
                                                          ? Image.asset(
                                                              'assets/images/na_logo.png',
                                                              fit: BoxFit.cover,
                                                            )
                                                          : CachedNetworkImage(
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
                                                                  tvDetails!
                                                                      .seasons![
                                                                          index]
                                                                      .posterPath!,
                                                              imageBuilder:
                                                                  (context,
                                                                          imageProvider) =>
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
                                                              placeholder: (context,
                                                                      url) =>
                                                                  recommendationAndSimilarTabImageShimmer(
                                                                      ),
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
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      tvDetails!.seasons![index]
                                                          .name!,
                                                      style: const TextStyle(
                                                          fontSize: 20,
                                                          fontFamily:
                                                              'PoppinsSB',
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                          Divider(
                                            color:Colors.white54,
                                            thickness: 1,
                                            endIndent: 20,
                                            indent: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ],
                    ));
  }

  Widget retryWidget() {
    return Center(
      child: Container(
          width: double.infinity,
          color:const Color(0xFFFFFFFF),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/network-signal.png',
                  width: 60, height: 60),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('Please connect to the Internet and try again',
                    textAlign: TextAlign.center),
              ),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0x0DF57C00)),
                      maximumSize:
                          MaterialStateProperty.all(const Size(200, 60)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side:
                                  const BorderSide(color: Color(0xFFF57C00))))),
                  onPressed: () {
                    setState(() {
                      requestFailed = false;
                      tvDetails = null;
                    });
                    getData();
                  },
                  child: const Text('Retry')),
            ],
          )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class TVCastTab extends StatefulWidget {
  final String? api;
  const TVCastTab({Key? key, this.api}) : super(key: key);

  @override
  TVCastTabState createState() => TVCastTabState();
}

class TVCastTabState extends State<TVCastTab>
    with AutomaticKeepAliveClientMixin<TVCastTab> {
  Credits? credits;
  bool requestFailed = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    moviesApi().fetchCredits(widget.api!).then((value) {
      setState(() {
        credits = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (credits == null) {
        setState(() {
          requestFailed = true;
          credits = Credits(cast: [Cast()]);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    return credits == null
        ? Container(
            color: const Color(0xFFFFFFFF),
            child: tvCastAndCrewTabShimmer())
        : credits!.cast!.isEmpty
            ? Container(
                color:
                    const Color(0xFFFFFFFF),
                child: const Center(
                  child: Text(
                      'There is no data available for this TV show cast',
                      style: kTextSmallHeaderStyle),
                ),
              )
            : requestFailed == true
                ? retryWidget()
                : Container(
                    color:const Color(0xFFFFFFFF),
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
                              color:const Color(0xFFFFFFFF),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 0.0,
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
                                              tag:
                                                  '${credits!.cast![index].name}',
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0),
                                                child: credits!.cast![index]
                                                            .profilePath ==
                                                        null
                                                    ? Image.asset(
                                                        'assets/images/na_square.png',
                                                        fit: BoxFit.cover,
                                                      )
                                                    : CachedNetworkImage(
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
                                                        imageUrl:
                                                            TMDB_BASE_IMAGE_URL +
                                                                imageQuality +
                                                                credits!
                                                                    .cast![
                                                                        index]
                                                                    .profilePath!,
                                                        imageBuilder: (context,
                                                                imageProvider) =>
                                                            Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            image:
                                                                DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        placeholder: (context,
                                                                url) =>
                                                            castAndCrewTabImageShimmer(
                                                                ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Image.asset(
                                                          'assets/images/na_sqaure.png',
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
                                                    fontFamily: 'PoppinsSB'),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                'As : '
                                                '${credits!.cast![index].roles![0].character!.isEmpty ? 'N/A' : credits!.cast![index].roles![0].character!}',
                                              ),
                                              Text(
                                                credits!.cast![index].roles![0]
                                                            .episodeCount! ==
                                                        1
                                                    ? '${credits!.cast![index].roles![0].episodeCount!} episode'
                                                    : '${credits!.cast![index].roles![0].episodeCount!} episodes',
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Divider(
                                      color: Colors.white54,
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

  Widget retryWidget() {
    return Center(
      child: Container(
          width: double.infinity,
          color: const Color(0xFFFFFFFF),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/network-signal.png',
                  width: 60, height: 60),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('Please connect to the Internet and try again',
                    textAlign: TextAlign.center),
              ),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0x0DF57C00)),
                      maximumSize:
                          MaterialStateProperty.all(const Size(200, 60)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side:
                                  const BorderSide(color: Color(0xFFF57C00))))),
                  onPressed: () {
                    setState(() {
                      requestFailed = false;
                      credits = null;
                    });
                    getData();
                  },
                  child: const Text('Retry')),
            ],
          )),
    );
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
  bool requestFailed = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    moviesApi().fetchCredits(widget.api!).then((value) {
      setState(() {
        credits = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (credits == null) {
        setState(() {
          requestFailed = true;
          credits = Credits(crew: [Crew()]);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    // final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return credits == null
        ? Container(
            color: const Color(0xFFFFFFFF),
            child: movieCastAndCrewTabShimmer())
        : credits!.crew!.isEmpty
            ? Container(
                color:
                  const Color(0xFFFFFFFF),
                child: const Center(
                  child: Text(
                      'There is no data available for this TV show cast',
                      style: kTextSmallHeaderStyle),
                ),
              )
            : requestFailed == true
                ? retryWidget()
                : Container(
                    color:const Color(0xFFFFFFFF),
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
                              color:const Color(0xFFFFFFFF),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 0.0,
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
                                              tag:
                                                  '${credits!.crew![index].name}',
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0),
                                                child: credits!.crew![index]
                                                            .profilePath ==
                                                        null
                                                    ? Image.asset(
                                                        'assets/images/na_square.png',
                                                        fit: BoxFit.cover,
                                                      )
                                                    : CachedNetworkImage(
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
                                                        imageUrl:
                                                            TMDB_BASE_IMAGE_URL +
                                                                imageQuality +
                                                                credits!
                                                                    .crew![
                                                                        index]
                                                                    .profilePath!,
                                                        imageBuilder: (context,
                                                                imageProvider) =>
                                                            Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            image:
                                                                DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        placeholder: (context,
                                                                url) =>
                                                            castAndCrewTabImageShimmer(
                                                                ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Image.asset(
                                                          'assets/images/na_sqaure.png',
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
                                                    fontFamily: 'PoppinsSB'),
                                              ),
                                              Text(
                                                'Job : '
                                                '${credits!.crew![index].department!.isEmpty ? 'N/A' : credits!.crew![index].department!}',
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Divider(
                                      color:Colors.white54,
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

  Widget retryWidget() {
    return Center(
      child: Container(
          width: double.infinity,
          color: const Color(0xFFFFFFFF),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/network-signal.png',
                  width: 60, height: 60),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('Please connect to the Internet and try again',
                    textAlign: TextAlign.center),
              ),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0x0DF57C00)),
                      maximumSize:
                          MaterialStateProperty.all(const Size(200, 60)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side:
                                  const BorderSide(color: Color(0xFFF57C00))))),
                  onPressed: () {
                    setState(() {
                      requestFailed = false;
                      credits = null;
                    });
                    getData();
                  },
                  child: const Text('Retry')),
            ],
          )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class TVRecommendationsTab extends StatefulWidget {
  final String api;
  final int tvId;
  final bool? includeAdult;
  const TVRecommendationsTab(
      {Key? key,
      required this.api,
      required this.tvId,
      required this.includeAdult})
      : super(key: key);

  @override
  TVRecommendationsTabState createState() => TVRecommendationsTabState();
}

class TVRecommendationsTabState extends State<TVRecommendationsTab>
    with AutomaticKeepAliveClientMixin {
  List<TV>? tvList;
  bool requestFailed = false;
  @override
  void initState() {
    super.initState();
    getData();
    getMoreData();
  }

  void getData() {
    tvApi().fetchTV('${widget.api}&include_adult=${widget.includeAdult}').then((value) {
      setState(() {
        tvList = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (tvList == null) {
        setState(() {
          requestFailed = true;
          tvList = [TV()];
        });
      }
    });
  }

  final _scrollController = ScrollController();

  int pageNum = 2;
  bool isLoading = false;

  Future<String> getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });

        var response = await http.get(Uri.parse(
            '$TMDB_API_BASE_URL/tv/${widget.tvId}/recommendations?api_key=$TMDB_API_KEY&include_adult=${widget.includeAdult}'
            '&language=en-US'
            '&page=$pageNum'));
        setState(() {
          pageNum++;
          isLoading = false;
          var newlistTV = (json.decode(response.body)['results'] as List)
              .map((i) => TV.fromJson(i))
              .toList();
          tvList!.addAll(newlistTV);
        });
      }
    });

    return "success";
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    return tvList == null
        ? Container(
            color:const Color(0xFFFFFFFF),
            child: detailsRecommendationsAndSimilarShimmer(
                _scrollController, isLoading))
        : tvList!.isEmpty
            ? Container(
                color:
                    const Color(0xFFFFFFFF),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                        'There is no recommendations available for this TV show',
                        textAlign: TextAlign.center,
                        style: kTextSmallHeaderStyle),
                  ),
                ),
              )
            : requestFailed == true
                ? retryWidget()
                : Container(
                    color:const Color(0xFFFFFFFF),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              itemCount: tvList!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return TVDetailPage(
                                        tvSeries: tvList![index],
                                        heroId: '${tvList![index].id}',
                                      );
                                    }));
                                  },
                                  child: Container(
                                    color: const Color(0xFFFFFFFF),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 0.0,
                                        bottom: 3.0,
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
                                                    right: 10.0),
                                                child: SizedBox(
                                                  width: 85,
                                                  height: 130,
                                                  child: Hero(
                                                    tag: '${tvList![index].id}',
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      child: tvList![index]
                                                                  .posterPath ==
                                                              null
                                                          ? Image.asset(
                                                              'assets/images/na_logo.png',
                                                              fit: BoxFit.cover,
                                                            )
                                                          : CachedNetworkImage(
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
                                                                  tvList![index]
                                                                      .posterPath!,
                                                              imageBuilder:
                                                                  (context,
                                                                          imageProvider) =>
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
                                                              placeholder: (context,
                                                                      url) =>
                                                                  recommendationAndSimilarTabImageShimmer(
                                                                      ),
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
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      tvList![index].name!,
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              'PoppinsSB',
                                                          fontSize: 15,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        const Icon(Icons.star,
                                                            color: Color(
                                                                0xFFF57C00)),
                                                        Text(
                                                          tvList![index]
                                                              .voteAverage!
                                                              .toStringAsFixed(
                                                                  1),
                                                          style: const TextStyle(
                                                              fontFamily:
                                                                  'Poppins'),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                          Divider(
                                            color: Colors.white54,
                                            thickness: 1,
                                            endIndent: 20,
                                            indent: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                        Visibility(
                            visible: isLoading,
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: CircularProgressIndicator()),
                            )),
                      ],
                    ));
  }

  Widget retryWidget() {
    return Center(
      child: Container(
          width: double.infinity,
          color: const Color(0xFFFFFFFF),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/network-signal.png',
                  width: 60, height: 60),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('Please connect to the Internet and try again',
                    textAlign: TextAlign.center),
              ),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0x0DF57C00)),
                      maximumSize:
                          MaterialStateProperty.all(const Size(200, 60)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side:
                                  const BorderSide(color: Color(0xFFF57C00))))),
                  onPressed: () {
                    setState(() {
                      requestFailed = false;
                      tvList = null;
                    });
                    getData();
                  },
                  child: const Text('Retry')),
            ],
          )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
