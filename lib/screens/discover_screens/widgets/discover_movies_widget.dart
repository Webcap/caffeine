import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:login/api/movies_api.dart';
import 'package:login/models/dropdown_select.dart';
import 'package:login/models/filter_chip.dart';
import 'package:login/models/movie_models.dart';
import 'package:login/provider/imagequality_provider.dart';
import 'package:login/screens/movie_screens/widgets/movie_details_screen.dart';
import 'package:login/utils/config.dart';
import 'package:login/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';

class DiscoverMovies extends StatefulWidget {
  const DiscoverMovies({Key? key,})
      : super(key: key);
  @override
  DiscoverMoviesState createState() => DiscoverMoviesState();
}

class DiscoverMoviesState extends State<DiscoverMovies>
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
    moviesApi().fetchMovies(
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
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Featured movies',
                style: kTextHeaderStyle,
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          height: 350,
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
                            child: Hero(
                              tag: '${moviesList![index].id}discover',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: CachedNetworkImage(
                                  fadeOutDuration:
                                      const Duration(milliseconds: 300),
                                  fadeOutCurve: Curves.easeOut,
                                  fadeInDuration:
                                      const Duration(milliseconds: 700),
                                  fadeInCurve: Curves.easeIn,
                                  imageUrl:
                                      moviesList![index].posterPath == null
                                          ? ''
                                          : TMDB_BASE_IMAGE_URL +
                                              imageQuality +
                                              moviesList![index].posterPath!,
                                  imageBuilder: (context, imageProvider) =>
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
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    'assets/images/na_logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: moviesList!.length,
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
