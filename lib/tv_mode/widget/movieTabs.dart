import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:login/api/endpoints.dart';
import 'package:login/screens/movie_screens/widgets/scrolling_widget.dart';

class movieTab extends StatefulWidget {
  const movieTab({super.key});

  @override
  State<movieTab> createState() => _movieTabState();
}

class _movieTabState extends State<movieTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Align(
                child: Text(
                  'Movies trending',
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
                alignment: Alignment.topLeft),
          ),
          SizedBox(height: 20),
          // CoverListView(context, 'movies'),
          // ScrollingMovies(
          //   title: 'Trending this week',
          //   api: Endpoints.trendingMoviesUrl(1),
          //   discoverType: 'Trending',
          //   isTrending: true,
          // ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Align(
                child: Text(
                  'Shows trending',
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
                alignment: Alignment.topLeft),
          ),
          // CoverListView(context, 'shows'),
        ],
      ),
    );
  }
}