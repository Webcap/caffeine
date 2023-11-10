import 'package:cached_network_image/cached_network_image.dart';
import 'package:caffiene/widgets/common_widgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/movies_api.dart';
import 'package:caffiene/models/dropdown_select.dart';
import 'package:caffiene/models/filter_chip.dart';
import 'package:caffiene/models/movie_models.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/movie_screens/movie_details.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';

class DiscoverMovies extends StatefulWidget {
  const DiscoverMovies({Key? key, required this.includeAdult})
      : super(key: key);
  final bool includeAdult;
  @override
  DiscoverMoviesState createState() => DiscoverMoviesState();
}

class DiscoverMoviesState extends State<DiscoverMovies>
    with AutomaticKeepAliveClientMixin {
  List<Movie>? moviesList;
  late double deviceHeight;
  YearDropdownData yearDropdownData = YearDropdownData();
  @override
  void initState() {
    super.initState();
    getData();
  }

  List<MovieGenreFilterChipWidget> movieGenreFilterdata =
      <MovieGenreFilterChipWidget>[
    MovieGenreFilterChipWidget(genreName: tr('action'), genreValue: '28'),
    MovieGenreFilterChipWidget(genreName: tr('adventure'), genreValue: '12'),
    MovieGenreFilterChipWidget(genreName: tr('animation'), genreValue: '16'),
    MovieGenreFilterChipWidget(genreName: tr('comedy'), genreValue: '35'),
    MovieGenreFilterChipWidget(genreName: tr('crime'), genreValue: '80'),
    MovieGenreFilterChipWidget(genreName: tr('documentary'), genreValue: '99'),
    MovieGenreFilterChipWidget(genreName: tr('drama'), genreValue: '18'),
    MovieGenreFilterChipWidget(genreName: tr('family'), genreValue: '10751'),
    MovieGenreFilterChipWidget(genreName: tr('fantasy'), genreValue: '14'),
    MovieGenreFilterChipWidget(genreName: tr('history'), genreValue: '36'),
    MovieGenreFilterChipWidget(genreName: tr('horror'), genreValue: '27'),
    MovieGenreFilterChipWidget(genreName: tr('music'), genreValue: '10402'),
    MovieGenreFilterChipWidget(genreName: tr('mystery'), genreValue: '9648'),
    MovieGenreFilterChipWidget(genreName: tr('romance'), genreValue: '10749'),
    MovieGenreFilterChipWidget(
        genreName: tr('science_fiction'), genreValue: '878'),
    MovieGenreFilterChipWidget(genreName: tr('tv_movie'), genreValue: '10770'),
    MovieGenreFilterChipWidget(genreName: tr('thriller'), genreValue: '53'),
    MovieGenreFilterChipWidget(genreName: tr('war'), genreValue: '10752'),
    MovieGenreFilterChipWidget(genreName: tr('western'), genreValue: '37'),
  ];

  void getData() {
    List<String> years = yearDropdownData.yearsList.getRange(1, 25).toList();
    List<MovieGenreFilterChipWidget> genres = movieGenreFilterdata;
    years.shuffle();
    genres.shuffle();
    moviesApi()
        .fetchMovies(
            '$TMDB_API_BASE_URL/discover/movie?api_key=$TMDB_API_KEY&sort_by=popularity.desc&watch_region=US&include_adult=${widget.includeAdult}&primary_release_year=${years.first}&with_genres=${genres.first.genreValue}')
        .then((value) {
      if (mounted) {
        setState(() {
          moviesList = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    deviceHeight = MediaQuery.of(context).size.height;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const LeadingDot(),
                    Expanded(
                      child: Text(
                        tr('featured_movies'),
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
          height: 350,
          // height: deviceHeight * 0.417,
          child: moviesList == null
              ? discoverMoviesAndTVShimmer1(themeMode)
              : moviesList!.isEmpty
                  ? Center(
                      child: Text(
                        tr("wow_odd"),
                        style: kTextSmallBodyStyle,
                      ),
                    )
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
                                  cacheManager: cacheProp(),
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
                                      discoverImageShimmer1(themeMode),
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

  @override
  bool get wantKeepAlive => true;
}
