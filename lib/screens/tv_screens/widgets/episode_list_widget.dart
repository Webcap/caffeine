import 'package:cached_network_image/cached_network_image.dart';
import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/functions/network.dart';
import 'package:reelriot/models/tv.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/tv_screens/episode_detail_page.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/utils/constant.dart';
import 'package:reelriot/models/recently_watched.dart';
import 'package:reelriot/widgets/common_widgets.dart';
import 'package:reelriot/provider/recently_watched_provider.dart';
import 'package:reelriot/widgets/mobile_context_menu.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ── Design tokens (design.json) ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFFDC2626);
  static const ratingGold = Color(0xFFEAB308);

  static const bgElevatedDark = Color(0x0DFFFFFF);
  static const bgElevatedLight = Color(0xFFF1F5F9);
  static const borderDark = Color(0x14FFFFFF);
  static const borderLight = Color(0x140F172A);
  static const textPrimDark = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
  static const textSecDark = Color(0xB8FFFFFF);
  static const textSecLight = Color(0xFF475569);
}

class EpisodeListWidget extends StatefulWidget {
  final int? tvId;
  final String? api;
  final String? seriesName;
  final String? posterPath;
  const EpisodeListWidget({
    super.key,
    this.api,
    this.tvId,
    this.seriesName,
    required this.posterPath,
  });

  @override
  EpisodeListWidgetState createState() => EpisodeListWidgetState();
}

