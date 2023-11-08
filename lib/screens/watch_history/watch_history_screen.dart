// ignore_for_file: unused_field, unused_local_variable

import 'package:caffiene/controller/database_controller.dart';
import 'package:caffiene/models/movie_models.dart';
import 'package:caffiene/models/tv.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/watch_history/widgets/movie_watch_history_widget.dart';
import 'package:caffiene/screens/watch_history/widgets/tv_watch_history_tab.dart';
import 'package:caffiene/utils/snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  MovieDatabaseController movieDatabaseController = MovieDatabaseController();
  TVDatabaseController tvDatabaseController = TVDatabaseController();
  FirebaseFirestore firebaseInstance = FirebaseFirestore.instance;
  List<Movie> firebaseMovies = [];
  List<TV> firebaseTvShows = [];
  bool? isLoading;
  late DocumentSnapshot subscription;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    getWatchedMovieAndTV();
  }

  Future<bool> checkIfDocExists(String docId) async {
    try {
      var collectionRef = firebaseInstance.collection('watch_history');
      var doc = await collectionRef.doc(docId).get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }

  void getWatchedMovieAndTV() async {
    print("geting watched history...");
    User? user = _auth.currentUser;
    uid = user!.uid;
    setState(() {
      isLoading = true;
      const CircularProgressIndicator();
    });

    if (await checkIfDocExists(uid!) == false) {
      openSnackbar(context, "error fetching dataset", Colors.red);
    }

    // Checks if a movie and tvShow collection exists for a signed in user and creates a collection if it doesn't exist
    subscription =
        await firebaseInstance.collection('watch_history').doc(uid!).get();
    final docData = subscription.data() as Map<String, dynamic>;

    // Fetches movies and tvShows of the signed in user and converts the map into a Movie/TV object/list
    await firebaseInstance
        .collection('watch_history')
        .doc(uid!)
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          for (Map<String, dynamic>? element
              in List.from(value.get('movies'))) {
            firebaseMovies.add(Movie.fromJson(element!));
          }
        });
      }
    });

    await firebaseInstance
        .collection('watch_history')
        .doc(uid!)
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          for (Map<String, dynamic>? element
              in List.from(value.get('tvShows'))) {
            firebaseTvShows.add(TV.fromJson(element!));
          }
        });
      }
    });

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
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
                      child: Icon(FontAwesomeIcons.clapperboard),
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
              indicatorColor: isDark ? Colors.white : Colors.black,
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
                tvWatchHistory(tvList: firebaseTvShows)
              ],
            ),
          )
        ],
      ),
    );
  }
}
