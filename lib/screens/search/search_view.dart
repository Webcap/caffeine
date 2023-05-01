import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:login/api/endpoints.dart';
import 'package:login/api/movies_api.dart';
import 'package:login/api/peoples_api.dart';
import 'package:login/api/tv_api.dart';
import 'package:login/models/movie_models.dart';
import 'package:login/models/person.dart';
import 'package:login/models/tv.dart';
import 'package:login/provider/imagequality_provider.dart';
import 'package:login/provider/settings_provider.dart';
import 'package:login/screens/movie_screens/movie_details.dart';
import 'package:login/screens/search/searched_person.dart';
import 'package:login/screens/tv_screens/tv_detail_page.dart';
import 'package:login/utils/config.dart';
import 'package:login/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class Search extends SearchDelegate<String> {
  // final Mixpanel mixpanel;
  final bool includeAdult;
  Search({required this.includeAdult})
      : super(
          searchFieldLabel: 'Search for a movie, TV show or a person',
        );

  @override
  ThemeData appBarTheme(BuildContext context) {
    // final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return ThemeData(
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFDFDEDE),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.black26, fontFamily: 'Poppins'),
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
      textTheme: TextTheme(
        headline6: TextStyle(color: Colors.black, fontFamily: 'Poppins'),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: maincolor2,
        selectionHandleColor: const Color(0xFF000000),
        selectionColor: Colors.black12,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(
          Icons.clear,
          color: maincolor2,
        ),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: maincolor2),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        body: Container(
          // color: isDark ? const Color(0xFF202124) : const Color(0xFFDFDEDE),
          child: Column(
            children: [
              TabBar(
                indicatorColor: maincolor,
                tabs: [
                  Tab(
                    child: Text('Movies',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: const Color(0xFFDFDEDE),
                        )),
                  ),
                  Tab(
                    child: Text('TV Shows',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: const Color(0xFFDFDEDE),
                        )),
                  ),
                  Tab(
                    child: Text('Person',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: const Color(0xFFDFDEDE),
                        )),
                  )
                ],
              ),
              Expanded(
                  child: TabBarView(children: [
                FutureBuilder<List<Movie>>(
                  future: moviesApi().fetchMovies(
                      Endpoints.movieSearchUrl(query, includeAdult)),
                  builder: (context, snapshot) {
                    if (query.isEmpty) return searchATermWidget();

                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return searchSuggestionVerticalScrollShimmer();
                      default:
                        if (snapshot.hasError || snapshot.data!.isEmpty) {
                          return errorMessageWidget();
                        } else {
                          return activeMovieSearch(snapshot.data!, context);
                        }
                    }
                  },
                ),
                FutureBuilder<List<TV>>(
                  future: tvApi()
                      .fetchTV(Endpoints.tvSearchUrl(query, includeAdult)),
                  builder: (context, snapshot) {
                    if (query.isEmpty) return searchATermWidget();

                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return searchSuggestionVerticalScrollShimmer();
                      default:
                        if (snapshot.hasError || snapshot.data!.isEmpty) {
                          return errorMessageWidget();
                        } else {
                          return activeTVSearch(snapshot.data!, context);
                        }
                    }
                  },
                ),
                FutureBuilder<List<Person>>(
                  future: peoplesApi().fetchPerson(
                      Endpoints.personSearchUrl(query, includeAdult)),
                  builder: (context, snapshot) {
                    if (query.isEmpty) return searchATermWidget();
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return searchedPersonShimmer();
                      default:
                        if (snapshot.hasError || snapshot.data!.isEmpty) {
                          return errorMessageWidget();
                        } else {
                          return activePersonSearch(snapshot.data!, context);
                        }
                    }
                  },
                ),
              ])),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchSuggestionVerticalScrollShimmer() => Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: 10,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 0.0,
                          bottom: 3.0,
                          left: 10,
                        ),
                        child: Column(
                          children: [
                            Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              direction: ShimmerDirection.ltr,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: SizedBox(
                                      width: 85,
                                      height: 130,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Container(
                                              height: 20,
                                              width: 150,
                                              color: Colors.white),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 1.0),
                                              child: Container(
                                                height: 20,
                                                width: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Container(
                                                height: 20,
                                                width: 30,
                                                color: Colors.white),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
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
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ],
      ));

  Widget searchedPersonShimmer() => Container(
      color: Colors.white,
      child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: 10,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 3.0,
                  bottom: 3.0,
                  left: 15,
                ),
                child: Column(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      direction: ShimmerDirection.ltr,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100.0),
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 20,
                                  width: 140,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          )
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
                ),
              ),
            );
          }));

  Widget errorMessageWidget() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/404.png'),
            Text(
              'The term you entered didn\'t bring any results',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.black),
            )
          ],
        ),
      ),
    );
  }

  Widget searchATermWidget() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/search.png'),
            const Padding(padding: EdgeInsets.only(top: 10, bottom: 5)),
            Text('Enter a word to search',
                style: TextStyle(color: Colors.black, fontFamily: 'Poppins'))
          ],
        ),
      ),
    );
  }

  Widget activeMovieSearch(List<Movie> moviesList, BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: moviesList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          // mixpanel
                          //     .track('Most viewed movie pages', properties: {
                          //   'Movie name': '${moviesList[index].originalTitle}',
                          //   'Movie id': '${moviesList[index].id}'
                          // });
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return MovieDetailPage(
                              movie: moviesList[index],
                              heroId: '${moviesList[index].id}',
                            );
                          }));
                        },
                        child: Container(
                          color: Colors.white,
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
                                          const EdgeInsets.only(right: 10.0),
                                      child: SizedBox(
                                        width: 85,
                                        height: 130,
                                        child: Hero(
                                          tag: '${moviesList[index].id}',
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: moviesList[index]
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
                                                    fadeOutCurve:
                                                        Curves.easeOut,
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 700),
                                                    fadeInCurve: Curves.easeIn,
                                                    imageUrl:
                                                        TMDB_BASE_IMAGE_URL +
                                                            imageQuality +
                                                            moviesList[index]
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
                                                    placeholder: (context,
                                                            url) =>
                                                        scrollingImageShimmer(),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      'assets/images/na_logo.png',
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
                                            moviesList[index].title!,
                                            style: TextStyle(
                                                fontFamily: 'PoppinsSB',
                                                fontSize: 15,
                                                overflow: TextOverflow.ellipsis,
                                                color: Colors.black),
                                          ),
                                          Row(
                                            children: <Widget>[
                                              const Icon(Icons.star,
                                                  color: Color(0xFFF57C00)),
                                              Text(
                                                moviesList[index]
                                                    .voteAverage!
                                                    .toStringAsFixed(1),
                                                style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    color: Colors.black),
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
            ),
          ],
        ));
  }

  Widget activeTVSearch(List<TV> tvList, BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: tvList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return TVDetailPage(
                                tvSeries: tvList[index],
                                heroId: '${tvList[index].id}');
                          }));
                        },
                        child: Container(
                          color: Colors.white,
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
                                          const EdgeInsets.only(right: 10.0),
                                      child: SizedBox(
                                        width: 85,
                                        height: 130,
                                        child: Hero(
                                          tag: '${tvList[index].id}',
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: tvList[index].posterPath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_logo.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
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
                                                            tvList[index]
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
                                                    placeholder: (context,
                                                            url) =>
                                                        scrollingImageShimmer(),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      'assets/images/na_logo.png',
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
                                            tvList[index].originalName!,
                                            style: TextStyle(
                                                fontFamily: 'PoppinsSB',
                                                fontSize: 15,
                                                overflow: TextOverflow.ellipsis,
                                                color: Colors.black),
                                          ),
                                          Row(
                                            children: <Widget>[
                                              const Icon(Icons.star,
                                                  color: Color(0xFFF57C00)),
                                              Text(
                                                tvList[index]
                                                    .voteAverage!
                                                    .toStringAsFixed(1),
                                                style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    color: Colors.black),
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
            ),
          ],
        ));
  }

  Widget activePersonSearch(List<Person>? personList, BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return Container(
        color: Colors.white,
        child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: personList!.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return SearchedPersonDetailPage(
                        person: personList[index],
                        heroId: '${personList[index].id}');
                  }));
                },
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 3.0,
                      bottom: 3.0,
                      left: 15,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: SizedBox(
                                width: 80,
                                height: 80,
                                child: Hero(
                                  tag: '${personList[index].id}',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100.0),
                                    child: personList[index].profilePath == null
                                        ? Image.asset(
                                            'assets/images/na_square.png',
                                            fit: BoxFit.cover,
                                          )
                                        : CachedNetworkImage(
                                            fadeOutDuration: const Duration(
                                                milliseconds: 300),
                                            fadeOutCurve: Curves.easeOut,
                                            fadeInDuration: const Duration(
                                                milliseconds: 700),
                                            fadeInCurve: Curves.easeIn,
                                            imageUrl: TMDB_BASE_IMAGE_URL +
                                                imageQuality +
                                                personList[index].profilePath!,
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
                                                detailCastImageShimmer(),
                                            errorWidget:
                                                (context, url, error) =>
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    personList[index].name!,
                                    style: TextStyle(
                                        fontFamily: 'PoppinsSB',
                                        fontSize: 17,
                                        color: Colors.black),
                                    overflow: TextOverflow.ellipsis,
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

  Widget buildSuggestionsSuccess(List<TV> moviesList) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        body: Column(
          children: const [
            TabBar(
              tabs: [
                Tab(
                  text: 'Movies',
                ),
                Tab(
                  text: 'TV',
                ),
                Tab(
                  text: 'Person',
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
