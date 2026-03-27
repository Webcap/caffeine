import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/functions/network.dart';
import 'package:caffiene/models/credits.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/movie_screens/cast_details.dart';
import 'package:caffiene/screens/movie_screens/crew_detail.dart';
import 'package:caffiene/screens/person/guest_star_details.dart';
import 'package:caffiene/widgets/cast_crew_shared.dart';
import 'package:caffiene/widgets/common_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TVEpisodeCastAndCrew extends StatefulWidget {
  const TVEpisodeCastAndCrew(
      {super.key,
      required this.id,
      required this.seasonNumber,
      required this.episodeNumber});

  final int id;
  final int seasonNumber;
  final int episodeNumber;

  @override
  State<TVEpisodeCastAndCrew> createState() => _TVEpisodeCastAndCrewState();
}

class _TVEpisodeCastAndCrewState extends State<TVEpisodeCastAndCrew> {
  Credits? credits;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCredits();
  }

  Future<void> _loadCredits() async {
    final context = this.context;
    if (!context.mounted) return;
    final lang =
        Provider.of<SettingsProvider>(context, listen: false).appLanguage;
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    final api = Endpoints.getEpisodeCredits(
        widget.id, widget.seasonNumber, widget.episodeNumber, lang);
    try {
      final c = await fetchCredits(api, isProxyEnabled, proxyUrl);
      if (mounted)
        setState(() {
          credits = c;
          _loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

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
      body: _loading
          ? Center(child: CircularProgressIndicator(color: textPrim))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      _error!,
                      style: TextStyle(color: textSec),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CastCrewDesign.screenPadH,
                    vertical: CastCrewDesign.space4,
                  ),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cast
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
                      if (credits?.cast == null || credits!.cast!.isEmpty)
                        CastCrewEmptyCard(
                          surface: surface,
                          border: border,
                          message: tr("no_cast_episode"),
                          textSec: textSec,
                        )
                      else
                        CastCrewSectionCard(
                          surface: surface,
                          border: border,
                          child: Column(
                            children: [
                              for (int i = 0;
                                  i < credits!.cast!.length;
                                  i++) ...[
                                if (i > 0) CastCrewTileDivider(indent: 72),
                                CastCrewTile(
                                  creditId: credits!.cast![i].creditId!,
                                  profilePath: credits!.cast![i].profilePath,
                                  name: credits!.cast![i].name ?? '',
                                  subtitle:
                                      (credits!.cast![i].character?.isEmpty ??
                                              true)
                                          ? tr("as_empty")
                                          : tr("as", namedArgs: {
                                              "character":
                                                  credits!.cast![i].character!
                                            }),
                                  textPrim: textPrim,
                                  textSec: textSec,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CastDetailPage(
                                        cast: credits!.cast![i],
                                        heroId: credits!.cast![i].creditId!,
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
                      // Guest Stars
                      Row(
                        children: [
                          const LeadingDot(),
                          Text(
                            tr("guest_stars"),
                            style: TextStyle(
                              color: textPrim,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: CastCrewDesign.space3),
                      if (credits?.episodeGuestStars == null ||
                          credits!.episodeGuestStars!.isEmpty)
                        CastCrewEmptyCard(
                          surface: surface,
                          border: border,
                          message: tr("no_guest_episode"),
                          textSec: textSec,
                        )
                      else
                        CastCrewSectionCard(
                          surface: surface,
                          border: border,
                          child: Column(
                            children: [
                              for (int i = 0;
                                  i < credits!.episodeGuestStars!.length;
                                  i++) ...[
                                if (i > 0) CastCrewTileDivider(indent: 72),
                                CastCrewTile(
                                  creditId: credits!
                                          .episodeGuestStars![i].creditId ??
                                      'guest_${credits!.episodeGuestStars![i].id}',
                                  profilePath: credits!
                                      .episodeGuestStars![i].profilePath,
                                  name:
                                      credits!.episodeGuestStars![i].name ?? '',
                                  subtitle: (credits!.episodeGuestStars![i]
                                              .character?.isEmpty ??
                                          true)
                                      ? tr("as_empty")
                                      : tr("as", namedArgs: {
                                          "character": credits!
                                              .episodeGuestStars![i].character!
                                        }),
                                  textPrim: textPrim,
                                  textSec: textSec,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => GuestStarDetailPage(
                                        cast: credits!.episodeGuestStars![i],
                                        heroId: credits!.episodeGuestStars![i]
                                                .creditId ??
                                            '${credits!.episodeGuestStars![i].id}',
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
                      // Crew
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
                      if (credits?.crew == null || credits!.crew!.isEmpty)
                        CastCrewEmptyCard(
                          surface: surface,
                          border: border,
                          message: tr("no_crew_episode"),
                          textSec: textSec,
                        )
                      else
                        CastCrewSectionCard(
                          surface: surface,
                          border: border,
                          child: Column(
                            children: [
                              for (int i = 0;
                                  i < credits!.crew!.length;
                                  i++) ...[
                                if (i > 0) CastCrewTileDivider(indent: 72),
                                CastCrewTile(
                                  creditId: credits!.crew![i].creditId!,
                                  profilePath: credits!.crew![i].profilePath,
                                  name: credits!.crew![i].name ?? '',
                                  subtitle: (credits!.crew![i].job ??
                                              credits!.crew![i].department ??
                                              '')
                                          .isEmpty
                                      ? tr("job_empty")
                                      : tr("job", namedArgs: {
                                          "job": credits!.crew![i].job ??
                                              credits!.crew![i].department ??
                                              ''
                                        }),
                                  textPrim: textPrim,
                                  textSec: textSec,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CrewDetailPage(
                                        crew: credits!.crew![i],
                                        heroId: credits!.crew![i].creditId!,
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
