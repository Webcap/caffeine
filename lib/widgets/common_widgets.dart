import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/movies_api.dart';
import 'package:caffiene/models/movie_models.dart';
import 'package:caffiene/screens/common/did_you_know.dart';
import 'package:caffiene/screens/common/title_review.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';

Widget watchProvidersTabData(
        {required bool isDark,
        required String imageQuality,
        required String noOptionMessage,
        required List? watchOptions}) =>
    Container(
      padding: const EdgeInsets.all(8.0),
      child: watchOptions == null
          ? Center(
              child: Text(
              noOptionMessage,
              textAlign: TextAlign.center,
            ))
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 100,
                childAspectRatio: 0.65,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: watchOptions.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 6,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: watchOptions[index].logoPath == null
                              ? Image.asset(
                                  'assets/images/na_logo.png',
                                  fit: BoxFit.cover,
                                )
                              : CachedNetworkImage(
                                  fadeOutDuration:
                                      const Duration(milliseconds: 300),
                                  fadeOutCurve: Curves.easeOut,
                                  fadeInDuration:
                                      const Duration(milliseconds: 700),
                                  fadeInCurve: Curves.easeIn,
                                  imageUrl: TMDB_BASE_IMAGE_URL +
                                      imageQuality +
                                      watchOptions[index].logoPath!,
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
                                      watchProvidersImageShimmer(isDark),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    'assets/images/na_logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Expanded(
                          flex: 3,
                          child: Text(
                            watchOptions[index].providerName!,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )),
                    ],
                  ),
                );
              }),
    );

class DidYouKnow extends StatefulWidget {
  const DidYouKnow({Key? key, required this.api}) : super(key: key);

  final String? api;

  @override
  State<DidYouKnow> createState() => _DidYouKnowState();
}

class _DidYouKnowState extends State<DidYouKnow> {
  ExternalLinks? externalLinks;

  @override
  void initState() {
    moviesApi().fetchSocialLinks(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          externalLinks = value;
        });
      }
    });
    super.initState();
  }

  void navToDYK(String dataType, String dataName, String imdbId) {
    Navigator.push(context, MaterialPageRoute(builder: ((context) {
      return DidYouKnowScreen(
        dataType: dataType,
        dataName: dataName,
        imdbId: imdbId,
      );
    })));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Did You Know',
            style: kTextHeaderStyle,
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
              child: externalLinks == null
                  ? const Center(child: CircularProgressIndicator())
                  : externalLinks!.imdbId == null ||
                          externalLinks!.imdbId!.isEmpty
                      ? const Center(
                          child: Text(
                          'This movie doesn\'t have IMDB id therefore additional data can\'t be fetched.',
                          textAlign: TextAlign.center,
                        ))
                      : Wrap(
                          spacing: 5,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                navToDYK(
                                    'trivia', 'Trivia', externalLinks!.imdbId!);
                              },
                              child: const Text('Trivia'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                navToDYK(
                                    'quotes', 'Quotes', externalLinks!.imdbId!);
                              },
                              child: const Text('Quotes'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                navToDYK(
                                    'goofs', 'Goofs', externalLinks!.imdbId!);
                              },
                              child: const Text('Goofs'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                navToDYK('crazycredits', 'Crazy Credits',
                                    externalLinks!.imdbId!);
                              },
                              child: const Text('Crazy Credits'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                navToDYK(
                                    'alternateversions',
                                    'Alternate Versions',
                                    externalLinks!.imdbId!);
                              },
                              child: const Text('Alternate Versions'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                navToDYK('soundtrack', 'Soundtrack',
                                    externalLinks!.imdbId!);
                              },
                              child: const Text('Soundtrack'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: ((context) {
                                  return TitleReviews(
                                      imdbId: externalLinks!.imdbId!);
                                })));
                              },
                              child: const Text('Reviews'),
                            ),
                          ],
                        )),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
