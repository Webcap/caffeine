// ignore_for_file: unused_field, unused_local_variable

import 'package:reelriot/controller/bookmark_database_controller.dart';
import 'package:reelriot/models/movie_models.dart';
import 'package:reelriot/models/recently_watched.dart';
import 'package:reelriot/models/tv.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/watch_history/widgets/movie_watch_history_widget.dart';
import 'package:reelriot/screens/watch_history/widgets/tv_watch_history_tab.dart';
import 'package:reelriot/utils/helpers/snackbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class WatchHistory extends StatefulWidget {
  const WatchHistory({super.key});

  @override
  State<WatchHistory> createState() => _WatchHistoryState();
}

class _WatchHistoryState extends State<WatchHistory>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  String? uid;
  final _auth = Supabase.instance.client.auth;
  final _supabase = Supabase.instance.client;
  MovieDatabaseController movieDatabaseController = MovieDatabaseController();
  TVDatabaseController tvDatabaseController = TVDatabaseController();
  List<Movie> firebaseMovies = [];
  List<TV> firebaseTvShows = [];
  bool? isLoading;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    getWatchedMovieAndTV();
  }

  void getWatchedMovieAndTV() async {
    final user = _auth.currentUser;
    uid = user?.id;
    if (uid == null) {
      setState(() => isLoading = false);
      return;
    }
    setState(() {
      isLoading = true;
    });

    // Fetch active continue-watching progress
    final cwRes = await _supabase
        .from('continue_watching_history')
        .select()
        .eq('user_id', uid!);

    // Fetch completely watched history
    final cpRes = await _supabase
        .from('completed_watch_history')
        .select()
        .eq('user_id', uid!);

    if (mounted) {
      setState(() {
        // Aggregate items from both tables
        final allProgress = [...cwRes, ...cpRes];

        for (var row in allProgress) {
          final isTv = row['media_type'] == 'tv';
          final isCompleted = row.containsKey('time_watched_ms'); // completed table specific column

          if (isTv) {
            firebaseTvShows.add(TV(
              id: row['media_id'],
              name: row['title'],
              posterPath: row['poster_path'],
              seriesName: row['title'],
              episodeName: row['episode_name'],
            ));
          } else {
            firebaseMovies.add(Movie(
              id: row['media_id'],
              title: row['title'],
              posterPath: row['poster_path'],
              backdropPath: row['backdrop_path'],
              releaseDate: null, // Schema no longer stores this explicitly
            ));
          }
        }
      });
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(tr("watch_history")),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey,
            child: TabBar(
              tabs: [
                Tab(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: FaIcon(FontAwesomeIcons.clapperboard),
                    ),
                    Text(
                      tr("movies"),
                    ),
                  ],
                )),
                Tab(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.live_tv_rounded)),
                    Text(
                      tr("tv_series"),
                    ),
                  ],
                ))
              ],
              indicatorColor: themeMode == "dark" || themeMode == "amoled"
                  ? Colors.white
                  : Colors.black,
              indicatorWeight: 3,
              //isScrollable: true,
              labelStyle: const TextStyle(
                fontFamily: 'PoppinsSB',
                color: Colors.black,
                fontSize: 17,
              ),
              unselectedLabelStyle:
                  const TextStyle(fontFamily: 'Poppins', color: Colors.black87),
              labelColor: Colors.black,
              controller: tabController,
              indicatorSize: TabBarIndicatorSize.tab,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                MovieWatchHistory(movieList: firebaseMovies),
                TVWatchHistory(tvList: firebaseTvShows)
              ],
            ),
          )
        ],
      ),
    );
  }
}
