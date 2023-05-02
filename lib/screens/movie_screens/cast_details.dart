import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:login/api/endpoints.dart';
import 'package:login/models/credits.dart';
import 'package:login/provider/imagequality_provider.dart';
import 'package:login/provider/settings_provider.dart';
import 'package:login/screens/movie_screens/widgets/cast_detail_about.dart';
import 'package:login/screens/movie_screens/widgets/cast_details_quick_info.dart';
import 'package:login/screens/person/widgets/person_widget.dart';
import 'package:login/screens/common/sabth.dart';
import 'package:login/utils/config.dart';
import 'package:provider/provider.dart';

class CastDetailPage extends StatefulWidget {
  final Cast? cast;
  final String heroId;

  const CastDetailPage({
    Key? key,
    this.cast,
    required this.heroId,
  }) : super(key: key);
  @override
  CastDetailPageState createState() => CastDetailPageState();
}

class CastDetailPageState extends State<CastDetailPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<CastDetailPage> {
  late TabController tabController;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 3, vsync: this);
    // mixpanelUpload(context);
  }

  // void mixpanelUpload(BuildContext context) {
  //   final mixpanel =
  //       Provider.of<MixpanelProvider>(context, listen: false).mixpanel;
  //   mixpanel.track('Most viewed person pages', properties: {
  //     'Person name': '${widget.cast!.name}',
  //     'Person id': '${widget.cast!.id}'
  //   });
  // }

  int selectedIndex = 0;
  final scrollController = ScrollController();

  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
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
              widget.cast!.name!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            )),
            expandedHeight: 210,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Column(
                children: [
                  CastDetailQuickInfo(
                    widget: widget,
                    imageQuality: imageQuality,
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              [
                CastDetailAbout(
                    cast: widget.cast,
                    selectedIndex: selectedIndex,
                    tabController: tabController)
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
