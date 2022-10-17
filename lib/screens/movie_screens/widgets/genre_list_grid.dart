import 'package:flutter/material.dart';
import 'package:login/api/movies_api.dart';
import 'package:login/models/genre_movies.dart';
import 'package:login/models/genres.dart';
import 'package:login/models/movie_models.dart';
import 'package:login/utils/config.dart';
import 'package:login/widgets/shimmer_widget.dart';

class GenreListGrid extends StatefulWidget {
  final String api;
  const GenreListGrid({
    Key? key,
    required this.api,
  }) : super(key: key);

  @override
  GenreListGridState createState() => GenreListGridState();
}

class GenreListGridState extends State<GenreListGrid>
    with AutomaticKeepAliveClientMixin<GenreListGrid> {
  List<Genres>? genreList;
  bool requestFailed = false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    moviesApi().fetchGenre(widget.api).then((value) {
      setState(() {
        genreList = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (genreList == null) {
        setState(() {
          requestFailed = true;
          genreList = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Genres',
                style: kTextHeaderStyle,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0),
          child: SizedBox(
            width: double.infinity,
            height: 80,
            child: genreList == null
                ? genreListGridShimmer()
                : requestFailed == true
                    ? retryWidget()
                    : Row(
                        children: [
                          Expanded(
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: genreList!.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return GenreMovies(
                                            genres: genreList![index]);
                                      }));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        width: 125,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: maincolor2,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Text(
                                          genreList![index].genreName!,
                                          style: const TextStyle(
                                              color: Colors.white),
                                          textAlign: TextAlign.center,
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
      ],
    );
  }

  Widget retryWidget() {
    return Center(
      child: Container(
          child: Row(
        children: [
          Image.asset('assets/images/network-signal.png',
              width: 50, height: 50),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                      genreList = null;
                    });
                    getData();
                  },
                  child: const Text('Retry')),
            ],
          ),
        ],
      )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class GenreDisplay extends StatefulWidget {
  final String? api;
  const GenreDisplay({Key? key, this.api}) : super(key: key);

  @override
  GenreDisplayState createState() => GenreDisplayState();
}

class GenreDisplayState extends State<GenreDisplay>
    with AutomaticKeepAliveClientMixin<GenreDisplay> {
  List<Genres>? genreList;
  @override
  void initState() {
    super.initState();
    moviesApi().fetchGenre(widget.api!).then((value) {
      setState(() {
        genreList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
        child: genreList == null
            ? SizedBox(
                height: 80,
                child: detailGenreShimmer(),
              )
            : genreList!.isEmpty
                ? Container()
                : SizedBox(
                    height: 80,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: genreList!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GenreMovies(
                                            genres: genreList![index],
                                          )));
                            },
                            child: Chip(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    width: 2,
                                    style: BorderStyle.solid,
                                    color: maincolor),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              label: Text(
                                genreList![index].genreName!,
                                style: const TextStyle(fontFamily: 'Poppins'),
                                // style: widget.themeData.textTheme.bodyText1,
                              ),
                              backgroundColor:const Color(0xFFDFDEDE),
                            ),
                          ),
                        );
                      },
                    ),
                  ));
  }

  @override
  bool get wantKeepAlive => true;
}
