import 'package:flutter/material.dart';
import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/person/widgets/person_widget.dart';
import 'package:caffiene/screens/tv_screens/widgets/person_widget.dart';
import 'package:provider/provider.dart';
import '/models/credits.dart' as cre;

class CastDetailAbout extends StatefulWidget {
  CastDetailAbout(
      {Key? key,
      required this.cast,
      required this.selectedIndex,
      required this.tabController})
      : super(key: key);
  int selectedIndex;
  final cre.Cast? cast;
  final TabController tabController;

  @override
  State<CastDetailAbout> createState() => _CastDetailAboutState();
}

class _CastDetailAboutState extends State<CastDetailAbout> {
  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0))),
        child: Column(
          children: [
            Column(
              children: [
                TabBar(
                  onTap: ((value) {
                    setState(() {
                      widget.selectedIndex = value;
                    });
                  }),
                  isScrollable: true,
                  indicatorWeight: 3,
                  unselectedLabelColor: Colors.white54,
                  labelColor: Colors.white,
                  tabs: [
                    Tab(
                      child: Text('About',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: isDark ? Colors.white : Colors.black)),
                    ),
                    Tab(
                      child: Text('Movies',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: isDark ? Colors.white : Colors.black)),
                    ),
                    Tab(
                      child: Text('TV Shows',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: isDark ? Colors.white : Colors.black)),
                    ),
                  ],
                  controller: widget.tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(1.6, 0, 1.6, 3),
                      child: IndexedStack(
                        index: widget.selectedIndex,
                        children: [
                          SingleChildScrollView(
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10, top: 10.0),
                                    child: Column(
                                      children: [
                                        PersonAboutWidget(
                                            api: Endpoints.getPersonDetails(
                                                widget.cast!.id!)),
                                        PersonSocialLinks(
                                          api: Endpoints
                                              .getExternalLinksForPerson(
                                                  widget.cast!.id!),
                                        ),
                                        PersonImagesDisplay(
                                          personName: widget.cast!.name!,
                                          api: Endpoints.getPersonImages(
                                            widget.cast!.id!,
                                          ),
                                          title: 'Images',
                                        ),
                                        PersonDataTable(
                                          api: Endpoints.getPersonDetails(
                                              widget.cast!.id!),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            child: PersonMovieListWidget(
                              isPersonAdult: widget.cast!.adult!,
                              includeAdult:
                                  Provider.of<SettingsProvider>(context)
                                      .isAdult,
                              api: Endpoints.getMovieCreditsForPerson(
                                  widget.cast!.id!),
                            ),
                          ),
                          Container(
                            child: PersonTVListWidget(
                                isPersonAdult: widget.cast!.adult!,
                                includeAdult:
                                    Provider.of<SettingsProvider>(context)
                                        .isAdult,
                                api: Endpoints.getTVCreditsForPerson(
                                    widget.cast!.id!)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
