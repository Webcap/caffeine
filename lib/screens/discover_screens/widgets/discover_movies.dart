// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:login/api/movies_api.dart';
// import 'package:login/models/dropdown_select.dart';
// import 'package:login/models/filter_chip.dart';
// import 'package:login/models/movie_models.dart';
// import 'package:login/screens/movie_screens/widgets/movie_details_screen.dart';
// import 'package:login/utils/config.dart';

// class DiscoverMovies extends StatefulWidget {
//   const DiscoverMovies({super.key});

//   @override
//   State<DiscoverMovies> createState() => _DiscoverMoviesState();
// }

// class _DiscoverMoviesState extends State<DiscoverMovies>
//     with AutomaticKeepAliveClientMixin {
//   List<Movie>? movieList;

//   late double deviceHeight;
//   bool requestFailed = false;
//   YearDropdownData yearDropdownData = YearDropdownData();
//   MovieGenreFilterChipData movieGenreFilterChipData =
//       MovieGenreFilterChipData();

//   @override
//   void initState() {
//     super.initState();
//     getData();
//   }

//   void getData() {
//     List<String> years = yearDropdownData.yearsList.getRange(1, 24).toList();
//     List<MovieGenreFilterChipWidget> genres =
//         movieGenreFilterChipData.movieGenreFilterdata;
//     years.shuffle();
//     genres.shuffle();
//     moviesApi()
//         .fetchMovies(
//             "$TMDB_API_BASE_URL/discover/movie?api_key=$TMDB_API_KEY&sort_by=popularity.desc&watch_region=US&include_adult=false&primary_release_year=${years.first}&with_genres=${genres.first.genreValue}")
//         .then((value) {
//       setState(() {
//         movieList = value;
//       });
//     });
//     Future.delayed(const Duration(seconds: 11), () {
//       if (movieList == null) {
//         setState(() {
//           requestFailed = true;
//           movieList = [];
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     deviceHeight = MediaQuery.of(context).size.height;

//     return Column(
//       children: <Widget>[
//         Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: const <Widget>[
//             Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Text('Featured movies', style: kTextHeaderStyle,
//             ),
//             ),
//           ],
//         ),
//         SizedBox(
//           width: double.infinity,
//           height: 350,
//           child: movieList == null
//             ? discoverMoviesAndTVShimmer(),
//             : requestFailed == true
//                ? retryWidget()
//                : CarouselSlider.builder(
//                   options: CarouselOptions(
//                     disableCenter: true,
//                     viewportFraction: 0.6,
//                     enlargeCenterPage: true,
//                     autoPlay: true,
//                   ),
//                   itemBuilder: (BuildContext context, int index, pageViewIndex) {
//                     return Container(
//                       child: GestureDetector(
//                         onTap: () {
//                           Navigator.push(context, MaterialPageRoute(builder: (context) => moviedetails(id: movieList![index].id)));
//                         }
//                       ),
//                     );
//                   },
//                )
//         )
//       ]
//     );
//   }
// }
