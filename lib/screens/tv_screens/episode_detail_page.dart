import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:login/api/endpoints.dart';
import 'package:login/api/movies_api.dart';
import 'package:login/models/movie_models.dart';
import 'package:login/models/tv.dart';
import 'package:login/provider/settings_provider.dart';
import 'package:login/screens/common/sabth.dart';
import 'package:login/screens/tv_screens/widgets/episode_about.dart';
import 'package:login/screens/tv_screens/widgets/scrolling_tv_widget.dart';
import 'package:login/screens/tv_screens/widgets/tv_episode_option.dart';
import 'package:login/screens/tv_screens/widgets/tv_episode_quick_info.dart';
import 'package:login/screens/tv_screens/widgets/tv_widgets.dart';
import 'package:login/utils/config.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

class EpisodeDetailPage extends StatefulWidget {
  final EpisodeList episodeList;
  final List<EpisodeList>? episodes;
  final int? tvId;
  final String? seriesName;

  const EpisodeDetailPage({
    Key? key,
    required this.episodeList,
    this.episodes,
    this.tvId,
    this.seriesName,
  }) : super(key: key);

  @override
  EpisodeDetailPageState createState() => EpisodeDetailPageState();
}

class EpisodeDetailPageState extends State<EpisodeDetailPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<EpisodeDetailPage> {
  late TabController tabController;
  bool? isVisible = false;
  double? buttonWidth = 150;
  ExternalLinks? externalLinks;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    // mixpanelUpload(context);
  }

  // void mixpanelUpload(BuildContext context) {
  //   final mixpanel =
  //       Provider.of<MixpanelProvider>(context, listen: false).mixpanel;
  //   mixpanel.track('Most viewed episode details', properties: {
  //     'TV series name': '${widget.seriesName}',
  //     'TV series episode name': '${widget.episodeList.name}',
  //   });
  // }

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
            forceElevated: true,
            backgroundColor: isDark ? Colors.black : Colors.white,
            shadowColor: isDark ? Colors.white : Colors.black,
            leading: SABTN(
              onBack: () {
                Navigator.pop(context);
              },
            ),
            title: SABT(
                child: Text(
              widget.episodeList.name!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            )),
            expandedHeight: 360,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Column(
                children: [
                  TVEpisodeQuickInfo(
                    episodeList: widget.episodeList,
                    seriesName: widget.seriesName,
                    tvId: widget.tvId,
                  ),
                  TVEpisodeOptions(episodeList: widget.episodeList)
                ],
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate.fixed([
            EpisodeAbout(
              episodeList: widget.episodeList,
              seriesName: widget.seriesName,
              tvId: widget.tvId,
            )
          ]))
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

