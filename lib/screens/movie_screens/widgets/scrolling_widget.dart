import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:login/api/movies_api.dart';
import 'package:login/models/movie_models.dart';
import 'package:login/provider/imagequality_provider.dart';
import 'package:login/provider/settings_provider.dart';
import 'package:login/screens/movie_screens/widgets/main_movie_list.dart';
import 'package:login/screens/movie_screens/movie_details.dart';
import 'package:login/utils/config.dart';
import 'package:login/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ScrollingMovies extends StatefulWidget {
  final String api, title;
  final dynamic discoverType;
  final bool isTrending;

  const ScrollingMovies({
    Key? key,
    required this.api,
    required this.title,
    this.discoverType,
    required this.isTrending,
  }) : super(key: key);
  @override
  ScrollingMoviesState createState() => ScrollingMoviesState();
}

class ScrollingMoviesState extends State<ScrollingMovies>
    with AutomaticKeepAliveClientMixin {
  late int index;
  List<Movie>? moviesList;
  final ScrollController _scrollController = ScrollController();

  int pageNum = 2;
  bool isLoading = false;

  void getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });
        if (mounted) {
          moviesApi()
              .fetchMovies('${widget.api}&include_adult=false&page=$pageNum')
              .then((value) {
            if (mounted) {
              setState(() {
                moviesList!.addAll(value);
                isLoading = false;
                pageNum++;
              });
            }
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    moviesApi().fetchMovies('${widget.api}&include_adult=false').then((value) {
      if (mounted) {
        setState(() {
          moviesList = value;
        });
      }
    });
    getMoreData();
  }

  // void getData() {
  //   moviesApi().fetchMovies('${widget.api}&include_adult=false').then((value) {
  //     setState(() {
  //       moviesList = value;
  //     });
  //   });
  //   Future.delayed(const Duration(seconds: 11), () {
  //     if (moviesList == null) {
  //       setState(() {
  //         requestFailed = true;
  //         moviesList = [Movie()];
  //       });
  //     }
  //   });
  // }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.title,
                style: kTextHeaderStyle,
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return MainMoviesList(
                        title: widget.title,
                        api: widget.api,
                        discoverType: widget.discoverType.toString(),
                        isTrending: widget.isTrending,
                      );
                    }));
                  },
                  style: ButtonStyle(
                      maximumSize:
                          MaterialStateProperty.all(const Size(200, 60)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side:
                                  const BorderSide(color: Color(0xFFF57C00))))),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Text('View all'),
                  ),
                )),
          ],
        ),
        SizedBox(
          width: double.infinity,
          height: 250,
          child: moviesList == null
              ? scrollingMoviesAndTVShimmer1(isDark)
              : Row(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: moviesList!.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MovieDetailPage(
                                            movie: moviesList![index],
                                            heroId:
                                                '${moviesList![index].id}${widget.title}')));
                              },
                              child: SizedBox(
                                width: 100,
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 6,
                                      child: Hero(
                                        tag:
                                            '${moviesList![index].id}${widget.title}',
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: moviesList![index]
                                                        .posterPath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_logo.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 300),
                                                    fadeOutCurve: Curves.easeOut,
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 700),
                                                    fadeInCurve: Curves.easeIn,
                                                    imageUrl: moviesList![index]
                                                                .posterPath ==
                                                            null
                                                        ? ''
                                                        : TMDB_BASE_IMAGE_URL +
                                                            imageQuality +
                                                            moviesList![index]
                                                                .posterPath!,
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
                                                    placeholder: (context, url) =>
                                                        scrollingImageShimmer1(
                                                            isDark),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      'assets/images/na_logo.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                          ),
                                          Positioned(
                                              top: 0,
                                              left: 0,
                                              child: Container(
                                                margin: const EdgeInsets.all(3),
                                                alignment: Alignment.topLeft,
                                                width: 50,
                                                height: 25,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color: isDark
                                                        ? Colors.black45
                                                        : Colors.white60),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.star,
                                                    ),
                                                    Text(moviesList![index]
                                                        .voteAverage!
                                                        .toStringAsFixed(1))
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          moviesList![index].title!,
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
                    Visibility(
                      visible: isLoading,
                      child: SizedBox(
                        width: 110,
                        child: horizontalLoadMoreShimmer1(isDark),
                      ),
                    ),
                  ],
                ),
        ),
        Divider(
          color: Colors.white54,
          thickness: 1,
          endIndent: 20,
          indent: 10,
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
