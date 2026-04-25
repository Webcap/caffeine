import 'package:cached_network_image/cached_network_image.dart';
import 'package:reelriot/api/endpoints.dart';
import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/models/movie_models.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/movie_screens/widgets/collecrions_widget.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/widgets/common_widgets.dart';
import 'package:reelriot/widgets/shimmer_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reelriot/utils/constant.dart';

// ─── Design tokens (design.json) ─────────────────────────────────────────────
class _Design {
  static const primary = Color(0xFFDC2626);
  static const primaryLight = Color(0xFFEF4444);
  static const bgCanvasDark = Color(0xFF030712);
  static const bgSurfaceDark = Color(0xFF0B0F14);
  static const bgElevatedDark = Color(0x0DFFFFFF);
  static const textPrimDark = Color(0xFFFFFFFF);
  static const textSecDark = Color(0xB8FFFFFF);
  static const textTerDark = Color(0x80FFFFFF);
  static const borderDark = Color(0x14FFFFFF);
  static const iconBgDark = Color(0x14FFFFFF);
  static const bgCanvasLight = Color(0xFFF8FAFC);
  static const bgSurfaceLight = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
  static const textSecLight = Color(0xFF64748B);
  static const borderLight = Color(0x140F172A);

  static const radiusMd = 16.0;
  static const radiusLg = 20.0;
  static const radiusXl = 24.0;
  static const space2 = 8.0;
  static const space3 = 12.0;
  static const space4 = 16.0;
  static const space5 = 20.0;
  static const space6 = 24.0;
  static const screenPadH = 16.0;
  static const shadowCard = BoxShadow(
    color: Color(0x38000000),
    blurRadius: 30,
    offset: Offset(0, 10),
  );
  static const heroOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x0D000000),
      Color(0x73000000),
      Color(0xEB000000),
    ],
    stops: [0.0, 0.45, 1.0],
  );
}

class CollectionDetailsWidget extends StatefulWidget {
  final BelongsToCollection? belongsToCollection;

  const CollectionDetailsWidget({
    super.key,
    this.belongsToCollection,
  });
  @override
  CollectionDetailsWidgetState createState() => CollectionDetailsWidgetState();
}

class CollectionDetailsWidgetState extends State<CollectionDetailsWidget>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<CollectionDetailsWidget> {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    final isDark = themeMode == 'dark' || themeMode == 'amoled';

    final bg = isDark ? _Design.bgCanvasDark : _Design.bgCanvasLight;
    final surface = isDark ? _Design.bgSurfaceDark : _Design.bgSurfaceLight;
    final textPrim = isDark ? _Design.textPrimDark : _Design.textPrimLight;
    final textSec = isDark ? _Design.textSecDark : _Design.textSecLight;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: bg,
        body: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor:
                  isDark ? _Design.bgSurfaceDark : _Design.bgSurfaceLight,
              leading: Padding(
                padding: const EdgeInsets.only(left: _Design.space2),
                child: _CircleIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.pop(context),
                  isDark: isDark,
                ),
              ),
              title: Text(
                widget.belongsToCollection!.name!,
                style: TextStyle(
                  color: textPrim,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              expandedHeight: 320,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Backdrop image
                    if (widget.belongsToCollection!.backdropPath != null)
                      CachedNetworkImage(
                        cacheManager: cacheProp(),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: surface,
                          child: Center(
                            child: Image.asset(
                              'assets/images/na_logo.png',
                              fit: BoxFit.contain,
                              width: 48,
                              height: 48,
                            ),
                          ),
                        ),
                        imageUrl:
                            '${buildImageUrl(tmdbBaseImageUrl, proxyUrl, isProxyEnabled, context)}original/${widget.belongsToCollection!.backdropPath!}',
                        errorWidget: (context, url, error) => Container(
                          color: surface,
                          child: Icon(Icons.movie_rounded,
                              size: 64, color: textSec),
                        ),
                      )
                    else
                      Container(color: surface),
                    // Hero overlay (design.json: heroOverlayDark)
                    DecoratedBox(
                      decoration: BoxDecoration(gradient: _Design.heroOverlay),
                    ),
                    // Poster + title at bottom of hero
                    Positioned(
                      left: _Design.screenPadH,
                      right: _Design.screenPadH,
                      bottom: _Design.space4,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(_Design.radiusMd),
                            child: SizedBox(
                              width: 94,
                              height: 140,
                              child:
                                  widget.belongsToCollection!.posterPath == null
                                      ? Image.asset(
                                          'assets/images/na_logo.png',
                                          fit: BoxFit.cover,
                                        )
                                      : CachedNetworkImage(
                                          cacheManager: cacheProp(),
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              scrollingImageShimmer(themeMode),
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                            'assets/images/na_logo.png',
                                            fit: BoxFit.cover,
                                          ),
                                          imageUrl: buildImageUrl(
                                                tmdbBaseImageUrl,
                                                proxyUrl,
                                                isProxyEnabled,
                                                context,
                                              ) +
                                              imageQuality +
                                              widget.belongsToCollection!
                                                  .posterPath!,
                                        ),
                            ),
                          ),
                          const SizedBox(width: _Design.space4),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                widget.belongsToCollection!.name!,
                                style: TextStyle(
                                  color: textPrim,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: _Design.space6),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: _Design.screenPadH),
                    child: Row(
                      children: [
                        const LeadingDot(),
                        Text(
                          tr('overview'),
                          style: TextStyle(
                            color: textPrim,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: _Design.space3),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: _Design.screenPadH),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(_Design.space4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? _Design.bgElevatedDark
                            : _Design.bgCanvasLight,
                        borderRadius: BorderRadius.circular(_Design.radiusMd),
                        border: Border.all(
                          color:
                              isDark ? _Design.borderDark : _Design.borderLight,
                          width: 1,
                        ),
                        boxShadow: [_Design.shadowCard],
                      ),
                      child: CollectionOverviewWidget(
                        api: Endpoints.getCollectionDetails(
                          widget.belongsToCollection!.id!,
                          lang,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: _Design.space6),
                  PartsList(
                    title: tr('movies'),
                    api: Endpoints.getCollectionDetails(
                      widget.belongsToCollection!.id!,
                      lang,
                    ),
                  ),
                  const SizedBox(height: _Design.space6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _Design.iconBgDark,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22, color: _Design.textPrimDark),
        ),
      ),
    );
  }
}
