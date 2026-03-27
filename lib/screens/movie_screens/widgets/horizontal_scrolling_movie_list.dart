import 'package:caffiene/functions/functions.dart';
import 'package:caffiene/widgets/cached_image.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/models/movie_models.dart';
import 'package:caffiene/screens/movie_screens/movie_details.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:caffiene/utils/constant.dart';
import 'package:provider/provider.dart';

class HorizontalScrollingMoviesList extends StatelessWidget {
  const HorizontalScrollingMoviesList({
    super.key,
    required ScrollController scrollController,
    required this.movieList,
    required this.imageQuality,
    required this.themeMode,
  }) : _scrollController = scrollController;

  final ScrollController _scrollController;
  final List<Movie>? movieList;
  final String imageQuality;
  final String themeMode;

  @override
  Widget build(BuildContext context) {
    final isProxyEnabled = context.read<SettingsProvider>().enableProxy;
    final proxyUrl = context.read<AppDependencyProvider>().tmdbProxy;
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: movieList!.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) => HorizontalMovieListItem(
        movie: movieList![index],
        imageQuality: imageQuality,
        themeMode: themeMode,
        proxyUrl: proxyUrl,
        isProxyEnabled: isProxyEnabled,
      ),
    );
  }
}

/// Extracted list item to avoid parent rebuilds triggering all items.
class HorizontalMovieListItem extends StatelessWidget {
  const HorizontalMovieListItem({
    super.key,
    required this.movie,
    required this.imageQuality,
    required this.themeMode,
    required this.proxyUrl,
    required this.isProxyEnabled,
  });

  final Movie movie;
  final String imageQuality;
  final String themeMode;
  final String proxyUrl;
  final bool isProxyEnabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      MovieDetailPage(movie: movie, heroId: '${movie.id}')));
        },
        child: SizedBox(
          width: 100,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 6,
                child: Hero(
                  tag: '${movie.id}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: movie.posterPath == null
                              ? Image.asset('assets/images/na_logo.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity)
                              : CachedPosterImage(
                                  cacheManager: cacheProp(),
                                  imageUrl: movie.posterPath == null
                                      ? ''
                                      : buildImageUrl(
                                              TMDB_BASE_IMAGE_URL,
                                              proxyUrl,
                                              isProxyEnabled,
                                              context) +
                                          imageQuality +
                                          movie.posterPath!,
                                  themeMode: themeMode,
                                  placeholder: (context, url) =>
                                      scrollingImageShimmer(themeMode),
                                  errorWidget: (context, url, error) =>
                                      Image.asset('assets/images/na_logo.png',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity),
                                ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            margin: const EdgeInsets.all(3),
                            alignment: Alignment.centerLeft,
                            constraints: const BoxConstraints(
                                maxWidth: 50, maxHeight: 25),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color:
                                    themeMode == "dark" || themeMode == "amoled"
                                        ? Colors.black45
                                        : Colors.white60),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star_rounded,
                                      size: 14,
                                      color: themeMode == "dark" ||
                                              themeMode == "amoled"
                                          ? Colors.white
                                          : Colors.black87),
                                  const SizedBox(width: 2),
                                  Text(
                                    movie.voteAverage!.toStringAsFixed(1),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: themeMode == "dark" ||
                                                themeMode == "amoled"
                                            ? Colors.white
                                            : Colors.black87),
                                  ),
                                ],
                              ),
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
                    movie.title!,
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
  }
}
