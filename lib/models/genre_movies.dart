// ignore_for_file: unused_field

import 'package:reelriot/api/endpoints.dart';
import 'package:reelriot/models/genres.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/movie_screens/widgets/particular_genre_movies.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ─── Design tokens (design.json) ─────────────────────────────────────────────
class _GenreDesign {
  static const bgCanvasDark = Color(0xFF030712);
  static const bgSurfaceDark = Color(0xFF0B0F14);
  static const textPrimDark = Color(0xFFFFFFFF);
  static const borderDark = Color(0x14FFFFFF);
  static const iconBgDark = Color(0x14FFFFFF);
  static const bgCanvasLight = Color(0xFFF8FAFC);
  static const bgSurfaceLight = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
  static const borderLight = Color(0x140F172A);

  static const radiusMd = 16.0;
  static const space2 = 8.0;
  static const screenPadH = 16.0;
}

class GenreMovies extends StatelessWidget {
  final Genres genres;
  const GenreMovies({super.key, required this.genres});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isDark = themeMode == 'dark' || themeMode == 'amoled';
    final bg = isDark ? _GenreDesign.bgCanvasDark : _GenreDesign.bgCanvasLight;
    final surface =
        isDark ? _GenreDesign.bgSurfaceDark : _GenreDesign.bgSurfaceLight;
    final textPrim =
        isDark ? _GenreDesign.textPrimDark : _GenreDesign.textPrimLight;
    final border = isDark ? _GenreDesign.borderDark : _GenreDesign.borderLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surface,
        leading: Padding(
          padding: const EdgeInsets.only(left: _GenreDesign.space2),
          child: Material(
            color: isDark ? _GenreDesign.iconBgDark : border,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child:
                    Icon(Icons.arrow_back_rounded, size: 22, color: textPrim),
              ),
            ),
          ),
        ),
        iconTheme: IconThemeData(color: textPrim),
        title: Text(
          tr("genre_movie_title", namedArgs: {"g": genres.genreName ?? "Null"}),
          style: TextStyle(
            color: textPrim,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ParticularGenreMovies(
        includeAdult: Provider.of<SettingsProvider>(context).isAdult,
        genreId: genres.genreID!,
        api: Endpoints.getMoviesForGenre(genres.genreID!, 1, lang),
        watchRegion: Provider.of<SettingsProvider>(context).defaultCountry,
      ),
    );
  }
}
