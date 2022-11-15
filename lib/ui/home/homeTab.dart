import 'package:flutter/material.dart';
import 'package:login/api/endpoints.dart';
import 'package:login/screens/movie_screens/widgets/scrolling_widget.dart';
import 'package:login/widgets/scrollingMovieList_tvMode.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: 20),
          // Padding(
          //   padding: const EdgeInsets.only(left: 15),
          //   child: Align(
          //       child: Text(
          //         'Movies trending',
          //         style: TextStyle(color: Colors.white, fontSize: 30),
          //       ),
          //       alignment: Alignment.topLeft),
          // ),
          SizedBox(height: 20),
          // CoverListView(context, 'movies'),
          ScrollingMoviesTVMode(
            api: Endpoints.popularMoviesUrl(1), title: 'Popular', isTrending: false, discoverType: 'popular',),
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
