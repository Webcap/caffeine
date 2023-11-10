import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/movies_api.dart';
import 'package:caffiene/models/watch_providers.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/widgets/common_widgets.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';

class WatchProvidersDetails extends StatefulWidget {
  final String api;
  final String country;
  const WatchProvidersDetails(
      {Key? key, required this.api, required this.country})
      : super(key: key);

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
    moviesApi().fetchWatchProviders(widget.api, widget.country).then((value) {
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
    return Container(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(),
            child: Center(
              child: TabBar(
                controller: tabController,
                isScrollable: true,
                indicatorWeight: 3,
                unselectedLabelColor: Colors.white54,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(
                    child: Text(tr("buy"),
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: themeMode == "dark" || themeMode == "amoled"
                                ? Colors.white
                                : Colors.black)),
                  ),
                  Tab(
                    child: Text(tr("stream"),
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: themeMode == "dark" || themeMode == "amoled"
                                ? Colors.white
                                : Colors.black)),
                  ),
                  Tab(
                    child: Text(tr("rent"),
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: themeMode == "dark" || themeMode == "amoled"
                                ? Colors.white
                                : Colors.black)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: themeMode == "dark" || themeMode == "amoled"
                  ? Colors.black
                  : Colors.white,
              child: TabBarView(
                controller: tabController,
                children: watchProviders == null
                    ? [
                        watchProvidersShimmer(themeMode),
                        watchProvidersShimmer(themeMode),
                        watchProvidersShimmer(themeMode),
                        watchProvidersShimmer(themeMode),
                      ]
                    : [
                        watchProvidersTabData(
                            themeMode: themeMode,
                            imageQuality: imageQuality,
                            noOptionMessage: tr("no_buy"),
                            watchOptions: watchProviders!.buy),
                        watchProvidersTabData(
                            themeMode: themeMode,
                            imageQuality: imageQuality,
                            noOptionMessage: tr("no_stream"),
                            watchOptions: watchProviders!.flatRate),
                        watchProvidersTabData(
                            themeMode: themeMode,
                            imageQuality: imageQuality,
                            noOptionMessage: tr("no_rent"),
                            watchOptions: watchProviders!.rent),
                      ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
