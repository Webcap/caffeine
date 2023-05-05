import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/movies_api.dart';
import 'package:caffiene/api/tv_api.dart';
import 'package:caffiene/models/images.dart';
import 'package:caffiene/models/movie_models.dart';
import 'package:caffiene/models/person.dart';
import 'package:intl/intl.dart';
import 'package:caffiene/models/tv.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/movie_screens/movie_details.dart';
import 'package:caffiene/screens/tv_screens/tv_detail_page.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/widgets/hero_photoview.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

class PersonImagesDisplay extends StatefulWidget {
  const PersonImagesDisplay({
    Key? key,
    required this.api,
    required this.title,
    required this.personName,
  }) : super(key: key);

  final String api;
  final String title;
  final String personName;

  @override
  State<PersonImagesDisplay> createState() => _PersonImagesDisplayState();
}

class _PersonImagesDisplayState extends State<PersonImagesDisplay>
    with AutomaticKeepAliveClientMixin {
  PersonImages? personImages;
  @override
  void initState() {
    super.initState();
    moviesApi().fetchPersonImages(widget.api).then((value) {
      setState(() {
        personImages = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  widget.title,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 150,
            child: personImages == null
                ? personImageShimmer()
                : personImages!.profile!.isEmpty
                    ? const Center(
                        child: Text('No images available for this person'),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: personImages!.profile!.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 0.0, 15.0, 8.0),
                                  child: SizedBox(
                                    width: 100,
                                    child: Column(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 6,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: CachedNetworkImage(
                                              fadeOutDuration: const Duration(
                                                  milliseconds: 300),
                                              fadeOutCurve: Curves.easeOut,
                                              fadeInDuration: const Duration(
                                                  milliseconds: 700),
                                              fadeInCurve: Curves.easeIn,
                                              imageUrl: TMDB_BASE_IMAGE_URL +
                                                  imageQuality +
                                                  personImages!.profile![index]
                                                      .filePath!,
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      GestureDetector(
                                                onTap: () {
                                                  // Navigator.push(context,
                                                  //     MaterialPageRoute(
                                                  //         builder: ((context) {
                                                  //   return HeroPhotoView(
                                                  //     imageProvider:
                                                  //         imageProvider,
                                                  //     currentIndex: index,
                                                  //     heroId:
                                                  //         TMDB_BASE_IMAGE_URL +
                                                  //             imageQuality +
                                                  //             personImages!
                                                  //                 .profile![
                                                  //                     index]
                                                  //                 .filePath!,
                                                  //     name: widget.personName,
                                                  //   );
                                                  // })));
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  scrollingImageShimmer(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Image.asset(
                                                'assets/images/na_square.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class PersonMovieListWidget extends StatefulWidget {
  final String api;
  final bool? isPersonAdult;
  final bool? includeAdult;
  const PersonMovieListWidget(
      {Key? key,
      required this.api,
      this.isPersonAdult,
      required this.includeAdult})
      : super(key: key);

  @override
  PersonMovieListWidgetState createState() => PersonMovieListWidgetState();
}

class PersonMovieListWidgetState extends State<PersonMovieListWidget>
    with AutomaticKeepAliveClientMixin<PersonMovieListWidget> {
  List<Movie>? personMoviesList;
  @override
  void initState() {
    super.initState();
    moviesApi().fetchPersonMovies(widget.api).then((value) {
      if (mounted) {
        setState(() {
          personMoviesList = value;
        });
      }
    });
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return personMoviesList == null
        ? personMoviesAndTVShowShimmer1(isDark)
        : widget.isPersonAdult == true && widget.includeAdult == false
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'This section contains NSFW & 18+ content',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          '${personMoviesList!.length} movies',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  personMoviesList!.isEmpty
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.only(
                              left: 5.0, right: 5.0, bottom: 8.0, top: 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 150,
                                      childAspectRatio: 0.48,
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 5,
                                    ),
                                    itemCount: personMoviesList!.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return MovieDetailPage(
                                                movie: personMoviesList![index],
                                                heroId:
                                                    '${personMoviesList![index].id}');
                                          }));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                flex: 6,
                                                child: Hero(
                                                  tag:
                                                      '${personMoviesList![index].id}',
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: personMoviesList![
                                                                        index]
                                                                    .posterPath ==
                                                                null
                                                            ? Image.asset(
                                                                'assets/images/na_rect.png',
                                                                fit: BoxFit
                                                                    .cover,
                                                              )
                                                            : CachedNetworkImage(
                                                                fadeOutDuration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            300),
                                                                fadeOutCurve:
                                                                    Curves
                                                                        .easeOut,
                                                                fadeInDuration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            700),
                                                                fadeInCurve:
                                                                    Curves
                                                                        .easeIn,
                                                                imageUrl: TMDB_BASE_IMAGE_URL +
                                                                    imageQuality +
                                                                    personMoviesList![
                                                                            index]
                                                                        .posterPath!,
                                                                imageBuilder:
                                                                    (context,
                                                                            imageProvider) =>
                                                                        Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    image:
                                                                        DecorationImage(
                                                                      image:
                                                                          imageProvider,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                                placeholder: (context,
                                                                        url) =>
                                                                    scrollingImageShimmer1(
                                                                        isDark),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Image.asset(
                                                                  'assets/images/na_rect.png',
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        left: 0,
                                                        child: Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .all(3),
                                                          alignment:
                                                              Alignment.topLeft,
                                                          width: 50,
                                                          height: 25,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              color: isDark
                                                                  ? Colors
                                                                      .black45
                                                                  : Colors
                                                                      .white38),
                                                          child: Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.star,
                                                              ),
                                                              Text(personMoviesList![
                                                                      index]
                                                                  .voteAverage!
                                                                  .toStringAsFixed(
                                                                      1))
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    personMoviesList![index]
                                                        .title!,
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          ),
                        ),
                ],
              );
  }
}

class PersonTVListWidget extends StatefulWidget {
  final String api;
  final bool? isPersonAdult;
  final bool? includeAdult;
  const PersonTVListWidget(
      {Key? key,
      required this.api,
      this.isPersonAdult,
      required this.includeAdult})
      : super(key: key);

  @override
  PersonTVListWidgetState createState() => PersonTVListWidgetState();
}

class PersonTVListWidgetState extends State<PersonTVListWidget>
    with AutomaticKeepAliveClientMixin<PersonTVListWidget> {
  List<TV>? personTVList;
  @override
  void initState() {
    super.initState();
    tvApi().fetchPersonTV(widget.api).then((value) {
      if (mounted) {
        setState(() {
          personTVList = value;
        });
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return personTVList == null
        ? personMoviesAndTVShowShimmer1(isDark)
        : widget.isPersonAdult == true && widget.includeAdult == false
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'This section contains NSFW & 18+ content',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          '${personTVList!.length} TV shows',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  personTVList!.isEmpty
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 10.0, bottom: 10.0, top: 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 150,
                                      childAspectRatio: 0.48,
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 5,
                                    ),
                                    itemCount: personTVList!.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return TVDetailPage(
                                                tvSeries: personTVList![index],
                                                heroId:
                                                    '${personTVList![index].id}');
                                          }));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                flex: 6,
                                                child: Hero(
                                                  tag:
                                                      '${personTVList![index].id}',
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: personTVList![
                                                                        index]
                                                                    .posterPath ==
                                                                null
                                                            ? Image.asset(
                                                                'assets/images/na_rect.png',
                                                                fit: BoxFit
                                                                    .cover,
                                                              )
                                                            : CachedNetworkImage(
                                                                fadeOutDuration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            300),
                                                                fadeOutCurve:
                                                                    Curves
                                                                        .easeOut,
                                                                fadeInDuration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            700),
                                                                fadeInCurve:
                                                                    Curves
                                                                        .easeIn,
                                                                imageUrl: TMDB_BASE_IMAGE_URL +
                                                                    imageQuality +
                                                                    personTVList![
                                                                            index]
                                                                        .posterPath!,
                                                                imageBuilder:
                                                                    (context,
                                                                            imageProvider) =>
                                                                        Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    image:
                                                                        DecorationImage(
                                                                      image:
                                                                          imageProvider,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                                placeholder: (context,
                                                                        url) =>
                                                                    scrollingImageShimmer1(
                                                                        isDark),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Image.asset(
                                                                  'assets/images/na_rect.png',
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        left: 0,
                                                        child: Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .all(3),
                                                          alignment:
                                                              Alignment.topLeft,
                                                          width: 50,
                                                          height: 25,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              color: isDark
                                                                  ? Colors
                                                                      .black45
                                                                  : Colors
                                                                      .white60),
                                                          child: Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.star,
                                                              ),
                                                              Text(personTVList![
                                                                      index]
                                                                  .voteAverage!
                                                                  .toStringAsFixed(
                                                                      1))
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    personTVList![index]
                                                        .originalName!,
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          ),
                        ),
                ],
              );
  }
}

