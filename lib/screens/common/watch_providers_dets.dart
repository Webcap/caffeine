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
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
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
                    child: Text('Buy',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white : Colors.black)),
                  ),
                  Tab(
                    child: Text('Stream',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white : Colors.black)),
                  ),
                  Tab(
                    child: Text('Rent',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white : Colors.black)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: isDark ? Colors.black : Colors.white,
              child: TabBarView(
                controller: tabController,
                children: watchProviders == null
                    ? [
                        watchProvidersShimmer(isDark),
                        watchProvidersShimmer(isDark),
                        watchProvidersShimmer(isDark),
                        watchProvidersShimmer(isDark),
                      ]
                    : [
                        watchProvidersTabData(
                            isDark: isDark,
                            imageQuality: imageQuality,
                            noOptionMessage:
                                'This movie doesn\'t have an option to buy yet',
                            watchOptions: watchProviders!.buy),
                        watchProvidersTabData(
                            isDark: isDark,
                            imageQuality: imageQuality,
                            noOptionMessage:
                                'This movie doesn\'t have an option to stream yet',
                            watchOptions: watchProviders!.flatRate),
                        watchProvidersTabData(
                            isDark: isDark,
                            imageQuality: imageQuality,
                            noOptionMessage:
                                'This movie doesn\'t have an option to rent yet',
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
