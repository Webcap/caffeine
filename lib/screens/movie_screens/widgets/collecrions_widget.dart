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

// ─── Design tokens (design.json) ─────────────────────────────────────────────
class _ColDesign {
  static const primary = Color(0xFFDC2626);
  static const bgSurfaceDark = Color(0xFF0B0F14);
  static const bgElevatedDark = Color(0x0DFFFFFF);
  static const textPrimDark = Color(0xFFFFFFFF);
  static const textSecDark = Color(0xB8FFFFFF);
  static const borderDark = Color(0x14FFFFFF);
  static const bgCanvasLight = Color(0xFFF8FAFC);
  static const textPrimLight = Color(0xFF0B0F14);
  static const textSecLight = Color(0xFF64748B);
  static const radiusMd = 16.0;
  static const radiusLg = 20.0;
  static const space2 = 8.0;
  static const space3 = 12.0;
  static const space4 = 16.0;
  static const space6 = 24.0;
  static const screenPadH = 16.0;
  static const shadowCard = BoxShadow(
    color: Color(0x38000000),
    blurRadius: 30,
    offset: Offset(0, 10),
  );
  static const heroOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00000000), Color(0x73000000), Color(0xEB000000)],
    stops: [0.0, 0.5, 1.0],
  );
}

class BelongsToCollectionWidget extends StatefulWidget {
  final String? api;
  const BelongsToCollectionWidget({
    super.key,
    this.api,
  });

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
    final themeMode = context.watch<SettingsProvider>().appTheme;
    final isProxyEnabled = context.read<SettingsProvider>().enableProxy;
    final proxyUrl = context.read<AppDependencyProvider>().tmdbProxy;
    final isDark = themeMode == 'dark' || themeMode == 'amoled';
    final textPrim =
        isDark ? _ColDesign.textPrimDark : _ColDesign.textPrimLight;

