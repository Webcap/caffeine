// ignore_for_file: unused_field

import 'package:cached_network_image/cached_network_image.dart';
import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/bookmarks_provider.dart';
import 'package:reelriot/utils/constant.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/models/movie_models.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/movie_screens/movie_details.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';

// ── Design tokens (design.json) ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFFDC2626);
  static const ratingGold = Color(0xFFEAB308);
  static const bgCanvasDark = Color(0xFF030712);
  static const bgCanvasLight = Color(0xFFF8FAFC);
  static const surfaceElevatedDark = Color(0x0AFFFFFF);
  static const surfaceElevatedLight = Color(0xFFF1F5F9);
  static const borderDark = Color(0x14FFFFFF);
  static const borderLight = Color(0x140F172A);
  static const textPrimDark = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
  static const textSecDark = Color(0xB8FFFFFF);
  static const textSecLight = Color(0xFF64748B);
  static const textTertDark = Color(0x80FFFFFF);
  static const textTertLight = Color(0xFF94A3B8);
}

class MovieBookmark extends StatefulWidget {
  const MovieBookmark({
    super.key,
    required this.movieList,
  });

  final List<Movie>? movieList;

  @override
  State<MovieBookmark> createState() => _MovieBookmarkState();
}

class _MovieBookmarkState extends State<MovieBookmark> {
  final _scrollController = ScrollController();

  Future<void> _onRefresh() async {
    await Provider.of<BookmarksProvider>(context, listen: false).fetchMovies();
  }

  Future<bool?> _removeMovie(Movie movie) async {
    try {
      await Provider.of<BookmarksProvider>(context, listen: false)
          .removeMovie(movie.id!);
      return true;
    } catch (_) {
      return false;
    }
  }

