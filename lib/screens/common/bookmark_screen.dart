import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:login/controller/database_controller.dart';
import 'package:login/models/movie_models.dart';
import 'package:login/models/tv.dart';
import 'package:login/provider/settings_provider.dart';
import 'package:login/screens/common/sync_screen.dart';
import 'package:login/utils/config.dart';
import 'package:provider/provider.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  String? uid;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  MovieDatabaseController movieDatabaseController = MovieDatabaseController();
  //TVDatabaseController tvDatabaseController = TVDatabaseController();
  List<TV>? tvList;
  List<Movie>? movieList;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    getData();
    fetchMovieBookmark();
    // fetchTVBookmark();
  }

  void getData() async {
    user = _auth.currentUser;
    uid = user!.uid;
  }

  Future<void> setMovieData() async {
    var mov = await movieDatabaseController.getMovieList();
    if (mounted) {
      setState(() {
        movieList = mov;
      });
    }
  }

  void fetchMovieBookmark() async {
    await setMovieData();
  }

  // Future<void> setTVData() async {
  //   var tv = await tvDatabaseController.getTVList();
  //   setState(() {
  //     tvList = tv;
  //   });
  // }

  // void fetchTVBookmark() async {
  //   await setTVData();
  // }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Bookmarks'),
        actions: [
          IconButton(
              onPressed: () {
                if (user!.isAnonymous) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'This syncing feature is only available for signed in users. Register to Cinemax to synchronize your bookmarked movies and tv shows so that you won\'t lose them.',
                        style: kTextVerySmallBodyStyle,
                        maxLines: 6,
                      ),
                      duration: Duration(seconds: 10),
                    ),
                  );
                } else {
                  Navigator.push(context,
                      MaterialPageRoute(builder: ((context) {
                    return const SyncScreen();
                  }))).then((value) async {
                    fetchMovieBookmark();
                    // fetchTVBookmark();
                  });
                }
              },
              icon: const Icon(Icons.sync_sharp))
        ],
      ),
    );
  }
}
