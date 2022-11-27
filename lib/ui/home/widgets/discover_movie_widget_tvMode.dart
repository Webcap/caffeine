import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:login/api/movies_api.dart';
import 'package:login/models/channel.dart';
import 'package:login/models/dropdown_select.dart';
import 'package:login/models/filter_chip.dart';
import 'package:login/models/movie_models.dart';
import 'package:login/models/poster.dart';
import 'package:login/models/slide.dart';
import 'package:login/provider/imagequality_provider.dart';
import 'package:login/screens/movie_screens/movie_details_screen.dart';
import 'package:login/ui/home/widgets/slide_item_widget.dart';
import 'package:login/utils/config.dart';
import 'package:login/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DiscoverMoviesTVMode extends StatefulWidget {
  int posty;
  int postx;

  DiscoverMoviesTVMode({
    Key? key,
    required this.posty,
    required this.postx,
  }) : super(key: key);
  @override
  DiscoverMoviesTVModeState createState() => DiscoverMoviesTVModeState();
}

class DiscoverMoviesTVModeState extends State<DiscoverMoviesTVMode>
    with AutomaticKeepAliveClientMixin {
  List<Movie>? moviesList;
  late double deviceHeight;
  bool requestFailed = false;
  YearDropdownData yearDropdownData = YearDropdownData();
  MovieGenreFilterChipData movieGenreFilterChipData =
      MovieGenreFilterChipData();
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    List<String> years = yearDropdownData.yearsList.getRange(1, 24).toList();
    List<MovieGenreFilterChipWidget> genres =
        movieGenreFilterChipData.movieGenreFilterdata;
    years.shuffle();
    genres.shuffle();
    moviesApi()
        .fetchMovies(
            '$TMDB_API_BASE_URL/discover/movie?api_key=$TMDB_API_KEY&sort_by=popularity.desc&watch_region=US&include_adult=false&primary_release_year=${years.first}&with_genres=${genres.first.genreValue}')
        .then((value) {
      setState(() {
        moviesList = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (moviesList == null) {
        setState(() {
          requestFailed = true;
          moviesList = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    deviceHeight = MediaQuery.of(context).size.height;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    // final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return Column(
      children: <Widget>[
        SizedBox(
          height: 75,
        ),
        Positioned(
          right: 0,
          top: 0,
          left: MediaQuery.of(context).size.width / 4,
          bottom: MediaQuery.of(context).size.width / 4,
          child: SizedBox(
            width: double.infinity,
            height: 250,
            // height: deviceHeight * 0.417,
            child: moviesList == null
                ? discoverMoviesAndTVShimmer()
                : requestFailed == true
                    ? retryWidget()
                    : CarouselSlider.builder(
                        options: CarouselOptions(
                          disableCenter: true,
                          viewportFraction: 0.6,
                          enlargeCenterPage: true,
                          autoPlay: true,
                        ),
                        itemBuilder:
                            (BuildContext context, int index, pageViewIndex) {
                          return Container(
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MovieDetailPage(
                                              movie: moviesList![index],
                                              heroId:
                                                  '${moviesList![index].id}discover')));
                                },
                                child: Stack(
                                  children: [
                                    AnimatedPositioned(
                                      top: (widget.posty < 0) ? 40 : 30,
                                      left: 0,
                                      right: 0,
                                      height: (widget.posty < 0)
                                          ? (MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  2) -
                                              5
                                          : (MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  2) -
                                              45,
                                      duration: Duration(microseconds: 200),
                                      child: Container(
                                        height: (widget.posty < 0)
                                            ? (MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    2) -
                                                5
                                            : (MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    2) -
                                                45,
                                        child: Stack(children: [
                                          Hero(
                                            tag:
                                                '${moviesList![index].id}discover',
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: CachedNetworkImage(
                                                fadeOutDuration: const Duration(
                                                    milliseconds: 300),
                                                fadeOutCurve: Curves.easeOut,
                                                fadeInDuration: const Duration(
                                                    milliseconds: 700),
                                                fadeInCurve: Curves.easeIn,
                                                imageUrl: moviesList![index]
                                                            .backdropPath ==
                                                        null
                                                    ? ''
                                                    : TMDB_BASE_IMAGE_URL +
                                                        imageQuality +
                                                        moviesList![index]
                                                            .backdropPath!,
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        Container(
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                placeholder: (context, url) =>
                                                    discoverImageShimmer(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  'assets/images/na_logo.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Text(moviesList![index].title!, style: TextStyle(color: Colors.white),)
                                        ]),
                                      ),
                                    ),
                                  ],
                                )),
                          );
                        },
                        itemCount: moviesList!.length,
                      ),
          ),
        ),
      ],
    );
  }

  Widget retryWidget() {
    return Center(
      child: Container(
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
                  maximumSize: MaterialStateProperty.all(const Size(200, 60)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          side: const BorderSide(color: Color(0xFFF57C00))))),
              onPressed: () {
                setState(() {
                  requestFailed = false;
                  moviesList = null;
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

class TVModeDiscoverSlider extends StatefulWidget {
  CarouselController carouselController;
  int posty;
  int postx;
  int side_current;
  List<Slide> slides;
  Function move;
  Poster poster;
  Channel channel;

  TVModeDiscoverSlider(
      {Key? key,
      required this.carouselController,
      required this.posty,
      required this.postx,
      required this.slides,
      required this.side_current,
      required this.move,
      required this.poster,
      required this.channel})
      : super(key: key);

  @override
  State<TVModeDiscoverSlider> createState() => _TVModeDiscoverSliderState();
}

class _TVModeDiscoverSliderState extends State<TVModeDiscoverSlider> {
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      top: (widget.posty < 0) ? 70 : 40,
      left: 0,
      right: 0,
      height: (widget.posty < 0)
          ? (MediaQuery.of(context).size.height / 2) - 5
          : (MediaQuery.of(context).size.height / 2) - 45,
      duration: Duration(milliseconds: 200),
      child: Container(
        height: (widget.posty < 0)
            ? (MediaQuery.of(context).size.height / 2) - 5
            : (MediaQuery.of(context).size.height / 2) - 45,
        child: Stack(
          children: [
            Positioned(
              bottom: 10,
              right: 50,
              child: AnimatedOpacity(
                opacity: (widget.posty < 0) ? 1 : 0,
                duration: Duration(milliseconds: 200),
                child: AnimatedSmoothIndicator(
                  activeIndex: widget.side_current,
                  count: widget.slides.length,
                  effect: ExpandingDotsEffect(
                      dotHeight: 7,
                      dotWidth: 7,
                      dotColor: Colors.white24,
                      activeDotColor: Colors.purple),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: (widget.posty < 0) ? 1 : 0,
              duration: Duration(milliseconds: 200),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: CarouselSlider.builder(
                  itemCount: widget.slides.length,
                  carouselController: widget.carouselController,
                  options: CarouselOptions(
                      autoPlay: true,
                      viewportFraction: 1,
                      onPageChanged: ((index, reason) {
                        setState(() {
                          widget.side_current = index;
                        });
                        widget.move(index);
                      })),
                  itemBuilder: (context, index, realIndex) {
                    return SlideItemWidget(
                        index: index, slide: widget.slides[index]);
                  },
                ),
              ),
            ),
            // AnimatedOpacity(
            //   opacity: (widget.posty < 0) ? 0 : 1,
            //   duration: Duration(milliseconds: 200),
            //   child: Container(
            //     width: MediaQuery.of(context).size.width,
            //     child: MovieDetailWidget(poster: widget.poster),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
