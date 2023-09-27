import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/models/credits.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/tv_screens/widgets/tv_widgets.dart';
import 'package:provider/provider.dart';

class TVSeasonCastAndCrew extends StatefulWidget {
  const TVSeasonCastAndCrew(
      {Key? key,
      required this.id,
      required this.seasonNumber,
      required this.passedFrom})
      : super(key: key);

  final int id;
  final int seasonNumber;
  final String passedFrom;

  @override
  State<TVSeasonCastAndCrew> createState() => _TVSeasonCastAndCrewState();
}

class _TVSeasonCastAndCrewState extends State<TVSeasonCastAndCrew>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  Credits? credits;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            elevation: 3,
            title: Text(
              tr("cast_and_crew"),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Column(
            children: [
              Container(
                color: Colors.grey,
                child: TabBar(
                  tabs: [
                    Tab(
                        child: Text(
                      tr("cast"),
                    )),
                    Tab(
                        child: Text(
                      tr("crew"),
                    ))
                  ],
                  indicatorColor: isDark ? Colors.white : Colors.black,
                  indicatorWeight: 3,
                  //isScrollable: true,
                  labelStyle: const TextStyle(
                    fontFamily: 'PoppinsSB',
                    color: Colors.black,
                    fontSize: 17,
                  ),
                  unselectedLabelStyle: const TextStyle(
                      fontFamily: 'Poppins', color: Colors.black87),
                  labelColor: Colors.black,
                  controller: tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    TVCastTab(
                      api: Endpoints.getFullTVSeasonCreditsUrl(
                          widget.id, widget.seasonNumber, lang),
                    ),
                    TVCrewTab(
                      api: Endpoints.getFullTVSeasonCreditsUrl(
                          widget.id, widget.seasonNumber, lang),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
