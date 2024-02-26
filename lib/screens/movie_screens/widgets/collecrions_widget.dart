import 'package:cached_network_image/cached_network_image.dart';
import 'package:caffiene/functions/functions.dart';
import 'package:caffiene/functions/network.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/screens/movie_screens/widgets/collection_details.dart';
import 'package:caffiene/utils/constant.dart';
import 'package:caffiene/widgets/common_widgets.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/models/movie_models.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/movie_screens/movie_details.dart';
import 'package:caffiene/utils/config.dart';
import 'package:provider/provider.dart';

class BelongsToCollectionWidget extends StatefulWidget {
  final String? api;
  const BelongsToCollectionWidget({
    Key? key,
    this.api,
  }) : super(key: key);

  @override
  BelongsToCollectionWidgetState createState() =>
      BelongsToCollectionWidgetState();
}

class BelongsToCollectionWidgetState extends State<BelongsToCollectionWidget> {
  BelongsToCollection? belongsToCollection;
  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchBelongsToCollection(widget.api!, isProxyEnabled, proxyUrl)
        .then((value) {
      if (mounted) {
        setState(() {
          belongsToCollection = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return belongsToCollection == null
        ? ShimmerBase(
            themeMode: themeMode,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          )
        : belongsToCollection?.id == null
            ? Container()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                    width: double.infinity,
                    height: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: belongsToCollection!.backdropPath == null
                                  ? Image.asset(
                                      'assets/images/na_logo.png',
                                    )
                                  : FadeInImage(
                                      fit: BoxFit.fill,
                                      placeholder: const AssetImage(
                                          'assets/images/loading_5.gif'),
                                      image: NetworkImage(
                                          '${buildImageUrl(TMDB_BASE_IMAGE_URL, proxyUrl, isProxyEnabled, context)}w500/${belongsToCollection!.backdropPath!}')),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      tr("belongs_to_the", namedArgs: {
                                        "collection": belongsToCollection!.name!
                                      }),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: TextButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                            Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.3),
                                          ),
                                          maximumSize:
                                              MaterialStateProperty.all(
                                                  const Size(200, 40)),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  side: BorderSide(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  )))),
                                      onPressed: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return CollectionDetailsWidget(
                                              belongsToCollection:
                                                  belongsToCollection!);
                                        }));
                                      },
                                      child: Text(
                                        tr("view_collection"),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ],
                    )),
              );
  }
}

class CollectionOverviewWidget extends StatefulWidget {
  final String? api;
  const CollectionOverviewWidget({Key? key, this.api}) : super(key: key);

  @override
  CollectionOverviewWidgetState createState() =>
      CollectionOverviewWidgetState();
}

class CollectionOverviewWidgetState extends State<CollectionOverviewWidget> {
  CollectionDetails? collectionDetails;

  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchCollectionDetails(widget.api!, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          collectionDetails = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return Container(
      child: collectionDetails == null
          ? ShimmerBase(
              themeMode: themeMode,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                        color: Colors.grey.shade600,
                        width: double.infinity,
                        height: 20),
                  ),
                  Container(
                      color: Colors.grey.shade600,
                      width: double.infinity,
                      height: 20)
                ],
              ),
            )
          : Text(collectionDetails!.overview!),
    );
  }
}

class PartsList extends StatefulWidget {
  final String? api;
  final String? title;
  const PartsList({Key? key, this.api, this.title}) : super(key: key);

  @override
  PartsListState createState() => PartsListState();
}

