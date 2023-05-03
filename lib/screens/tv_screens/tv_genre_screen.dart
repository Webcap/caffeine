import 'package:flutter/material.dart';
import 'package:login/api/endpoints.dart';
import 'package:login/models/genres.dart';
import 'package:login/provider/settings_provider.dart';
import 'package:login/screens/tv_screens/widgets/particular_genre_tv.dart';
import 'package:login/screens/tv_screens/widgets/tv_genre_widgets.dart';
import 'package:provider/provider.dart';

class TVGenre extends StatelessWidget {
  final Genres genres;
  const TVGenre({Key? key, required this.genres}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${genres.genreName!} TV shows',
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: ParticularGenreTV(
          includeAdult: Provider.of<SettingsProvider>(context).isAdult,
          genreId: genres.genreID!,
          api: Endpoints.getTVShowsForGenre(genres.genreID!, 1),
        ),
      ),
    );
  }
}
