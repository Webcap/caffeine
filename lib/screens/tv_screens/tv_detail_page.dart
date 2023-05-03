// ignore_for_file: avoid_unnecessary_containers

import 'package:cached_network_image/cached_network_image.dart';
import 'package:login/provider/settings_provider.dart';
import 'package:login/screens/common/sabth.dart';
import 'package:login/screens/tv_screens/widgets/scrolling_tv_widget.dart';
import 'package:login/screens/tv_screens/widgets/tv_about.dart';
import 'package:login/screens/tv_screens/widgets/tv_detail_options.dart';
import 'package:login/screens/tv_screens/widgets/tv_detail_quick_info.dart';
import 'package:login/screens/tv_screens/widgets/tv_widgets.dart';
import 'package:login/utils/config.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
import '/models/tv.dart';
import 'package:flutter/material.dart';
import '/api/endpoints.dart';
import 'package:intl/intl.dart';

import 'widgets/tv_genre_widgets.dart';

class TVDetailPage extends StatefulWidget {
  final TV tvSeries;
  final String heroId;

  const TVDetailPage({
    Key? key,
    required this.tvSeries,
    required this.heroId,
  }) : super(key: key);
  @override
  TVDetailPageState createState() => TVDetailPageState();
}

class TVDetailPageState extends State<TVDetailPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<TVDetailPage> {
  late TabController tabController;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 6, vsync: this);
    mixpanelUpload(context);
  }

  void mixpanelUpload(BuildContext context) {
    final mixpanel =
        Provider.of<SettingsProvider>(context, listen: false).mixpanel;
    mixpanel.track('Most viewed TV pages', properties: {
      'TV series name': '${widget.tvSeries.name}',
      'TV series id': '${widget.tvSeries.id}',
      'Is TV series adult?': '${widget.tvSeries.adult}'
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 1,
            shadowColor: isDark ? Colors.white : Colors.black,
            forceElevated: true,
            backgroundColor: isDark ? Colors.black : Colors.white,
            leading: SABTN(
              onBack: () {
                Navigator.pop(context);
              },
            ),
            title: SABT(
                child: Text(
              widget.tvSeries.firstAirDate == ""
                  ? widget.tvSeries.name!
                  : '${widget.tvSeries.name!} (${DateTime.parse(widget.tvSeries.firstAirDate!).year})',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            )),
            expandedHeight: 380,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Column(
                children: [
                  TVDetailQuickInfo(
                      tvSeries: widget.tvSeries, heroId: widget.heroId),

                  const SizedBox(height: 18),

                  // ratings / lists / bookmark options
                  TVDetailOptions(tvSeries: widget.tvSeries),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              [TVAbout(tvSeries: widget.tvSeries)],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Share.share(
                'Checkout the TV show \'${widget.tvSeries.name}\'!\nIt is rated ${widget.tvSeries.voteAverage!.toStringAsFixed(1)} out of 10\nhttps://themoviedb.org/tv/${widget.tvSeries.id}');
          },
          child: const Icon(Icons.share)),
    );
  }

  @override
  bool get wantKeepAlive => true;

  // void modalBottomSheetMenu(String country) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (builder) {
  //       return TVWatchProvidersDetails(
  //         api: Endpoints.getTVWatchProviders(widget.tvSeries.id!),
  //         country: country,
  //       );
  //     },
  //   );
  // }
}