class PartsListState extends State<PartsList> {
  List<Movie>? collectionMovieList;
  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchCollectionMovies(widget.api!, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          collectionMovieList = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const LeadingDot(),
                    Expanded(
                      child: Text(
                        widget.title!,
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
          height: 250,
          child: collectionMovieList == null
              ? Row(
                  children: [
                    Expanded(
                      child: ShimmerBase(
                        themeMode: themeMode,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: 3,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 105,
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 6,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade600,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 5, 0, 30),
                                        child: Container(
                                          width: 110.0,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              color: Colors.grey.shade600),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: collectionMovieList!.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MovieDetailPage(
                                            movie: collectionMovieList![index],
                                            heroId:
                                                '${collectionMovieList![index].id}')));
                              },
                              child: SizedBox(
                                width: 105,
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 6,
                                      child: Hero(
                                        tag:
                                            '${collectionMovieList![index].id}',
                                        child: Material(
                                          type: MaterialType.transparency,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: collectionMovieList![
                                                                index]
                                                            .posterPath ==
                                                        null
                                                    ? Image.asset(
                                                        'assets/images/na_logo.png',
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                        height: double.infinity)
                                                    : CachedNetworkImage(
                                                        cacheManager:
                                                            cacheProp(),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    300),
                                                        fadeOutCurve:
                                                            Curves.easeOut,
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    700),
                                                        fadeInCurve:
                                                            Curves.easeIn,
                                                        imageUrl: buildImageUrl(
                                                                TMDB_BASE_IMAGE_URL,
                                                                proxyUrl,
                                                                isProxyEnabled,
                                                                context) +
                                                            imageQuality +
                                                            collectionMovieList![
                                                                    index]
                                                                .posterPath!,
                                                        imageBuilder: (context,
                                                                imageProvider) =>
                                                            Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            image:
                                                                DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        placeholder: (context,
                                                                url) =>
                                                            scrollingImageShimmer(
                                                                themeMode),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Image.asset(
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
                                                      const EdgeInsets.all(3),
                                                  alignment: Alignment.topLeft,
                                                  width: 50,
                                                  height: 25,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color:
                                                          themeMode == "dark" ||
                                                                  themeMode ==
                                                                      "amoled"
                                                              ? Colors.black45
                                                              : Colors.white60),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.star_rounded,
                                                      ),
                                                      Text(collectionMovieList![
                                                              index]
                                                          .voteAverage!
                                                          .toStringAsFixed(1))
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          collectionMovieList![index].title!,
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
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
    );
  }
}

class CollectionMovies extends StatefulWidget {
  final String? api;
  const CollectionMovies({
    Key? key,
    this.api,
  }) : super(key: key);
  @override
  CollectionMoviesState createState() => CollectionMoviesState();
}

class CollectionMoviesState extends State<CollectionMovies> {
  List<Movie>? moviesList;
  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchCollectionMovies(widget.api!, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          moviesList = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return moviesList == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : moviesList!.isEmpty
            ? Center(
                child: Text(
                  tr("no_watchprovider_movie"),
                  style: const TextStyle(fontFamily: 'Poppins'),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: moviesList!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MovieDetailPage(
                                        movie: moviesList![index],
                                        heroId: '${moviesList![index].id}')));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 85,
                                      height: 130,
                                      child: Hero(
                                        tag: '${moviesList![index].id}',
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: moviesList![index]
                                                      .posterPath ==
                                                  null
                                              ? Image.asset(
                                                  'assets/images/na_logo.png',
                                                  fit: BoxFit.cover,
                                                )
                                              : CachedNetworkImage(
                                                  cacheManager: cacheProp(),
                                                  fadeOutDuration:
                                                      const Duration(
                                                          milliseconds: 300),
                                                  fadeOutCurve: Curves.easeOut,
                                                  fadeInDuration:
                                                      const Duration(
                                                          milliseconds: 700),
                                                  fadeInCurve: Curves.easeIn,
                                                  imageUrl: buildImageUrl(
                                                          TMDB_BASE_IMAGE_URL,
                                                          proxyUrl,
                                                          isProxyEnabled,
                                                          context) +
                                                      imageQuality +
                                                      moviesList![index]
                                                          .posterPath!,
                                                  imageBuilder: (context,
                                                          imageProvider) =>
                                                      Container(
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover,
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
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              moviesList![index].title!,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins'),
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Text(
                                                  moviesList![index]
                                                      .voteAverage!
                                                      .toStringAsFixed(1),
                                                  style: const TextStyle(
                                                      fontFamily: 'Poppins'),
                                                ),
                                                const Icon(
                                                  Icons.star_rounded,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 24.0),
                                  child: Divider(
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
  }
}
