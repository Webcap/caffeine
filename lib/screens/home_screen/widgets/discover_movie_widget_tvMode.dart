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
import 'package:login/provider/settings_provider.dart';
import 'package:login/screens/movie_screens/movie_details.dart';
import 'package:login/screens/home_screen/widgets/slide_item_widget.dart';
import 'package:login/utils/config.dart';
import 'package:login/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DiscoverMoviesTVMode extends StatefulWidget {
  int posty;
  int postx;
  CarouselController carouselController;

  DiscoverMoviesTVMode({
    Key? key,
    required this.posty,
    required this.postx,
    required this.carouselController,
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
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    // final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
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
              // slider position bubble
              Positioned(
                bottom: 10,
                right: 50,
                child: AnimatedOpacity(
                  opacity: (widget.posty < 0) ? 1 : 0,
                  duration: Duration(milliseconds: 200),
                  child: AnimatedSmoothIndicator(
                    activeIndex: 0,
                    count: 5,
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
                    itemCount: 5,
                    carouselController: widget.carouselController,
                    options: CarouselOptions(
                        autoPlay: true,
                        viewportFraction: 1,
                        onPageChanged: (index, reason) {
                          // setState(() {
                          //   widget.side_current = index;
                          // });
                          // widget.move(index);
                        }),
                    itemBuilder: (ctx, index, realIdx) {
                      return Text(
                        "fuck youuuu",
                        style: TextStyle(color: Colors.white),
                      );
                      // return SlideItemWidget(
                      //     index: index, slide: widget.slides[index]);
                    },
                  ),
                ),
              ),
            ],
          ),
        ));
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
