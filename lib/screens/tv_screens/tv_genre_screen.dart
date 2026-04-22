import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/api/endpoints.dart';
import 'package:reelriot/models/genres.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/tv_screens/widgets/particular_genre_tv.dart';
import 'package:provider/provider.dart';

// ─── Design tokens (design.json) ─────────────────────────────────────────────
class _Design {
  static const bgCanvasDark = Color(0xFF030712);
  static const bgSurfaceDark = Color(0xFF0B0F14);
  static const textPrimDark = Color(0xFFFFFFFF);
  static const borderDark = Color(0x14FFFFFF);
  static const iconBgDark = Color(0x14FFFFFF);
  static const bgCanvasLight = Color(0xFFF8FAFC);
  static const bgSurfaceLight = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
  static const borderLight = Color(0x140F172A);

  static const space2 = 8.0;
}

class TVGenre extends StatelessWidget {
  final Genres genres;
  const TVGenre({super.key, required this.genres});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isDark = themeMode == 'dark' || themeMode == 'amoled';
    final bg = isDark ? _Design.bgCanvasDark : _Design.bgCanvasLight;
    final surface = isDark ? _Design.bgSurfaceDark : _Design.bgSurfaceLight;
    final textPrim = isDark ? _Design.textPrimDark : _Design.textPrimLight;
    final border = isDark ? _Design.borderDark : _Design.borderLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surface,
        leading: Padding(
          padding: const EdgeInsets.only(left: _Design.space2),
          child: Material(
            color: isDark ? _Design.iconBgDark : border,
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
          tr("genre_tv_title", namedArgs: {"g": genres.genreName ?? "Null"}),
          style: TextStyle(
            color: textPrim,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ParticularGenreTV(
        includeAdult: Provider.of<SettingsProvider>(context).isAdult,
        genreId: genres.genreID!,
        api: Endpoints.getTVShowsForGenre(genres.genreID!, 1, lang),
      ),
    );
  }
}