class EpisodeListWidgetState extends State<EpisodeListWidget>
    with AutomaticKeepAliveClientMixin {
  TVDetails? tvDetails;
  bool _lockTap = false;

  void _suppressTap() {
    setState(() => _lockTap = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _lockTap = false);
    });
  }

  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchTVDetails(widget.api!, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          tvDetails = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return Container(
        child: tvDetails == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, left: 8.0, right: 8.0),
                          child: Row(
                            children: [
                              const LeadingDot(),
                              Expanded(
                                child: Text(
                                  tr("episodes"),
                                  style: kTextHeaderStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: 10,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          padding: const EdgeInsets.only(right: 10),
                          child: Column(
                            children: [
                              ShimmerBase(
                                themeMode: themeMode,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 10.0, left: 5.0),
                                      child: Container(
                                        height: 90.0,
                                        width: 160,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(3.0),
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 2.0),
                                            child: Container(
                                                color: Colors.grey.shade600,
                                                height: 19,
                                                width: 150),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 2.0),
                                            child: Container(
                                                color: Colors.grey.shade600,
                                                height: 19,
                                                width: 110),
                                          ),
                                          Row(children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 3.0),
                                              child: Container(
                                                  color: Colors.grey.shade600,
                                                  height: 20,
                                                  width: 20),
                                            ),
                                            Container(
                                                color: Colors.grey.shade600,
                                                height: 20,
                                                width: 25),
                                          ]),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Divider(
                                color: Theme.of(context).colorScheme.primary,
                                thickness: 0.5,
                                endIndent: 5,
                                indent: 5,
                              ),
                            ],
                          ),
                        );
                      }),
                ],
              )
            : tvDetails!.episodes!.isEmpty
                ? Center(
                    child:
                        Text(tr("no_episodes"), style: kTextSmallHeaderStyle),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Row(
                          children: [
                            const LeadingDot(),
                            Expanded(
                              child: Text(
                                tr("episodes"),
                                style: kTextHeaderStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Consumer<RecentProvider>(
                        builder: (context, recentProvider, child) {
                          return ListView.builder(
                              shrinkWrap: true,
                              itemCount: tvDetails!.episodes!.length,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemBuilder: (BuildContext context, int index) {
                                final isDark = themeMode == 'dark' ||
                                    themeMode == 'amoled';
                                final elevated = isDark
                                    ? _C.bgElevatedDark
                                    : _C.bgElevatedLight;
                                final border =
                                    isDark ? _C.borderDark : _C.borderLight;
                                final textPrim =
                                    isDark ? _C.textPrimDark : _C.textPrimLight;
                                final textSec =
                                    isDark ? _C.textSecDark : _C.textSecLight;
                                final ep = tvDetails!.episodes![index];
                                final stillPath = ep.stillPath;
                                final hasStill =
                                    stillPath != null && stillPath.isNotEmpty;

                                final isWatched = recentProvider.episodes.any(
                                    (e) =>
                                        e.seriesId == widget.tvId &&
                                        e.seasonNum == ep.seasonNumber &&
                                        e.episodeNum == ep.episodeNumber &&
                                        ((e.elapsed ?? 0) +
                                                (e.remaining ?? 0)) >
                                            0 &&
                                        ((e.elapsed ?? 0) /
                                                ((e.elapsed ?? 0) +
                                                    (e.remaining ?? 0))) >=
                                            0.9);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        if (_lockTap) return;
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EpisodeDetailPage(
                                                      seriesName:
                                                          widget.seriesName,
                                                      posterPath:
                                                          widget.posterPath,
                                                      tvId: widget.tvId,
                                                      episodes:
                                                          tvDetails!.episodes,
                                                      episodeList: ep,
                                                    )));
                                      },
                                      onLongPress: () {
                                        _suppressTap();
                                        MobileContextMenu.show(
                                          context: context,
                                          title: ep.name ??
                                              'Episode ${ep.episodeNumber}',
                                          subtitle:
                                              'S${ep.seasonNumber} | E${ep.episodeNumber}',
                                          items: [
                                            MobileContextMenuItem(
                                              label: tr("mark_as_completed"),
                                              icon: Icons.check_circle_outline,
                                              onTap: () {
                                                final recentEp = RecentEpisode(
                                                  dateTime: DateTime.now()
                                                      .toIso8601String(),
                                                  elapsed: 3600,
                                                  episodeName: ep.name,
                                                  episodeNum: ep.episodeNumber,
                                                  id: ep.episodeId,
                                                  posterPath: widget.posterPath,
                                                  remaining: 0,
                                                  seasonNum: ep.seasonNumber,
                                                  seriesName: widget.seriesName,
                                                  seriesId: widget.tvId,
                                                );
                                                recentProvider
                                                    .markEpisodeAsCompleted(
                                                        recentEp);
                                              },
                                            ),
                                            MobileContextMenuItem(
                                              label:
                                                  tr("mark_watched_until_here"),
                                              icon: Icons
                                                  .playlist_add_check_rounded,
                                              onTap: () {
                                                recentProvider
                                                    .markUntilEpisodeAsCompleted(
                                                  allEpisodes:
                                                      tvDetails!.episodes!,
                                                  targetEpisode: ep,
                                                  tvId: widget.tvId,
                                                  seriesName: widget.seriesName,
                                                  posterPath: widget.posterPath,
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: LayoutBuilder(
                                          builder: (context, constraints) {
                                        final imgWidth =
                                            (constraints.maxWidth * 0.38)
                                                .clamp(120.0, 180.0);
                                        final imgHeight = imgWidth * (9 / 16);
                                        return Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: elevated,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                                color: border, width: 1),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Stack(
                                                  children: [
                                                    SizedBox(
                                                      height: imgHeight,
                                                      width: imgWidth,
                                                      child: !hasStill
                                                          ? Image.asset(
                                                              'assets/images/na_logo.png',
                                                              fit: BoxFit.cover,
                                                              width: double
                                                                  .infinity,
                                                            )
                                                          : CachedNetworkImage(
                                                              cacheManager:
                                                                  cacheProp(),
                                                              fadeOutDuration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          300),
                                                              fadeInDuration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          700),
                                                              imageUrl: buildImageUrl(
                                                                      tmdbBaseImageUrl,
                                                                      proxyUrl,
                                                                      isProxyEnabled,
                                                                      context) +
                                                                  imageQuality +
                                                                  stillPath,
                                                              fit: BoxFit.cover,
                                                              placeholder: (_,
                                                                      __) =>
                                                                  ShimmerBase(
                                                                themeMode:
                                                                    themeMode,
                                                                child: Container(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade600),
                                                              ),
                                                              errorWidget: (_,
                                                                      __,
                                                                      ___) =>
                                                                  Image.asset(
                                                                'assets/images/na_logo.png',
                                                                fit: BoxFit.cover,
                                                                width: double
                                                                    .infinity,
                                                              ),
                                                            ),
                                                    ),
                                                    if (isWatched)
                                                      Positioned(
                                                        top: 6,
                                                        right: 6,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: _C.primary,
                                                            shape:
                                                                BoxShape.circle,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withValues(
                                                                        alpha:
                                                                            0.3),
                                                                blurRadius: 4,
                                                                offset:
                                                                    const Offset(
                                                                        0, 2),
                                                              ),
                                                            ],
                                                          ),
                                                          child: const Icon(
                                                            Icons.check,
                                                            color: Colors.white,
                                                            size: 14,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 3),
                                                      decoration: BoxDecoration(
                                                        color: _C.primary
                                                            .withValues(
                                                                alpha: 0.15),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                      ),
                                                      child: Text(
                                                        'E${ep.episodeNumber! <= 9 ? ep.episodeNumber.toString().padLeft(2, '0') : ep.episodeNumber}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: _C.primary,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      ep.name ?? '—',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: textPrim,
                                                        height: 1.2,
                                                        fontFamily: 'PoppinsSB',
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Wrap(
                                                      spacing: 12,
                                                      runSpacing: 4,
                                                      crossAxisAlignment:
                                                          WrapCrossAlignment
                                                              .center,
                                                      children: [
                                                        if (ep.airDate !=
                                                                null &&
                                                            ep.airDate!
                                                                .isNotEmpty) ...[
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .calendar_month_rounded,
                                                                size: 14,
                                                                color: textSec,
                                                              ),
                                                              const SizedBox(
                                                                  width: 4),
                                                              Text(
                                                                '${DateTime.parse(ep.airDate!).day} ${DateFormat("MMM").format(DateTime.parse(ep.airDate!))} ${DateTime.parse(ep.airDate!).year}',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      textSec,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                        if (ep.voteAverage !=
                                                                null &&
                                                            ep.voteAverage! > 0)
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .star_rounded,
                                                                size: 16,
                                                                color: _C
                                                                    .ratingGold,
                                                              ),
                                                              const SizedBox(
                                                                  width: 4),
                                                              Text(
                                                                ep.voteAverage!
                                                                    .toStringAsFixed(
                                                                        1),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      textSec,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                );
                              });
                        },
                      ),
                    ],
                  ));
  }

  @override
  bool get wantKeepAlive => true;
}
