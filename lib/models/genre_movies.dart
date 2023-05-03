import 'package:flutter/material.dart';
import 'package:login/api/endpoints.dart';
import 'package:login/models/genres.dart';
import 'package:login/provider/settings_provider.dart';
import 'package:login/screens/movie_screens/widgets/particular_genre_movies.dart';
import 'package:login/utils/config.dart';
import 'package:provider/provider.dart';

class GenreMovies extends StatelessWidget {
  final Genres genres;
  const GenreMovies({Key? key, required this.genres}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${genres.genreName!} movies',
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
        child: ParticularGenreMovies(
          includeAdult: Provider.of<SettingsProvider>(context).isAdult,
          genreId: genres.genreID!,
          api: Endpoints.getMoviesForGenre(genres.genreID!, 1),
          watchRegion: Provider.of<SettingsProvider>(context).defaultCountry,
        ),
      ),
    );
  }
}
