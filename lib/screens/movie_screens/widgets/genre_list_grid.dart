import 'package:caffiene/functions/network.dart';
import 'package:caffiene/models/genre_movies.dart';
import 'package:caffiene/models/genres.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/widgets/common_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';

// ─── Design tokens (design.json) ─────────────────────────────────────────────
class _Design {
  static const bgSurfaceDark = Color(0xFF0B0F14);
  static const textPrimDark = Color(0xFFFFFFFF);
  static const borderDark = Color(0x14FFFFFF);
  static const bgSurfaceLight = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
  static const borderLight = Color(0x140F172A);

  static const radiusMd = 16.0;
  static const space2 = 8.0;
  static const space3 = 12.0;
  static const screenPadH = 16.0;
  static const shadowCard = BoxShadow(
    color: Color(0x38000000),
    blurRadius: 30,
    offset: Offset(0, 10),
  );
}

class GenreListGrid extends StatefulWidget {
  final String api;
  const GenreListGrid({
    super.key,
    required this.api,
  });

  @override
  GenreListGridState createState() => GenreListGridState();
}

class GenreListGridState extends State<GenreListGrid>
    with AutomaticKeepAliveClientMixin<GenreListGrid> {
  List<Genres>? genreList;

  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchGenre(widget.api, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          genreList = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isDark = themeMode == 'dark' || themeMode == 'amoled';
    final textPrim = isDark ? _Design.textPrimDark : _Design.textPrimLight;
    final surface = isDark ? _Design.bgSurfaceDark : _Design.bgSurfaceLight;
    final border = isDark ? _Design.borderDark : _Design.borderLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: _Design.screenPadH,
            right: _Design.screenPadH,
            top: _Design.space2,
            bottom: _Design.space3,
          ),
          child: Row(
            children: [
              const LeadingDot(),
              Expanded(
                child: Text(
                  tr("genres"),
                  style: TextStyle(
                    color: textPrim,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: _Design.screenPadH,
            right: _Design.screenPadH,
            bottom: 16,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 88,
            child: genreList == null
                ? genreListGridShimmer(themeMode)
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: genreList!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: _Design.space3),
                        child: _GenreChip(
                          surface: surface,
                          border: border,
                          label: genreList![index].genreName ?? "Null",
                          textPrim: textPrim,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GenreMovies(
                                  genres: genreList![index],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _GenreChip extends StatelessWidget {
  final Color surface;
  final Color border;
  final Color textPrim;
  final String label;
  final VoidCallback onTap;

  const _GenreChip({
    required this.surface,
    required this.border,
    required this.label,
    required this.textPrim,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(_Design.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_Design.radiusMd),
        child: Container(
          width: 130,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_Design.radiusMd),
            border: Border.all(color: border),
            boxShadow: const [_Design.shadowCard],
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: _Design.space3, vertical: _Design.space2),
          child: Text(
            label,
            style: TextStyle(
              color: textPrim,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class GenreDisplay extends StatefulWidget {
  final String? api;
  const GenreDisplay({super.key, this.api});

  @override
  GenreDisplayState createState() => GenreDisplayState();
}

class GenreDisplayState extends State<GenreDisplay>
    with AutomaticKeepAliveClientMixin<GenreDisplay> {
  List<Genres>? genreList;

  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchGenre(widget.api!, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          genreList = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isDark = themeMode == 'dark' || themeMode == 'amoled';
    final textPrim = isDark ? _Design.textPrimDark : _Design.textPrimLight;
    final surface = isDark ? _Design.bgSurfaceDark : _Design.bgSurfaceLight;
    final border = isDark ? _Design.borderDark : _Design.borderLight;

    super.build(context);
    return genreList == null
        ? SizedBox(
            height: 88,
            child: detailGenreShimmer(themeMode),
          )
        : genreList!.isEmpty
            ? const SizedBox.shrink()
            : SizedBox(
                height: 88,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: genreList!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _GenreChip(
                        surface: surface,
                        border: border,
                        label: genreList![index].genreName!,
                        textPrim: textPrim,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GenreMovies(
                                genres: genreList![index],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
  }

  @override
  bool get wantKeepAlive => true;
}
