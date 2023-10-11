import 'package:flutter/material.dart';
import 'package:caffiene/models/movie_models.dart';
import 'package:caffiene/models/tv.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/common/sabth.dart';
import 'package:caffiene/screens/tv_screens/widgets/episode_about.dart';
import 'package:caffiene/screens/tv_screens/widgets/tv_episode_option.dart';
import 'package:caffiene/screens/tv_screens/widgets/tv_episode_quick_info.dart';
import 'package:provider/provider.dart';

class EpisodeDetailPage extends StatefulWidget {
  final EpisodeList episodeList;
  final List<EpisodeList>? episodes;
  final int? tvId;
  final String? seriesName;
  final String? posterPath;

  const EpisodeDetailPage({
    Key? key,
    required this.episodeList,
    this.episodes,
    this.tvId,
    this.seriesName,
    required this.posterPath,
  }) : super(key: key);

  @override
  EpisodeDetailPageState createState() => EpisodeDetailPageState();
}

class EpisodeDetailPageState extends State<EpisodeDetailPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<EpisodeDetailPage> {
  bool? isVisible = false;
  double? buttonWidth = 150;
  ExternalLinks? externalLinks;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    mixpanelUpload(context);
  }

  void mixpanelUpload(BuildContext context) {
    final mixpanel =
        Provider.of<SettingsProvider>(context, listen: false).mixpanel;
    mixpanel.track('Most viewed episode details', properties: {
      'TV series name': '${widget.seriesName}',
      'TV series episode name': '${widget.episodeList.name}',
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
            expandedHeight: 375,
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
              posterPath: widget.posterPath,
            )
          ]))
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
