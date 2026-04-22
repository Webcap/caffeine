import 'package:reelriot/models/credits.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/movie_screens/cast_details.dart';
import 'package:reelriot/screens/movie_screens/crew_detail.dart';
import 'package:reelriot/widgets/cast_crew_shared.dart';
import 'package:reelriot/widgets/common_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MovieCastAndCrew extends StatelessWidget {
  const MovieCastAndCrew({super.key, required this.credits});
  final Credits credits;

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isDark = themeMode == 'dark' || themeMode == 'amoled';
    final bg =
        isDark ? CastCrewDesign.bgCanvasDark : CastCrewDesign.bgCanvasLight;
    final surface =
        isDark ? CastCrewDesign.bgSurfaceDark : CastCrewDesign.bgSurfaceLight;
    final textPrim =
        isDark ? CastCrewDesign.textPrimDark : CastCrewDesign.textPrimLight;
    final textSec =
        isDark ? CastCrewDesign.textSecDark : CastCrewDesign.textSecLight;
    final border =
        isDark ? CastCrewDesign.borderDark : CastCrewDesign.borderLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surface,
        leading: Padding(
          padding: const EdgeInsets.only(left: CastCrewDesign.space2),
          child: CastCrewCircleBackButton(
            onTap: () => Navigator.pop(context),
            iconColor: textPrim,
            bgColor: isDark ? CastCrewDesign.iconBgDark : border,
          ),
        ),
        title: Text(
          tr("cast_and_crew"),
          style: TextStyle(
            color: textPrim,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: CastCrewDesign.screenPadH,
          vertical: CastCrewDesign.space4,
        ),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const LeadingDot(),
                Text(
                  tr("cast"),
                  style: TextStyle(
                    color: textPrim,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: CastCrewDesign.space3),
            if (credits.cast == null || credits.cast!.isEmpty)
              CastCrewEmptyCard(
                surface: surface,
                border: border,
                message: tr("no_cast_movie"),
                textSec: textSec,
              )
            else
              CastCrewSectionCard(
                surface: surface,
                border: border,
                child: Column(
                  children: [
                    for (int i = 0; i < credits.cast!.length; i++) ...[
                      if (i > 0) CastCrewTileDivider(indent: 72),
                      CastCrewTile(
                        creditId: credits.cast![i].creditId!,
                        profilePath: credits.cast![i].profilePath,
                        name: credits.cast![i].name ?? '',
                        subtitle: credits.cast![i].character?.isEmpty ?? true
                            ? tr("as_empty")
                            : tr("as", namedArgs: {
                                "character": credits.cast![i].character!
                              }),
                        textPrim: textPrim,
                        textSec: textSec,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CastDetailPage(
                              cast: credits.cast![i],
                              heroId: credits.cast![i].creditId!,
                            ),
                          ),
                        ),
                        themeMode: themeMode,
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: CastCrewDesign.space6),
            Row(
              children: [
                const LeadingDot(),
                Text(
                  tr("crew"),
                  style: TextStyle(
                    color: textPrim,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: CastCrewDesign.space3),
            if (credits.crew == null || credits.crew!.isEmpty)
              CastCrewEmptyCard(
                surface: surface,
                border: border,
                message: tr("no_crew_movie"),
                textSec: textSec,
              )
            else
              CastCrewSectionCard(
                surface: surface,
                border: border,
                child: Column(
                  children: [
                    for (int i = 0; i < credits.crew!.length; i++) ...[
                      if (i > 0) CastCrewTileDivider(indent: 72),
                      CastCrewTile(
                        creditId: credits.crew![i].creditId!,
                        profilePath: credits.crew![i].profilePath,
                        name: credits.crew![i].name ?? '',
                        subtitle: (credits.crew![i].job ??
                                    credits.crew![i].department ??
                                    '')
                                .isEmpty
                            ? tr("job_empty")
                            : tr("job", namedArgs: {
                                "job": credits.crew![i].job ??
                                    credits.crew![i].department ??
                                    ''
                              }),
                        textPrim: textPrim,
                        textSec: textSec,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CrewDetailPage(
                              crew: credits.crew![i],
                              heroId: credits.crew![i].creditId!,
                            ),
                          ),
                        ),
                        themeMode: themeMode,
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: CastCrewDesign.space6),
          ],
        ),
      ),
    );
  }
}
