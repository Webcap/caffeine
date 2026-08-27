import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/models/recently_watched.dart';
import 'package:reelriot/models/tv_stream_metadata.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/recently_watched_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/utils/constant.dart';
import 'package:reelriot/utils/globals.dart';
import 'package:reelriot/utils/globlal_methods.dart';
import 'package:reelriot/utils/theme/textStyle.dart';
import 'package:reelriot/widgets/common_widgets.dart';
import 'package:reelriot/widgets/mobile_context_menu.dart';
import 'package:reelriot/widgets/shimmer_widget.dart';
import 'package:reelriot/widgets/unified_video_loader.dart';

class _C {
  static const primary = Color(0xFFDC2626);
  static const textPrimDark = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
}

class ScrollingRecentEpisodes extends StatefulWidget {
  const ScrollingRecentEpisodes({
    required this.episodesList,
    required this.title,
    super.key,
  });

  final List<RecentEpisode> episodesList;
  final String title;

  @override
  State<ScrollingRecentEpisodes> createState() =>
      _ScrollingRecentEpisodesState();
}

class _ScrollingRecentEpisodesState extends State<ScrollingRecentEpisodes> {
  final ScrollController _scrollController = ScrollController();
  bool _lockTap = false;

  void _suppressTap() {
    setState(() => _lockTap = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _lockTap = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final appDep = Provider.of<AppDependencyProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageQuality = settings.imageQuality;
    final themeMode = settings.appTheme;
    final fetchRoute = appDep.fetchRoute;
    final proxyUrl = appDep.tmdbProxy;
    final isProxyEnabled = settings.enableProxy;

    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final cardWidth = isTablet ? 250.0 : 200.0;
    final cardHeight = isTablet ? 155.0 : 130.0;
    final textPrim = isDark ? _C.textPrimDark : _C.textPrimLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Section Header
        Padding(
          padding: EdgeInsets.fromLTRB(
            isTablet ? 20 : 16,
            8,
            isTablet ? 20 : 16,
            10,
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _C.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: isTablet ? 19 : 17,
                    fontWeight: FontWeight.w700,
                    color: textPrim,
                    fontFamily: 'PoppinsSB',
                  ),
                ),
              ),
            ],
          ),
        ),

        // Landscape episode cards
        SizedBox(
          height: cardHeight,
          child: ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 12),
            itemCount: widget.episodesList.length,
            itemBuilder: (BuildContext ctx, int index) {
              final ep = widget.episodesList[index];
              final recentEpisodes =
                  Provider.of<RecentProvider>(ctx, listen: false);

              final imgBase = buildImageUrl(
                tmdbBaseImageUrl,
                proxyUrl,
                isProxyEnabled,
                context,
              );
              final imageUrl = ep.posterPath != null && ep.posterPath!.isNotEmpty
                  ? '$imgBase$imageQuality${ep.posterPath}'
                  : '';

              final elapsed = ep.elapsed ?? 0;
              final remaining = ep.remaining ?? 0;
              final total = elapsed + remaining;
              final progress = total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 0.0;

              final seasonStr = (ep.seasonNum ?? 0).toString().padLeft(2, '0');
              final epStr = (ep.episodeNum ?? 0).toString().padLeft(2, '0');

              return Padding(
                padding: EdgeInsets.only(right: isTablet ? 14 : 10),
                child: GestureDetector(
                  onLongPress: () {
                    _suppressTap();
                    MobileContextMenu.show(
                      context: ctx,
                      title: ep.seriesName ?? '',
                      subtitle: 'S$seasonStr | E$epStr - ${ep.episodeName ?? ''}',
                      items: [
                        MobileContextMenuItem(
                          label: tr("mark_as_completed"),
                          icon: Icons.check_circle_outline,
                          onTap: () {
                            recentEpisodes.markEpisodeAsCompleted(ep);
                          },
                        ),
                        MobileContextMenuItem(
                          label: tr("remove_from_history"),
                          icon: Icons.delete_outline,
                          color: Colors.red,
                          onTap: () {
                            recentEpisodes.deleteEpisode(
                              ep.id!,
                              ep.episodeNum!,
                              ep.seasonNum!,
                            );
                          },
                        ),
                      ],
                    );
                  },
                  onTap: () async {
                    if (_lockTap) return;
                    final connected = await checkConnection();
                    if (!ctx.mounted) return;
                    if (connected) {
                      Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) => UnifiedVideoLoader(
                            mediaType: MediaType.tvShow,
                            download: false,
                            route: fetchRoute == "flixHQ"
                                ? StreamRoute.flixHQ
                                : StreamRoute.tmDB,
                            tvMetadata: TVStreamMetadata(
                              elapsed: ep.elapsed,
                              episodeId: ep.id,
                              episodeName: ep.episodeName,
                              episodeNumber: ep.episodeNum,
                              posterPath: ep.posterPath,
                              seasonNumber: ep.seasonNum,
                              seriesName: ep.seriesName,
                              tvId: ep.seriesId,
                              airDate: null,
                            ),
                          ),
                        ),
                      );
                    } else {
                      GlobalMethods.showCustomScaffoldMessage(
                        SnackBar(
                          content: Text(
                            tr("check_connection"),
                            style: kTextSmallBodyStyle,
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                        ctx,
                      );
                    }
                  },
                  child: SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(isTablet ? 16 : 12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background image
                          imageUrl.isEmpty
                              ? Image.asset(
                                  'assets/images/na_logo.png',
                                  fit: BoxFit.cover,
                                )
                              : CachedNetworkImage(
                                  cacheManager: cacheProp(),
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) =>
                                      scrollingImageShimmer(themeMode),
                                  errorWidget: (_, __, ___) => Image.asset(
                                    'assets/images/na_logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),

                          // Dark gradient overlay
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.85),
                                  ],
                                  stops: const [0.2, 1.0],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),

                          // Season / Episode Badge (Top Left)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _C.primary.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                'S$seasonStr · E$epStr',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),

                          // Play Button Overlay (Center)
                          Center(
                            child: Container(
                              width: isTablet ? 40 : 34,
                              height: isTablet ? 40 : 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.45),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                size: isTablet ? 24 : 20,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // Title and Subtitle (Bottom)
                          Positioned(
                            left: 10,
                            right: 10,
                            bottom: 10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  ep.seriesName ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                if (ep.episodeName != null &&
                                    ep.episodeName!.isNotEmpty) ...[
                                  const SizedBox(height: 1),
                                  Text(
                                    ep.episodeName!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: isTablet ? 11 : 10,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white70,
                                      shadows: const [
                                        Shadow(
                                          color: Colors.black,
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Progress Indicator (Bottom edge)
                          if (progress > 0)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 3.5,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  _C.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Divider(
          color: isDark ? Colors.white12 : Colors.black12,
          thickness: 1,
          endIndent: isTablet ? 24 : 20,
          indent: isTablet ? 24 : 10,
        ),
      ],
    );
  }
}
