import 'package:cached_network_image/cached_network_image.dart';
import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/models/tv.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/person/widgets/person_widget.dart';
import 'package:caffiene/screens/tv_screens/widgets/created_by_widget.dart';
import 'package:caffiene/screens/tv_screens/widgets/person_widget.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caffiene/utils/constant.dart';


class CreatedByQuickInfo extends StatelessWidget {
  const CreatedByQuickInfo({
    Key? key,
    required this.widget,
    required this.imageQuality,
  }) : super(key: key);

  final CreatedByPersonDetailPage widget;
  final String imageQuality;

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          Positioned(
            bottom: 0.0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  // poster
                  Hero(
                    tag: widget.heroId,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(150),
                            child: SizedBox(
                              width: 120,
                              height: 120,
                              child: widget.createdBy!.profilePath == null
                                  ? Image.asset(
                                      'assets/images/na_logo.png',
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      cacheManager: cacheProp(),
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          scrollingImageShimmer(themeMode),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        'assets/images/na_logo.png',
                                        fit: BoxFit.cover,
                                      ),
                                      imageUrl: TMDB_BASE_IMAGE_URL +
                                          imageQuality +
                                          widget.createdBy!.profilePath!,
                                    ),
                            ),
                          ),
                        )),
                  ),
                  const SizedBox(width: 16),
                  //  titles
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.createdBy!.name!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 25, fontFamily: 'PoppinsSB'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class CreatedByAbout extends StatefulWidget {
  CreatedByAbout(
      {Key? key,
      required this.createdBy,
      required this.selectedIndex,
      required this.tabController})
      : super(key: key);
  int selectedIndex;
  final CreatedBy? createdBy;
  final TabController tabController;

  @override
  State<CreatedByAbout> createState() => _CreatedByAboutState();
}

class _CreatedByAboutState extends State<CreatedByAbout> {
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
                                                widget.createdBy!.id!, lang)),
                                        PersonSocialLinks(
                                          api: Endpoints
                                              .getExternalLinksForPerson(
                                                  widget.createdBy!.id!, lang),
                                        ),
                                        PersonImagesDisplay(
                                          personName: widget.createdBy!.name!,
                                          api: Endpoints.getPersonImages(
                                            widget.createdBy!.id!,
                                          ),
                                          title: tr("images"),
                                        ),
                                        PersonDataTable(
                                          api: Endpoints.getPersonDetails(
                                              widget.createdBy!.id!, lang),
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
                              includeAdult:
                                  Provider.of<SettingsProvider>(context)
                                      .isAdult,
                              api: Endpoints.getMovieCreditsForPerson(
                                  widget.createdBy!.id!, lang),
                            ),
                          ),
                          Container(
                            child: PersonTVListWidget(
                                includeAdult:
                                    Provider.of<SettingsProvider>(context)
                                        .isAdult,
                                api: Endpoints.getTVCreditsForPerson(
                                    widget.createdBy!.id!, lang)),
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
