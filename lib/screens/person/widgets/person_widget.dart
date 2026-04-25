import 'package:cached_network_image/cached_network_image.dart';
import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/functions/network.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/screens/common/hero_photoview.dart';
import 'package:reelriot/utils/theme/textStyle.dart';
import 'package:reelriot/widgets/common_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/models/images.dart';
import 'package:reelriot/models/movie_models.dart';
import 'package:reelriot/models/person.dart';
import 'package:reelriot/models/tv.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/movie_screens/movie_details.dart';
import 'package:reelriot/screens/tv_screens/tv_detail_page.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:reelriot/utils/constant.dart';

class PersonImagesDisplay extends StatefulWidget {
  const PersonImagesDisplay({
    super.key,
    required this.api,
    required this.title,
    required this.personName,
  });

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
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchPersonImages(widget.api, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          personImages = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const LeadingDot(),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: kTextHeaderStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 150,
            child: personImages == null
                ? personImageShimmer(themeMode)
                : personImages!.profile!.isEmpty
                    ? Center(
                        child: Text(tr("no_images_person")),
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
                                              cacheManager: cacheProp(),
                                              fadeOutDuration: const Duration(
                                                  milliseconds: 300),
                                              fadeOutCurve: Curves.easeOut,
                                              fadeInDuration: const Duration(
                                                  milliseconds: 700),
                                              fadeInCurve: Curves.easeIn,
                                              imageUrl: buildImageUrl(
                                                      tmdbBaseImageUrl,
                                                      proxyUrl,
                                                      isProxyEnabled,
                                                      context) +
                                                  imageQuality +
                                                  personImages!.profile![index]
                                                      .filePath!,
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      GestureDetector(
                                                onTap: () {
                                                  Navigator.push(context,
                                                      MaterialPageRoute(
                                                          builder: ((context) {
                                                    return HeroPhotoView(
                                                      imageProvider:
                                                          imageProvider,
                                                      currentIndex: index,
                                                      heroId: buildImageUrl(
                                                              tmdbBaseImageUrl,
                                                              proxyUrl,
                                                              isProxyEnabled,
                                                              context) +
                                                          imageQuality +
                                                          personImages!
                                                              .profile![index]
                                                              .filePath!,
                                                      name: widget.personName,
                                                    );
                                                  })));
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
                                                  scrollingImageShimmer(
                                                      themeMode),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Image.asset(
                                                'assets/images/na_logo.png',
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
      {super.key,
      required this.api,
      this.isPersonAdult,
      required this.includeAdult});

  @override
  PersonMovieListWidgetState createState() => PersonMovieListWidgetState();
}

class PersonMovieListWidgetState extends State<PersonMovieListWidget>
    with AutomaticKeepAliveClientMixin<PersonMovieListWidget> {
  List<Movie>? personMoviesList;
  List<Movie>? uniqueMov;
  List<Movie>? originalMov;
  Set<int> seenIds = {};
  String selectedFilter = 'default_filter';

  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchPersonMovies(widget.api, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          personMoviesList = value;
        });
      }
      if (personMoviesList != null) {
        uniqueMov = [];
        for (Movie mov in personMoviesList!) {
          if (!seenIds.contains(mov.id)) {
            uniqueMov!.add(mov);
            seenIds.add(mov.id!);
          }
        }
        originalMov = List.from(uniqueMov!);
        sortMovies();
      }
    });
  }

  void sortMovies() {
    if (uniqueMov == null) return;
    if (selectedFilter == 'newest') {
      uniqueMov!.sort((a, b) {
        if (a.releaseDate == null || a.releaseDate!.isEmpty) return 1;
        if (b.releaseDate == null || b.releaseDate!.isEmpty) return -1;
        return b.releaseDate!.compareTo(a.releaseDate!);
      });
    } else if (selectedFilter == 'popular') {
      uniqueMov!.sort((a, b) {
        if (a.popularity == null) return 1;
        if (b.popularity == null) return -1;
        return b.popularity!.compareTo(a.popularity!);
      });
    } else {
      uniqueMov = List.from(originalMov!);
    }
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return uniqueMov == null
        ? personMoviesAndTVShowShimmer(themeMode)
        : widget.isPersonAdult == true && widget.includeAdult == false
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    tr("contains_nsfw"),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tr("person_movie_count", namedArgs: {
                            "count": uniqueMov!.length.toString()
                          }),
                          style: const TextStyle(fontSize: 15),
                        ),
                        // We use a small Row or Wrap for the filters
                        Row(
                          children: [
                            _buildFilterChip(
                              context,
                              label: tr("default_filter"),
                              selected: selectedFilter == 'default_filter',
                              onSelected: () {
                                setState(() {
                                  selectedFilter = 'default_filter';
                                  sortMovies();
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              context,
                              label: tr("newest"),
                              selected: selectedFilter == 'newest',
                              onSelected: () {
                                setState(() {
                                  selectedFilter = 'newest';
                                  sortMovies();
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              context,
                              label: tr("popular"),
                              selected: selectedFilter == 'popular',
                              onSelected: () {
                                setState(() {
                                  selectedFilter = 'popular';
                                  sortMovies();
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  uniqueMov!.isEmpty
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
                                    itemCount: uniqueMov!.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return MovieDetailPage(
                                                movie: uniqueMov![index],
                                                heroId:
                                                    '${uniqueMov![index].id}');
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
                                                      '${uniqueMov![index].id}',
                                                  child: Material(
                                                    type: MaterialType
                                                        .transparency,
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          child: uniqueMov![index]
                                                                      .posterPath ==
                                                                  null
                                                              ? Image.asset(
                                                                  'assets/images/na_logo.png',
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  width: double
                                                                      .infinity,
                                                                  height: double
                                                                      .infinity)
                                                              : CachedNetworkImage(
                                                                  cacheManager:
                                                                      cacheProp(),
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
                                                                  imageUrl: buildImageUrl(
                                                                          tmdbBaseImageUrl,
                                                                          proxyUrl,
                                                                          isProxyEnabled,
                                                                          context) +
                                                                      imageQuality +
                                                                      uniqueMov![
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
                                                                      scrollingImageShimmer(
                                                                          themeMode),
                                                                  errorWidget: (context, url, error) => Image.asset(
                                                                      'assets/images/na_logo.png',
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      width: double
                                                                          .infinity,
                                                                      height: double
                                                                          .infinity),
                                                                ),
                                                        ),
                                                        Positioned(
                                                          top: 0,
                                                          left: 0,
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(3),
                                                            alignment: Alignment
                                                                .topLeft,
                                                            width: 50,
                                                            height: 25,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                color: themeMode ==
                                                                            "dark" ||
                                                                        themeMode ==
                                                                            "amoled"
                                                                    ? Colors
                                                                        .black45
                                                                    : Colors
                                                                        .white38),
                                                            child: Row(
                                                              children: [
                                                                const Icon(
                                                                  Icons
                                                                      .star_rounded,
                                                                ),
                                                                Text(uniqueMov![
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
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    uniqueMov![index].title!,
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

  Widget _buildFilterChip(BuildContext context,
      {required String label,
      required bool selected,
      required VoidCallback onSelected}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? primaryColor.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? primaryColor
                : (isDark ? Colors.white24 : Colors.black26),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? primaryColor
                : (isDark ? Colors.white70 : Colors.black54),
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class PersonTVListWidget extends StatefulWidget {
  final String api;
  final bool? isPersonAdult;
  final bool? includeAdult;
  const PersonTVListWidget(
      {super.key,
      required this.api,
      this.isPersonAdult,
      required this.includeAdult});

  @override
  PersonTVListWidgetState createState() => PersonTVListWidgetState();
}

class PersonTVListWidgetState extends State<PersonTVListWidget>
    with AutomaticKeepAliveClientMixin<PersonTVListWidget> {
  List<TV>? personTVList;
  List<TV>? uniqueTV;
  List<TV>? originalTV;
  Set<int> seenIds = {};
  String selectedFilter = 'default_filter';
  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchPersonTV(widget.api, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          personTVList = value;
        });
      }
      if (personTVList != null) {
        uniqueTV = [];
        for (TV tv in personTVList!) {
          if (!seenIds.contains(tv.id)) {
            uniqueTV!.add(tv);
            seenIds.add(tv.id!);
          }
        }
        originalTV = List.from(uniqueTV!);
        sortTV();
      }
    });
  }

  void sortTV() {
    if (uniqueTV == null) return;
    if (selectedFilter == 'newest') {
      uniqueTV!.sort((a, b) {
        if (a.firstAirDate == null || a.firstAirDate!.isEmpty) return 1;
        if (b.firstAirDate == null || b.firstAirDate!.isEmpty) return -1;
        return b.firstAirDate!.compareTo(a.firstAirDate!);
      });
    } else if (selectedFilter == 'popular') {
      uniqueTV!.sort((a, b) {
        if (a.popularity == null) return 1;
        if (b.popularity == null) return -1;
        return b.popularity!.compareTo(a.popularity!);
      });
    } else {
      uniqueTV = List.from(originalTV!);
    }
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return uniqueTV == null
        ? personMoviesAndTVShowShimmer(themeMode)
        : widget.isPersonAdult == true && widget.includeAdult == false
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    tr("contains_nsfw"),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tr("person_tv_count", namedArgs: {
                            "count": uniqueTV!.length.toString()
                          }),
                          style: const TextStyle(fontSize: 15),
                        ),
                        Row(
                          children: [
                            _buildFilterChip(
                              context,
                              label: tr("default_filter"),
                              selected: selectedFilter == 'default_filter',
                              onSelected: () {
                                setState(() {
                                  selectedFilter = 'default_filter';
                                  sortTV();
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              context,
                              label: tr("newest"),
                              selected: selectedFilter == 'newest',
                              onSelected: () {
                                setState(() {
                                  selectedFilter = 'newest';
                                  sortTV();
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              context,
                              label: tr("popular"),
                              selected: selectedFilter == 'popular',
                              onSelected: () {
                                setState(() {
                                  selectedFilter = 'popular';
                                  sortTV();
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  uniqueTV!.isEmpty
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
                                    itemCount: uniqueTV!.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return TVDetailPage(
                                                tvSeries: uniqueTV![index],
                                                heroId:
                                                    '${uniqueTV![index].id}');
                                          }));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                flex: 6,
                                                child: Hero(
                                                  tag: '${uniqueTV![index].id}',
                                                  child: Material(
                                                    type: MaterialType
                                                        .transparency,
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          child: uniqueTV![
                                                                          index]
                                                                      .posterPath ==
                                                                  null
                                                              ? Image.asset(
                                                                  'assets/images/na_logo.png',
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  width: double
                                                                      .infinity,
                                                                  height: double
                                                                      .infinity)
                                                              : CachedNetworkImage(
                                                                  cacheManager:
                                                                      cacheProp(),
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
                                                                  imageUrl: buildImageUrl(
                                                                          tmdbBaseImageUrl,
                                                                          proxyUrl,
                                                                          isProxyEnabled,
                                                                          context) +
                                                                      imageQuality +
                                                                      uniqueTV![
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
                                                                      scrollingImageShimmer(
                                                                          themeMode),
                                                                  errorWidget: (context, url, error) => Image.asset(
                                                                      'assets/images/na_logo.png',
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      width: double
                                                                          .infinity,
                                                                      height: double
                                                                          .infinity),
                                                                ),
                                                        ),
                                                        Positioned(
                                                          top: 0,
                                                          left: 0,
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(3),
                                                            alignment: Alignment
                                                                .topLeft,
                                                            width: 50,
                                                            height: 25,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                color: themeMode ==
                                                                            "dark" ||
                                                                        themeMode ==
                                                                            "amoled"
                                                                    ? Colors
                                                                        .black45
                                                                    : Colors
                                                                        .white60),
                                                            child: Row(
                                                              children: [
                                                                const Icon(
                                                                  Icons
                                                                      .star_rounded,
                                                                ),
                                                                Text(uniqueTV![
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
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    uniqueTV![index]
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

  Widget _buildFilterChip(BuildContext context,
      {required String label,
      required bool selected,
      required VoidCallback onSelected}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? primaryColor.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? primaryColor
                : (isDark ? Colors.white24 : Colors.black26),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? primaryColor
                : (isDark ? Colors.white70 : Colors.black54),
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class PersonAboutWidget extends StatefulWidget {
  final String api;
  const PersonAboutWidget({
    super.key,
    required this.api,
  });

  @override
  State<PersonAboutWidget> createState() => _PersonAboutWidgetState();
}

class _PersonAboutWidgetState extends State<PersonAboutWidget>
    with AutomaticKeepAliveClientMixin {
  PersonDetails? personDetails;

  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchPersonDetails(widget.api, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          personDetails = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return personDetails == null
        ? personAboutSimmer(themeMode)
        : Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                          child: Row(
                            children: [
                              const LeadingDot(),
                              Expanded(
                                child: Text(
                                  tr("biography"),
                                  style: kTextHeaderStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  ReadMoreText(
                    personDetails?.biography != ""
                        ? personDetails!.biography!
                        : tr("no_biography_person"),
                    trimLines: 4,
                    style: kTextSmallAboutBodyStyle,
                    colorClickableText: Theme.of(context).colorScheme.primary,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: tr("read_more"),
                    trimExpandedText: tr("read_less"),
                    lessStyle: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold),
                    moreStyle: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
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

class PersonDataTable extends StatefulWidget {
  const PersonDataTable({required this.api, super.key});
  final String api;

  @override
  State<PersonDataTable> createState() => _PersonDataTableState();
}

class _PersonDataTableState extends State<PersonDataTable> {
  PersonDetails? personDetails;
  @override
  void initState() {
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchPersonDetails(widget.api, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          personDetails = value;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: personDetails == null
              ? personDetailInfoTableShimmer(themeMode)
              : DataTable(dataRowMinHeight: 40, columns: [
                  DataColumn(
                      label: personDetails!.deathday != null &&
                              personDetails!.birthday != null
                          ? Text(
                              tr("died_aged"),
                              style: kTableLeftStyle,
                            )
                          : Text(
                              tr("age"),
                              style: kTableLeftStyle,
                            )),
                  DataColumn(
                    label: personDetails!.deathday != null &&
                            personDetails!.birthday != null
                        ? Text(
                            '${DateTime.parse(personDetails!.deathday.toString()).year.toInt() - DateTime.parse(personDetails!.birthday!.toString()).year - 1}')
                        : Text(personDetails?.birthday != null
                            ? '${DateTime.parse(DateTime.now().toString()).year.toInt() - DateTime.parse(personDetails!.birthday!.toString()).year - 1}'
                            : '-'),
                  ),
                ], rows: [
                  DataRow(cells: [
                    DataCell(Text(
                      tr("born_on"),
                      style: kTableLeftStyle,
                    )),
                    DataCell(
                      Text(personDetails?.birthday != null
                          ? '${DateTime.parse(personDetails!.birthday!).day} ${DateFormat.MMMM().format(DateTime.parse(personDetails!.birthday!))}, ${DateTime.parse(personDetails!.birthday!.toString()).year}'
                          : '-'),
                    ),
                  ]),
                  DataRow(cells: [
                    DataCell(Text(
                      tr("from"),
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
      );
  }
}
