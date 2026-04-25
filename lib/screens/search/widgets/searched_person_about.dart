import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/api/endpoints.dart';
import 'package:reelriot/models/person.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/person/widgets/person_widget.dart';
import 'package:reelriot/screens/tv_screens/widgets/person_widget.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class SearchedPersonAbout extends StatefulWidget {
  SearchedPersonAbout(
      {super.key,
      required this.person,
      required this.selectedIndex,
      required this.tabController});
  int selectedIndex;
  final TabController tabController;
  final Person? person;

  @override
  State<SearchedPersonAbout> createState() => _SearchedPersonAboutState();
}

class _SearchedPersonAboutState extends State<SearchedPersonAbout> {
  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
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
                      child: Text(tr("about"),
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color:
                                  themeMode == "dark" || themeMode == "amoled"
                                      ? Colors.white
                                      : Colors.black)),
                    ),
                    Tab(
                      child: Text(tr("movies"),
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color:
                                  themeMode == "dark" || themeMode == "amoled"
                                      ? Colors.white
                                      : Colors.black)),
                    ),
                    Tab(
                      child: Text(tr("tv_shows"),
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color:
                                  themeMode == "dark" || themeMode == "amoled"
                                      ? Colors.white
                                      : Colors.black)),
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
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10, top: 10.0),
                                  child: Column(
                                    children: [
                                      PersonAboutWidget(
                                          api: Endpoints.getPersonDetails(
                                              widget.person!.id!, lang)),
                                      PersonSocialLinks(
                                        api: Endpoints
                                            .getExternalLinksForPerson(
                                                widget.person!.id!, lang),
                                      ),
                                      PersonImagesDisplay(
                                        personName: widget.person!.name!,
                                        api: Endpoints.getPersonImages(
                                          widget.person!.id!,
                                        ),
                                        title: tr("images"),
                                      ),
                                      PersonDataTable(
                                        api: Endpoints.getPersonDetails(
                                            widget.person!.id!, lang),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PersonMovieListWidget(
                            isPersonAdult: widget.person!.adult!,
                            includeAdult:
                                Provider.of<SettingsProvider>(context)
                                    .isAdult,
                            api: Endpoints.getMovieCreditsForPerson(
                                widget.person!.id!, lang),
                          ),
                          PersonTVListWidget(
                              isPersonAdult: widget.person!.adult!,
                              includeAdult:
                                  Provider.of<SettingsProvider>(context)
                                      .isAdult,
                              api: Endpoints.getTVCreditsForPerson(
                                  widget.person!.id!, lang)),
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