  Widget _buildEmptyState(bool isDark) {
    final textPrim = isDark ? _C.textPrimDark : _C.textPrimLight;
    final textTert = isDark ? _C.textTertDark : _C.textTertLight;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border_rounded,
            size: 72,
            color: textTert.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 20),
          Text(
            tr("no_movies_bookmarked"),
            textAlign: TextAlign.center,
            style: kTextSmallHeaderStyle.copyWith(
              color: textPrim,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard({
    required Movie movie,
    required String themeMode,
    required String imageQuality,
    required bool isProxyEnabled,
    required String proxyUrl,
    required bool isDark,
  }) {
    return Dismissible(
      key: ValueKey<int>(movie.id!),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _removeMovie(movie),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: _C.primary.withValues(alpha: 0.9),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: Card(
        color: isDark ? _C.surfaceElevatedDark : _C.surfaceElevatedLight,
        elevation: 0,
        margin: const EdgeInsets.all(6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? _C.borderDark : _C.borderLight,
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MovieDetailPage(movie: movie, heroId: '${movie.id}'),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
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
                            borderRadius: BorderRadius.circular(8),
                            child: movie.posterPath == null
                                ? Image.asset(
                                    'assets/images/na_logo.png',
                                    fit: BoxFit.cover,
                                    height: double.infinity,
                                  )
                                : CachedNetworkImage(
                                    cacheManager: cacheProp(),
                                    fadeOutDuration:
                                        const Duration(milliseconds: 300),
                                    fadeOutCurve: Curves.easeOut,
                                    fadeInDuration:
                                        const Duration(milliseconds: 700),
                                    fadeInCurve: Curves.easeIn,
                                    imageUrl: buildImageUrl(
                                          TMDB_BASE_IMAGE_URL,
                                          proxyUrl,
                                          isProxyEnabled,
                                          context,
                                        ) +
                                        imageQuality +
                                        movie.posterPath!,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) =>
                                        scrollingImageShimmer(themeMode),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      'assets/images/na_logo.png',
                                      fit: BoxFit.cover,
                                      height: double.infinity,
                                    ),
                                  ),
                          ),
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: _C.ratingGold.withValues(alpha: 0.18),
                                border: Border.all(
                                  color: _C.ratingGold.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 13,
                                    color: _C.ratingGold,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    movie.voteAverage!.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: _C.ratingGold,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () async {
                                await _removeMovie(movie);
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withValues(alpha: 0.5),
                                  border: Border.all(
                                    color: _C.borderDark,
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.bookmark_rounded,
                                  size: 18,
                                  color: _C.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  flex: 2,
                  child: Text(
                    movie.title!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? _C.textPrimDark : _C.textPrimLight,
                      fontFamily: 'PoppinsSB',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListCard({
    required Movie movie,
    required String themeMode,
    required String imageQuality,
    required bool isProxyEnabled,
    required String proxyUrl,
    required bool isDark,
  }) {
    return Dismissible(
      key: ValueKey<int>(movie.id!),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _removeMovie(movie),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: _C.primary.withValues(alpha: 0.9),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: Card(
        color: isDark ? _C.surfaceElevatedDark : _C.surfaceElevatedLight,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? _C.borderDark : _C.borderLight,
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MovieDetailPage(movie: movie, heroId: '${movie.id}'),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8, left: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: SizedBox(
                        width: 85,
                        height: 130,
                        child: Hero(
                          tag: '${movie.id}',
                          child: Material(
                            type: MaterialType.transparency,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                children: [
                                  movie.posterPath == null
                                      ? Image.asset(
                                          'assets/images/na_logo.png',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        )
                                      : CachedNetworkImage(
                                          cacheManager: cacheProp(),
                                          fadeOutDuration:
                                              const Duration(milliseconds: 300),
                                          fadeOutCurve: Curves.easeOut,
                                          fadeInDuration:
                                              const Duration(milliseconds: 700),
                                          fadeInCurve: Curves.easeIn,
                                          imageUrl: buildImageUrl(
                                                TMDB_BASE_IMAGE_URL,
                                                proxyUrl,
                                                isProxyEnabled,
                                                context,
                                              ) +
                                              imageQuality +
                                              movie.posterPath!,
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
                                              mainPageVerticalScrollImageShimmer(
                                            themeMode,
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                            'assets/images/na_logo.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () async {
                                        await _removeMovie(movie);
                                      },
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black
                                              .withValues(alpha: 0.5),
                                        ),
                                        child: const Icon(
                                          Icons.bookmark_rounded,
                                          size: 14,
                                          color: _C.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title!,
                            style: TextStyle(
                              fontFamily: 'PoppinsSB',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color:
                                  isDark ? _C.textPrimDark : _C.textPrimLight,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: _C.ratingGold.withValues(alpha: 0.14),
                              border: Border.all(
                                color: _C.ratingGold.withValues(alpha: 0.28),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 12,
                                  color: _C.ratingGold,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  movie.voteAverage!.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _C.ratingGold,
                                    fontFamily: 'PoppinsSB',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: isDark ? _C.borderDark : _C.borderLight,
                  endIndent: 24,
                  indent: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final viewType = Provider.of<SettingsProvider>(context).defaultView;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (widget.movieList == null && viewType == 'grid') {
      return Container(child: moviesAndTVShowGridShimmer(themeMode));
    }

    if (widget.movieList == null && viewType == 'list') {
      return Container(
        child: mainPageVerticalScrollShimmer(
          themeMode: themeMode,
          isLoading: false,
          scrollController: _scrollController,
        ),
      );
    }

    final movies = widget.movieList!;
    if (movies.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: viewType == 'grid'
            ? GridView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 150,
                  childAspectRatio: 0.48,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                itemCount: movies.length,
                itemBuilder: (context, index) => _buildGridCard(
                  movie: movies[index],
                  themeMode: themeMode,
                  imageQuality: imageQuality,
                  isProxyEnabled: isProxyEnabled,
                  proxyUrl: proxyUrl,
                  isDark: isDark,
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                itemCount: movies.length,
                itemBuilder: (context, index) => _buildListCard(
                  movie: movies[index],
                  themeMode: themeMode,
                  imageQuality: imageQuality,
                  isProxyEnabled: isProxyEnabled,
                  proxyUrl: proxyUrl,
                  isDark: isDark,
                ),
              ),
      ),
    );
  }
}
