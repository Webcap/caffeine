import 'package:caffiene/screens/tv_screens/widgets/tv_season_about.dart';
import 'package:caffiene/screens/tv_screens/widgets/tv_season_details_quickinfo.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/models/tv.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/common/sabth.dart';
import 'package:provider/provider.dart';

class SeasonsDetail extends StatefulWidget {
  final Seasons seasons;
  final String heroId;
  final int? tvId;
  final String? seriesName;
  final TVDetails tvDetails;

  const SeasonsDetail({
    Key? key,
    required this.seasons,
    required this.heroId,
    required this.tvDetails,
    this.seriesName,
    this.tvId,
  }) : super(key: key);

  @override
  SeasonsDetailState createState() => SeasonsDetailState();
}

class SeasonsDetailState extends State<SeasonsDetail>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<SeasonsDetail> {
  late TabController tabController;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    mixpanelUpload(context);
  }

  void mixpanelUpload(BuildContext context) {
    final mixpanel =
        Provider.of<SettingsProvider>(context, listen: false).mixpanel;
    mixpanel.track('Most viewed season details', properties: {
      'TV series name': '${widget.seriesName}',
      'TV series season number': '${widget.seasons.seasonNumber}',
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
              widget.seasons.airDate == null || widget.seasons.airDate == ""
                  ? widget.seasons.name!
                  : '${widget.seasons.name!} (${DateTime.parse(widget.seasons.airDate!).year})',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            )),
            expandedHeight: 315,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Column(
                children: [
                  TVSeasonDetailQuickInfo(
                      tvSeries: widget.tvDetails,
                      heroId: widget.heroId,
                      season: widget.seasons),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              [
                TVSeasonAbout(
                  season: widget.seasons,
                  tvDetails: widget.tvDetails,
                  seriesName: widget.seriesName,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
