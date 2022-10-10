import 'package:flutter/material.dart';
import 'package:login/screens/movie_source_screen.dart';
import 'package:login/utils/movies_api.dart';
import 'package:login/widgets/movie_page_buttons.dart';
import 'package:login/widgets/movie_rec.dart';

class moviedetails extends StatelessWidget {
  final int id;
  const moviedetails({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff292837),
      body: FutureBuilder(
        future: moviesApi().getMovieDetail(id.toString()),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Stack(
              children: [
                Opacity(
                  opacity: 0.4,
                  child: (snapshot.data.backdropPath == null)
                      ? Container(
                          height: 200,
                          width: double.infinity,
                        )
                      : Image.network(
                          'https://image.tmdb.org/t/p/original/${snapshot.data.backdropPath}',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                SingleChildScrollView(
                    child: SafeArea(
                  child: Column(children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),

                            InkWell(
                              onTap: () {},
                              child: Icon(
                                Icons.cast,
                                color: Colors.white,
                                size: 30,
                              ),
                            )
                          ]),
                    ),
                    SizedBox(height: 60),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration:  BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network('https://image.tmdb.org/t/p/w500/${snapshot.data.posterPath}',
                                height: 250,
                                width: 180
                              ),
                            )
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 50, top: 70),
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              color: Colors.red,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2
                                )
                              ]
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              size: 60,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    MoviePageButtons(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${snapshot.data.title}",
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            "${snapshot.data.overview}",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.justify,
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),

                    movieSourceSelect(),
                    SizedBox(height: 10),
                    MovieRecommendWidget()
                  ]),
                )),
              ],
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