    return belongsToCollection == null
        ? ShimmerBase(
            themeMode: themeMode,
            child: Padding(
              padding: const EdgeInsets.all(_ColDesign.space4),
              child: Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: isDark
                      ? _ColDesign.bgElevatedDark
                      : _ColDesign.textSecLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(_ColDesign.radiusMd),
                ),
              ),
            ),
          )
        : belongsToCollection?.id == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: _ColDesign.screenPadH,
                    vertical: _ColDesign.space3),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_ColDesign.radiusLg),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: belongsToCollection!.backdropPath == null
                              ? Image.asset(
                                  'assets/images/na_logo.png',
                                  fit: BoxFit.cover,
                                )
                              : CachedNetworkImage(
                                  cacheManager: cacheProp(),
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: _ColDesign.bgSurfaceDark,
                                    child: Center(
                                      child: Image.asset(
                                        'assets/images/loading_5.gif',
                                        width: 40,
                                        height: 40,
                                      ),
                                    ),
                                  ),
                                  imageUrl:
                                      '${buildImageUrl(TMDB_BASE_IMAGE_URL, proxyUrl, isProxyEnabled, context)}w500/${belongsToCollection!.backdropPath!}',
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: _ColDesign.bgSurfaceDark,
                                    child: Icon(Icons.collections_rounded,
                                        size: 48, color: textPrim),
                                  ),
                                ),
                        ),
                        DecoratedBox(
                          decoration:
                              BoxDecoration(gradient: _ColDesign.heroOverlay),
                          child: const SizedBox.expand(),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: _ColDesign.space6),
                              child: Text(
                                tr('belongs_to_the', namedArgs: {
                                  'collection': belongsToCollection!.name!
                                }),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textPrim,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: _ColDesign.space4),
                            Material(
                              color: _ColDesign.primary,
                              borderRadius: BorderRadius.circular(9999),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CollectionDetailsWidget(
                                        belongsToCollection:
                                            belongsToCollection!,
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(9999),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: _ColDesign.space6,
                                      vertical: 14),
                                  child: Text(
                                    tr('view_collection'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
  }
}

class CollectionOverviewWidget extends StatefulWidget {
  final String? api;
  const CollectionOverviewWidget({super.key, this.api});

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
    final isDark = themeMode == 'dark' || themeMode == 'amoled';
    final textSec = isDark ? _ColDesign.textSecDark : _ColDesign.textSecLight;
    final surface =
        isDark ? _ColDesign.bgSurfaceDark : _ColDesign.bgCanvasLight;
    final border = _ColDesign.borderDark;

    if (collectionDetails == null) {
      return ShimmerBase(
        themeMode: themeMode,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: _ColDesign.screenPadH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 16,
                width: 120,
                decoration: BoxDecoration(
                  color: isDark
                      ? _ColDesign.bgElevatedDark
                      : _ColDesign.textSecLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: _ColDesign.space3),
              Container(
                height: 48,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? _ColDesign.bgElevatedDark
                      : _ColDesign.textSecLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: _ColDesign.screenPadH, vertical: _ColDesign.space2),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(_ColDesign.space4),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(_ColDesign.radiusMd),
          border: Border.all(color: border),
          boxShadow: const [_ColDesign.shadowCard],
        ),
        child: Text(
          collectionDetails!.overview!,
          style: TextStyle(
            color: textSec,
            fontSize: 14,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

class PartsList extends StatefulWidget {
  final String? api;
  final String? title;
  const PartsList({super.key, this.api, this.title});

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
    final imageQuality = context.watch<SettingsProvider>().imageQuality;
    final themeMode = context.watch<SettingsProvider>().appTheme;
    final isProxyEnabled = context.read<SettingsProvider>().enableProxy;
    final proxyUrl = context.read<AppDependencyProvider>().tmdbProxy;
    final isDark = themeMode == 'dark' || themeMode == 'amoled';
    final textPrim =
        isDark ? _ColDesign.textPrimDark : _ColDesign.textPrimLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(_ColDesign.screenPadH,
              _ColDesign.space4, _ColDesign.screenPadH, _ColDesign.space2),
          child: Row(
            children: [
              const LeadingDot(),
              Expanded(
                child: Text(
                  widget.title!,
                  style: TextStyle(
                    color: textPrim,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 260,
          child: collectionMovieList == null
              ? ShimmerBase(
                  themeMode: themeMode,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: _ColDesign.screenPadH),
                    itemCount: 3,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(right: _ColDesign.space3),
                        child: SizedBox(
                          width: 120,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? _ColDesign.bgElevatedDark
                                        : _ColDesign.textSecLight
                                            .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(
                                        _ColDesign.radiusMd),
                                  ),
                                ),
                              ),
                              const SizedBox(height: _ColDesign.space2),
                              Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? _ColDesign.bgElevatedDark
                                      : _ColDesign.textSecLight
                                          .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: collectionMovieList!.length,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: _ColDesign.screenPadH),
                  itemBuilder: (BuildContext context, int index) {
                    final movie = collectionMovieList![index];
                    return Padding(
                      padding: const EdgeInsets.only(right: _ColDesign.space3),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieDetailPage(
                                movie: movie,
                                heroId: '${movie.id}',
                              ),
                            ),
                          );
                        },
                        child: SizedBox(
                          width: 120,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Hero(
                                  tag: '${movie.id}',
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              _ColDesign.radiusMd),
                                          child: movie.posterPath == null
                                              ? Image.asset(
                                                  'assets/images/na_logo.png',
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
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
                                                      movie.posterPath!,
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
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  ),
                                                ),
                                        ),
                                        Positioned(
                                          top: _ColDesign.space2,
                                          left: _ColDesign.space2,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: _ColDesign.primary,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.star_rounded,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  movie.voteAverage!
                                                      .toStringAsFixed(1),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
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
                              const SizedBox(height: _ColDesign.space2),
                              Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: Text(
                                  movie.title!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: textPrim,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
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

class CollectionMovies extends StatefulWidget {
  final String? api;
  const CollectionMovies({
    super.key,
    this.api,
  });
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
    final imageQuality = context.watch<SettingsProvider>().imageQuality;
    final themeMode = context.watch<SettingsProvider>().appTheme;
    final isProxyEnabled = context.read<SettingsProvider>().enableProxy;
    final proxyUrl = context.read<AppDependencyProvider>().tmdbProxy;
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
