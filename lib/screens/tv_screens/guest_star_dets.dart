import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:login/api/endpoints.dart';
import 'package:login/models/credits.dart';
import 'package:login/provider/imagequality_provider.dart';
import 'package:login/provider/settings_provider.dart';
import 'package:login/screens/movie_screens/widgets/person_widget.dart';
import 'package:login/screens/tv_screens/widgets/person_widget.dart';
import 'package:login/utils/config.dart';
import 'package:provider/provider.dart';

class GuestStarDetailPage extends StatefulWidget {
  final TVEpisodeGuestStars? cast;
  final String heroId;

  const GuestStarDetailPage({
    Key? key,
    this.cast,
    required this.heroId,
  }) : super(key: key);
  @override
  GuestStarDetailPageState createState() => GuestStarDetailPageState();
}

class GuestStarDetailPageState extends State<GuestStarDetailPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<GuestStarDetailPage> {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    //   mixpanelUpload(context);
  }

  // void mixpanelUpload(BuildContext context) {
  //   final mixpanel =
  //       Provider.of<MixpanelProvider>(context, listen: false).mixpanel;
  //   mixpanel.track('Most viewed person pages', properties: {
  //     'Person name': '${widget.cast!.name}',
  //     'Person id': '${widget.cast!.id}'
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          gradient: LinearGradient(
                              begin: FractionalOffset.topCenter,
                              end: FractionalOffset.bottomCenter,
                              colors: [
                                Color(0xFFFFFFFF),
                                Color(0xFFFFFFFF),
                                Color(0xFFFFFFFF),
                                Color(0xFFFFFFFF),
                              ],
                              stops: [
                                0.0,
                                0.25,
                                0.5,
                                0.75
                              ])),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          gradient: LinearGradient(
                              begin: FractionalOffset.bottomCenter,
                              end: FractionalOffset.topCenter,
                              colors: [
                                const Color(0xFFF57C00),
                                const Color(0xFFF57C00).withOpacity(0.3),
                                const Color(0xFFF57C00).withOpacity(0.2),
                                const Color(0xFFF57C00).withOpacity(0.1),
                              ],
                              stops: const [
                                0.0,
                                0.25,
                                0.5,
                                0.75
                              ])),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFFF57C00),
                ),
              )
            ],
          ),
          Column(
            children: <Widget>[
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFFF57C00),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.transparent,
                  child: Stack(
                    children: <Widget>[
                      SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 75, 16, 16),
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            color: const Color(0xFFDFDEDE),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 55,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        '${widget.cast!.name}',
                                        style: const TextStyle(fontSize: 25),
                                        // style: widget
                                        //     .themeData.textTheme.headline5,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                TabBar(
                                  isScrollable: true,
                                  indicatorColor: const Color(0xFFF57C00),
                                  indicatorWeight: 3,
                                  unselectedLabelColor: Colors.white54,
                                  labelColor: Colors.white,
                                  tabs: [
                                    Tab(
                                      child: Text('About',
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.black)),
                                    ),
                                    Tab(
                                      child: Text('Movies',
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.black)),
                                    ),
                                    Tab(
                                      child: Text('TV Shows',
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.black)),
                                    ),
                                  ],
                                  controller: tabController,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        1.6, 0, 1.6, 3),
                                    child: TabBarView(
                                      physics: const PageScrollPhysics(),
                                      controller: tabController,
                                      children: [
                                        SingleChildScrollView(
                                          child: Container(
                                            color: const Color(0xFFFFFFFF),
                                            child: Column(
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10.0,
                                                          right: 10,
                                                          top: 10.0),
                                                  child: Column(
                                                    children: [
                                                      PersonAboutWidget(
                                                          api: Endpoints
                                                              .getPersonDetails(
                                                                  widget.cast!
                                                                      .id!)),
                                                      PersonSocialLinks(
                                                        api: Endpoints
                                                            .getExternalLinksForPerson(
                                                                widget
                                                                    .cast!.id!),
                                                      ),
                                                      PersonImagesDisplay(
                                                        personName:
                                                            widget.cast!.name!,
                                                        api: Endpoints
                                                            .getPersonImages(
                                                          widget.cast!.id!,
                                                        ),
                                                        title: 'Images',
                                                      ),
                                                      PersonDataTable(
                                                          api: Endpoints
                                                              .getPersonDetails(
                                                                  widget.cast!
                                                                      .id!)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          color: const Color(0xFFFFFFFF),
                                          child: PersonMovieListWidget(
                                            api: Endpoints
                                                .getMovieCreditsForPerson(
                                                    widget.cast!.id!),
                                          ),
                                        ),
                                        Container(
                                          color: const Color(0xFFFFFFFF),
                                          child: PersonTVListWidget(
                                              api: Endpoints
                                                  .getTVCreditsForPerson(
                                                      widget.cast!.id!)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Hero(
                              tag: widget.heroId,
                              child: SizedBox(
                                width: 125,
                                height: 125,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: widget.cast!.profilePath == null
                                      ? Image.asset(
                                          'assets/images/na_square.png',
                                          fit: BoxFit.cover,
                                        )
                                      : CachedNetworkImage(
                                          fadeOutDuration:
                                              const Duration(milliseconds: 300),
                                          fadeOutCurve: Curves.easeOut,
                                          fadeInDuration:
                                              const Duration(milliseconds: 700),
                                          fadeInCurve: Curves.easeIn,
                                          imageUrl:
                                              '$TMDB_BASE_IMAGE_URL$imageQuality${widget.cast!.profilePath}',
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          placeholder: (context, url) =>
                                              Image.asset(
                                            'assets/images/loading.gif',
                                            fit: BoxFit.cover,
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                            'assets/images/na_square.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
