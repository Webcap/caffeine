import 'package:flutter/material.dart';
import 'package:login/api/endpoints.dart';
import 'package:login/models/person.dart';
import 'package:login/provider/settings_provider.dart';
import 'package:login/screens/person/widgets/person_widget.dart';
import 'package:login/screens/tv_screens/widgets/person_widget.dart';
import 'package:provider/provider.dart';

class SearchedPersonAbout extends StatefulWidget {
  SearchedPersonAbout(
      {Key? key,
      required this.person,
      required this.selectedIndex,
      required this.tabController})
      : super(key: key);
  int selectedIndex;
  final TabController tabController;
  final Person? person;

  @override
  State<SearchedPersonAbout> createState() => _SearchedPersonAboutState();
}

class _SearchedPersonAboutState extends State<SearchedPersonAbout> {
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
                                                widget.person!.id!)),
                                        PersonSocialLinks(
                                          api: Endpoints
                                              .getExternalLinksForPerson(
                                                  widget.person!.id!),
                                        ),
                                        PersonImagesDisplay(
                                          personName: widget.person!.name!,
                                          api: Endpoints.getPersonImages(
                                            widget.person!.id!,
                                          ),
                                          title: 'Images',
                                        ),
                                        PersonDataTable(
                                          api: Endpoints.getPersonDetails(
                                              widget.person!.id!),
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
                              isPersonAdult: widget.person!.adult!,
                              includeAdult:
                                  Provider.of<SettingsProvider>(context)
                                      .isAdult,
                              api: Endpoints.getMovieCreditsForPerson(
                                  widget.person!.id!),
                            ),
                          ),
                          Container(
                            child: PersonTVListWidget(
                                isPersonAdult: widget.person!.adult!,
                                includeAdult:
                                    Provider.of<SettingsProvider>(context)
                                        .isAdult,
                                api: Endpoints.getTVCreditsForPerson(
                                    widget.person!.id!)),
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