class PersonAboutWidget extends StatefulWidget {
  final String api;
  const PersonAboutWidget({
    Key? key,
    required this.api,
  }) : super(key: key);

  @override
  State<PersonAboutWidget> createState() => _PersonAboutWidgetState();
}

class _PersonAboutWidgetState extends State<PersonAboutWidget>
    with AutomaticKeepAliveClientMixin {
  PersonDetails? personDetails;

  @override
  void initState() {
    super.initState();
    moviesApi().fetchPersonDetails(widget.api).then((value) {
      setState(() {
        personDetails = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    //final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return personDetails == null
        ? personAboutSimmer()
        : Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0, bottom: 8),
                    child: Text(
                      'Biography',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  ReadMoreText(
                    personDetails?.biography != ""
                        ? personDetails!.biography!
                        : 'We don\'t have a biography for this person',
                    trimLines: 4,
                    style: kTextSmallAboutBodyStyle,
                    colorClickableText: const Color(0xFFF57C00),
                    trimMode: TrimMode.Line,
                    trimCollapsedText: 'read more',
                    trimExpandedText: 'read less',
                    lessStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFF57C00),
                        fontWeight: FontWeight.bold),
                    moreStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFF57C00),
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          );
  }

  @override
  bool get wantKeepAlive => true;
}

// class PersonSocialLinks extends StatefulWidget {
//   final String? api;
//   const PersonSocialLinks({
//     Key? key,
//     this.api,
//   }) : super(key: key);

//   @override
//   PersonSocialLinksState createState() => PersonSocialLinksState();
// }

// class PersonSocialLinksState extends State<PersonSocialLinks> {
//   ExternalLinks? externalLinks;
//   bool? isAllNull;
//   @override
//   void initState() {
//     super.initState();
//     fetchSocialLinks(widget.api!).then((value) {
//       setState(() {
//         externalLinks = value;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     //final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
//     return Padding(
//       padding: const EdgeInsets.only(top: 10.0),
//       child: Container(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Social media links',
//               style: TextStyle(fontSize: 20),
//             ),
//             SizedBox(
//               height: 55,
//               width: double.infinity,
//               child: externalLinks == null
//                   ? socialMediaShimmer(isDark)
//                   : externalLinks?.facebookUsername == null &&
//                           externalLinks?.instagramUsername == null &&
//                           externalLinks?.twitterUsername == null &&
//                           externalLinks?.imdbId == null
//                       ? const Center(
//                           child: Text(
//                             'This person doesn\'t have social media links provided :(',
//                             textAlign: TextAlign.center,
//                             style: kTextSmallBodyStyle,
//                           ),
//                         )
//                       : Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8),
//                             color: isDark
//                                 ? Colors.transparent
//                                 : const Color(0xFFDFDEDE),
//                           ),
//                           child: ListView(
//                             scrollDirection: Axis.horizontal,
//                             children: [
//                               SocialIconWidget(
//                                 isNull: externalLinks?.facebookUsername == null,
//                                 url: externalLinks?.facebookUsername == null
//                                     ? ''
//                                     : FACEBOOK_BASE_URL +
//                                         externalLinks!.facebookUsername!,
//                                 icon: const Icon(
//                                   SocialIcons.facebook_f,
//                                   color: Color(0xFFF57C00),
//                                 ),
//                               ),
//                               SocialIconWidget(
//                                 isNull:
//                                     externalLinks?.instagramUsername == null,
//                                 url: externalLinks?.instagramUsername == null
//                                     ? ''
//                                     : INSTAGRAM_BASE_URL +
//                                         externalLinks!.instagramUsername!,
//                                 icon: const Icon(
//                                   SocialIcons.instagram,
//                                   color: Color(0xFFF57C00),
//                                 ),
//                               ),
//                               SocialIconWidget(
//                                 isNull: externalLinks?.twitterUsername == null,
//                                 url: externalLinks?.twitterUsername == null
//                                     ? ''
//                                     : TWITTER_BASE_URL +
//                                         externalLinks!.twitterUsername!,
//                                 icon: const Icon(
//                                   SocialIcons.twitter,
//                                   color: Color(0xFFF57C00),
//                                 ),
//                               ),
//                               SocialIconWidget(
//                                 isNull: externalLinks?.imdbId == null,
//                                 url: externalLinks?.imdbId == null
//                                     ? ''
//                                     : IMDB_BASE_URL + externalLinks!.imdbId!,
//                                 icon: const Center(
//                                   child: FaIcon(
//                                     FontAwesomeIcons.imdb,
//                                     size: 30,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class PersonDataTable extends StatefulWidget {
  const PersonDataTable({required this.api, Key? key}) : super(key: key);
  final String api;

  @override
  State<PersonDataTable> createState() => _PersonDataTableState();
}

