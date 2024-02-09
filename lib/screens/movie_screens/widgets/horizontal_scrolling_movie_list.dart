import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/models/movie_models.dart';
import 'package:caffiene/screens/movie_screens/movie_details.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:caffiene/utils/constant.dart';

class HorizontalScrollingMoviesList extends StatelessWidget {
  const HorizontalScrollingMoviesList({
    Key? key,
    required ScrollController scrollController,
    required this.movieList,
    required this.imageQuality,
    required this.themeMode,
  })  : _scrollController = scrollController,
        super(key: key);

  final ScrollController _scrollController;
  final List<Movie>? movieList;
  final String imageQuality;
  final String themeMode;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: movieList!.length,
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
                          movie: movieList![index],
                          heroId: '${movieList![index].id}')));
            },
            child: SizedBox(
              width: 100,
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: Hero(
                      tag: '${movieList![index].id}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: movieList![index].posterPath == null
                                  ? Image.asset(
                                      'assets/images/na_rect.png',
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      cacheManager: cacheProp(),
                                      fadeOutDuration:
                                          const Duration(milliseconds: 300),
                                      fadeOutCurve: Curves.easeOut,
                                      fadeInDuration:
                                          const Duration(milliseconds: 700),
                                      fadeInCurve: Curves.easeIn,
                                      imageUrl:
                                          movieList![index].posterPath == null
                                              ? ''
                                              : TMDB_BASE_IMAGE_URL +
                                                  imageQuality +
                                                  movieList![index].posterPath!,
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
                                        'assets/images/na_rect.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                margin: const EdgeInsets.all(3),
                                alignment: Alignment.topLeft,
                                width: 50,
                                height: 25,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: themeMode == "dark" ||
                                            themeMode == "amoled"
                                        ? Colors.black45
                                        : Colors.white60),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                    ),
                                    Text(movieList![index]
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
                        movieList![index].title!,
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
    );
  }
}
