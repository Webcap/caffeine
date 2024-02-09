import 'package:cached_network_image/cached_network_image.dart';
import 'package:caffiene/screens/movie_screens/widgets/collection_details.dart';
import 'package:caffiene/utils/constant.dart';
import 'package:caffiene/widgets/common_widgets.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/movies_api.dart';
import 'package:caffiene/models/movie_models.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/movie_screens/movie_details.dart';
import 'package:caffiene/utils/config.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

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
    moviesApi().fetchBelongsToCollection(widget.api!).then((value) {
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
                                          '${TMDB_BASE_IMAGE_URL}w500/${belongsToCollection!.backdropPath!}')),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Belongs to the ${belongsToCollection!.name!}',
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
                                      child: const Text(
                                        'View the collection',
                                        style: TextStyle(color: Colors.white),
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
  bool requestFailed = false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    moviesApi().fetchCollectionDetails(widget.api!).then((value) {
      setState(() {
        collectionDetails = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (collectionDetails == null) {
        setState(() {
          requestFailed = true;
          collectionDetails = CollectionDetails();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //final themeMode = Provider.of<DarkthemeProvider>(context).darktheme;
    return Container(
      child: collectionDetails == null
          ? Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              direction: ShimmerDirection.ltr,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: 20),
                  ),
                  Container(
                      color: Colors.white, width: double.infinity, height: 20)
                ],
              ),
            )
          : requestFailed == true
              ? retryWidget()
              : Text(collectionDetails!.overview!),
    );
  }

  Widget retryWidget() {
    return Center(
      child: Container(
          width: double.infinity,
          color: const Color(0xFFFFFFFF),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/network-signal.png',
                  width: 60, height: 60),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('Please connect to the Internet and try again',
                    textAlign: TextAlign.center),
              ),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0x0DF57C00)),
                      maximumSize:
                          MaterialStateProperty.all(const Size(200, 60)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side: const BorderSide(color: maincolor)))),
                  onPressed: () {
                    setState(() {
                      requestFailed = false;
                      collectionDetails = null;
                    });
                    getData();
                  },
                  child: const Text('Retry')),
            ],
          )),
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
    moviesApi().fetchCollectionMovies(widget.api!).then((value) {
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
                                                        imageUrl:
                                                            TMDB_BASE_IMAGE_URL +
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
