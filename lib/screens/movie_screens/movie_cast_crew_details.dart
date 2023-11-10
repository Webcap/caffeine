import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/models/credits.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/movie_screens/widgets/cast_tab_widget.dart';
import 'package:provider/provider.dart';

class MovieCastAndCrew extends StatefulWidget {
  const MovieCastAndCrew({Key? key, required this.credits}) : super(key: key);
  final Credits credits;

  @override
  State<MovieCastAndCrew> createState() => _MovieCastAndCrewState();
}

class _MovieCastAndCrewState extends State<MovieCastAndCrew>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
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
                  indicatorColor: themeMode == "dark" || themeMode == "amoled"
                      ? Colors.white
                      : Colors.black,
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
                    CastTab(credits: widget.credits),
                    CrewTab(
                      credits: widget.credits,
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
