import 'package:reelriot/functions/network.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/models/watch_providers.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/widgets/common_widgets.dart';
import 'package:reelriot/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';

// ─── Design tokens (design.json) ─────────────────────────────────────────────
class _Design {
  static const primary = Color(0xFFDC2626);
  static const bgCanvasDark = Color(0xFF030712);
  static const bgCanvasLight = Color(0xFFF8FAFC);
  static const bgSurfaceDark = Color(0xFF0B0F14);
  static const bgSurfaceLight = Color(0xFFFFFFFF);
  static const borderDark = Color(0x14FFFFFF);
  static const borderLight = Color(0x140F172A);
  static const textTertDark = Color(0x80FFFFFF);
  static const textTertLight = Color(0xFF94A3B8);
}

class WatchProvidersDetails extends StatefulWidget {
  final String api;
  final String country;
  const WatchProvidersDetails(
      {super.key, required this.api, required this.country});

  @override
  State<WatchProvidersDetails> createState() => _WatchProvidersDetailsState();
}

class _WatchProvidersDetailsState extends State<WatchProvidersDetails>
    with SingleTickerProviderStateMixin {
  WatchProviders? watchProviders;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchWatchProviders(widget.api, widget.country, isProxyEnabled, proxyUrl)
        .then((value) {
      if (mounted) {
        setState(() {
          watchProviders = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isDark = themeMode == 'dark' || themeMode == 'amoled';
    final bg = isDark ? _Design.bgCanvasDark : _Design.bgCanvasLight;
    final surface = isDark ? _Design.bgSurfaceDark : _Design.bgSurfaceLight;
    final border = isDark ? _Design.borderDark : _Design.borderLight;
    final textTert = isDark ? _Design.textTertDark : _Design.textTertLight;

    return Container(
      color: bg,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: surface,
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: Center(
              child: TabBar(
                controller: tabController,
                isScrollable: true,
                indicatorColor: _Design.primary,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: _Design.primary,
                unselectedLabelColor: textTert,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(text: tr("buy")),
                  Tab(text: tr("stream")),
                  Tab(text: tr("rent")),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: bg,
              child: TabBarView(
                controller: tabController,
                children: watchProviders == null
                    ? [
                        watchProvidersShimmer(themeMode),
                        watchProvidersShimmer(themeMode),
                        watchProvidersShimmer(themeMode),
                      ]
                    : [
                        watchProvidersTabData(
                            themeMode: themeMode,
                            imageQuality: imageQuality,
                            noOptionMessage: tr("no_buy"),
                            watchOptions: watchProviders!.buy,
                            context: context),
                        watchProvidersTabData(
                            themeMode: themeMode,
                            imageQuality: imageQuality,
                            noOptionMessage: tr("no_stream"),
                            watchOptions: watchProviders!.flatRate,
                            context: context),
                        watchProvidersTabData(
                            themeMode: themeMode,
                            imageQuality: imageQuality,
                            noOptionMessage: tr("no_rent"),
                            watchOptions: watchProviders!.rent,
                            context: context),
                      ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
