import 'package:reelriot/api/endpoints.dart';
import 'package:reelriot/models/tv.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/tv_screens/widgets/scrolling_tv_widget.dart';
import 'package:reelriot/screens/tv_screens/widgets/tv_epi_image.dart';
import 'package:reelriot/screens/tv_screens/widgets/watch_now_tv.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/widgets/common_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

// ── Design tokens (design.json) ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFFDC2626);
}

class EpisodeAbout extends StatefulWidget {
  const EpisodeAbout({
    super.key,
    required this.episodeList,
    this.episodes,
    this.tvId,
    required this.posterPath,
    this.seriesName,
    this.scrollable = true,
  });
  final EpisodeList episodeList;
  final List<EpisodeList>? episodes;
  final int? tvId;
  final String? seriesName;
  final String? posterPath;

  /// When false, renders its content directly (no SingleChildScrollView) so
  /// a caller can place it inside a scroll region it already owns — used by
  /// the expanded (tablet-landscape) layout, which shares one scroll view
  /// across the title block, ratings, and this content.
  final bool scrollable;

  @override
  State<EpisodeAbout> createState() => _EpisodeAboutState();
}

class _EpisodeAboutState extends State<EpisodeAbout> {
  late AppDependencyProvider appDependency =
      Provider.of<AppDependencyProvider>(context, listen: false);
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    final content = Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        const LeadingDot(),
                        Expanded(
                          child: Text(
                            tr("overview"),
                            style: kTextHeaderStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ReadMoreText(
                (widget.episodeList.overview == null ||
                        widget.episodeList.overview!.isEmpty)
                    ? tr("no_episode_overview")
                    : widget.episodeList.overview!,
                trimLines: 4,
                style: const TextStyle(fontFamily: 'Poppins'),
                colorClickableText: _C.primary,
                trimMode: TrimMode.Line,
                trimCollapsedText: tr("read_more"),
                trimExpandedText: tr("read_less"),
                lessStyle: const TextStyle(
                    fontSize: 14,
                    color: _C.primary,
                    fontWeight: FontWeight.bold),
                moreStyle: const TextStyle(
                    fontSize: 14,
                    color: _C.primary,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, bottom: 4.0, right: 8.0),
                  child: Text(
                    widget.episodeList.airDate == null ||
                            widget.episodeList.airDate!.isEmpty ||
                            DateTime.tryParse(widget.episodeList.airDate!) == null
                        ? tr("episode_air_empty")
                        : '${tr("episode_air")}  ${DateTime.parse(widget.episodeList.airDate!).day} ${DateFormat("MMMM").format(DateTime.parse(widget.episodeList.airDate!))}, ${DateTime.parse(widget.episodeList.airDate!).year}',
                    style: const TextStyle(
                      fontFamily: 'PoppinsSB',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              appDependency.displayWatchNowButton &&
                      (widget.episodeList.airDate == null ||
                          widget.episodeList.airDate!.isEmpty ||
                          (DateTime.tryParse(widget.episodeList.airDate!) != null &&
                              DateTime.tryParse(widget.episodeList.airDate!)!
                                  .isBefore(DateTime.now().add(const Duration(days: 1)))))
                  ? WatchNowButtonTV(
                      episode: widget.episodeList,
                      seriesName: widget.seriesName ?? '',
                      tvId: widget.tvId ?? 0,
                      posterPath: widget.posterPath ?? '',
                    )
                  : Container(),
            ]),

            const SizedBox(height: 15),
            if (widget.tvId != null &&
                widget.episodeList.seasonNumber != null &&
                widget.episodeList.episodeNumber != null) ...[
              ScrollingTVEpisodeCasts(
                passedFrom: 'episode_detail',
                seasonNumber: widget.episodeList.seasonNumber!,
                episodeNumber: widget.episodeList.episodeNumber!,
                id: widget.tvId,
                api: Endpoints.getEpisodeCredits(
                    widget.tvId!,
                    widget.episodeList.seasonNumber!,
                    widget.episodeList.episodeNumber!,
                    lang),
              ),
              TVEpisodeImagesDisplay(
                title: tr("images"),
                name: '${widget.seriesName ?? ''}_${widget.episodeList.name ?? ''}',
                api: Endpoints.getTVEpisodeImagesUrl(
                    widget.tvId!,
                    widget.episodeList.seasonNumber!,
                    widget.episodeList.episodeNumber!),
              ),
            ],
          ],
        );

    return widget.scrollable ? SingleChildScrollView(child: content) : content;
  }
}
