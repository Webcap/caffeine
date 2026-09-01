import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/models/tv.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/tv_screens/widgets/tv_season_about.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/utils/constant.dart';
import 'package:reelriot/utils/globals.dart';

/// Two-column layout for the season detail page on tablet-landscape /
/// unfolded-foldable widths (>= 840dp): season poster pinned in a
/// contained media card on the left, title/series-name/overview/cast/
/// episodes/images scrolling together on the right. Same "media left,
/// content right" composition as the episode and movie detail pages'
/// expanded layouts.
class SeasonDetailExpandedLayout extends StatelessWidget {
  const SeasonDetailExpandedLayout({
    super.key,
    required this.season,
    required this.heroId,
    required this.tvDetails,
    this.seriesName,
    this.tvId,
  });

  final Seasons season;
  final String heroId;
  final TVDetails tvDetails;
  final String? seriesName;
  final int? tvId;

  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseUrl = buildImageUrl(tmdbBaseImageUrl, proxyUrl, isProxyEnabled, context);

    return SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: pinned poster card ─────────────────────────────────────
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 12, 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 2 / 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: heroId,
                        child: season.posterPath == null
                            ? Image.asset('assets/images/na_logo.png', fit: BoxFit.cover)
                            : CachedNetworkImage(
                                cacheManager: cacheProp(),
                                fit: BoxFit.cover,
                                imageUrl: baseUrl + imageQuality + season.posterPath!,
                                errorWidget: (context, url, error) =>
                                    Image.asset('assets/images/na_logo.png', fit: BoxFit.cover),
                              ),
                      ),
                      Positioned(
                        left: 12,
                        top: 12,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? Colors.black45 : Colors.white70,
                              border: Border.all(
                                color: (isDark ? Colors.white : Colors.black)
                                    .withValues(alpha: 0.12),
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Right: title + series name + overview + cast + episodes ─────
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 24, 24, 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            season.airDate == null || season.airDate == ''
                                ? season.name ?? '—'
                                : '${season.name!} (${DateTime.parse(season.airDate!).year})',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : Colors.black,
                              fontFamily: 'PoppinsSB',
                            ),
                          ),
                        ),
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(const Color(0x26F57C00)),
                            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                side: const BorderSide(color: maincolor),
                              ),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            tr('open_show'),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    if (tvDetails.originalTitle != null &&
                        tvDetails.originalTitle!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        tvDetails.originalTitle!,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    TVSeasonAbout(
                      season: season,
                      tvDetails: tvDetails,
                      seriesName: seriesName,
                      scrollable: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
