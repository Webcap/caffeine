import 'package:caffiene/screens/common/sabth.dart';
import 'package:caffiene/screens/movie_screens/widgets/crew_about_details.dart';
import 'package:caffiene/screens/movie_screens/widgets/crew_detail_quick_info.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/models/credits.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:provider/provider.dart';

class CrewDetailPage extends StatefulWidget {
  final String heroId;
  final Crew? crew;

  const CrewDetailPage({
    Key? key,
    this.crew,
    required this.heroId,
  }) : super(key: key);
  @override
  CrewDetailPageState createState() => CrewDetailPageState();
}

class CrewDetailPageState extends State<CrewDetailPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<CrewDetailPage> {
  late TabController tabController;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 3, vsync: this);
    mixpanelUpload(context);
  }

  void mixpanelUpload(BuildContext context) {
    final mixpanel =
        Provider.of<SettingsProvider>(context, listen: false).mixpanel;
    mixpanel.track('Most viewed person pages', properties: {
      'Person name': '${widget.crew!.name}',
      'Person id': '${widget.crew!.id}'
    });
  }

  int selectedIndex = 0;
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;

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
              widget.crew!.name!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            )),
            expandedHeight: 210,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Column(
                children: [
                  CrewDetailQuickInfo(
                    widget: widget,
                    imageQuality: imageQuality,
                  )
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              [
                CrewDetailAbout(
                    crew: widget.crew,
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
