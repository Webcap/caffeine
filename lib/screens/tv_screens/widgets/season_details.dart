import 'package:reelriot/screens/tv_screens/widgets/season_detail_expanded_layout.dart';
import 'package:reelriot/screens/tv_screens/widgets/tv_season_about.dart';
import 'package:reelriot/screens/tv_screens/widgets/tv_season_details_quickinfo.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/models/tv.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/common/sabth.dart';
import 'package:provider/provider.dart';

class SeasonsDetail extends StatefulWidget {
  final Seasons seasons;
  final String heroId;
  final int? tvId;
  final String? seriesName;
  final TVDetails tvDetails;

  const SeasonsDetail({
    super.key,
    required this.seasons,
    required this.heroId,
    required this.tvDetails,
    this.seriesName,
    this.tvId,
  });

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
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isExpanded = MediaQuery.sizeOf(context).width >= 840;

    if (isExpanded) {
      return Scaffold(
        body: SeasonDetailExpandedLayout(
          season: widget.seasons,
          heroId: widget.heroId,
          tvDetails: widget.tvDetails,
          seriesName: widget.seriesName,
          tvId: widget.tvId,
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 1,
            shadowColor: themeMode == "dark" || themeMode == "amoled"
                ? Colors.white
                : Colors.black,
            forceElevated: true,
            backgroundColor: themeMode == "dark" || themeMode == "amoled"
                ? Colors.black
                : Colors.white,
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
                color: Theme.of(context).colorScheme.onSurface,
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