class _PersonDataTableState extends State<PersonDataTable> {
  PersonDetails? personDetails;
  @override
  void initState() {
    moviesApi().fetchPersonDetails(widget.api).then((value) {
      setState(() {
        personDetails = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: personDetails == null
              ? personDetailInfoTableShimmer()
              : DataTable(dataRowHeight: 40, columns: [
                  const DataColumn(
                      label: Text(
                    'Age',
                    style: kTableLeftStyle,
                  )),
                  DataColumn(
                    label: Text(personDetails?.birthday != null
                        ? '${DateTime.parse(DateTime.now().toString()).year.toInt() - DateTime.parse(personDetails!.birthday!.toString()).year - 1}'
                        : '-'),
                  ),
                ], rows: [
                  DataRow(cells: [
                    const DataCell(Text(
                      'Born on',
                      style: kTableLeftStyle,
                    )),
                    DataCell(
                      Text(personDetails?.birthday != null
                          ? '${DateTime.parse(personDetails!.birthday!).day} ${DateFormat.MMMM().format(DateTime.parse(personDetails!.birthday!))}, ${DateTime.parse(personDetails!.birthday!.toString()).year}'
                          : '-'),
                    ),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text(
                      'From',
                      style: kTableLeftStyle,
                    )),
                    DataCell(
                      Text(
                        personDetails?.birthPlace != null
                            ? personDetails!.birthPlace!
                            : '-',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ]),
                ]),
        ),
      ),
    );
  }
}
