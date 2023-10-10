import 'package:cached_network_image/cached_network_image.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/movies_api.dart';
import 'package:caffiene/models/movie_models.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // void navToDYK(String dataType, String dataName, String imdbId) {
  //   Navigator.push(context, MaterialPageRoute(builder: ((context) {
  //     return DidYouKnowScreen(
  //       dataType: dataType,
  //       dataName: dataName,
  //       imdbId: imdbId,
  //     );
  //   })));
  // }

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
                          // children: [
                          //   ElevatedButton(
                          //     onPressed: () {
                          //       navToDYK(
                          //           'trivia', 'Trivia', externalLinks!.imdbId!);
                          //     },
                          //     child: const Text('Trivia'),
                          //   ),
                          //   ElevatedButton(
                          //     onPressed: () {
                          //       navToDYK(
                          //           'quotes', 'Quotes', externalLinks!.imdbId!);
                          //     },
                          //     child: const Text('Quotes'),
                          //   ),
                          //   ElevatedButton(
                          //     onPressed: () {
                          //       navToDYK(
                          //           'goofs', 'Goofs', externalLinks!.imdbId!);
                          //     },
                          //     child: const Text('Goofs'),
                          //   ),
                          //   ElevatedButton(
                          //     onPressed: () {
                          //       navToDYK('crazycredits', 'Crazy Credits',
                          //           externalLinks!.imdbId!);
                          //     },
                          //     child: const Text('Crazy Credits'),
                          //   ),
                          //   ElevatedButton(
                          //     onPressed: () {
                          //       navToDYK(
                          //           'alternateversions',
                          //           'Alternate Versions',
                          //           externalLinks!.imdbId!);
                          //     },
                          //     child: const Text('Alternate Versions'),
                          //   ),
                          //   ElevatedButton(
                          //     onPressed: () {
                          //       navToDYK('soundtrack', 'Soundtrack',
                          //           externalLinks!.imdbId!);
                          //     },
                          //     child: const Text('Soundtrack'),
                          //   ),
                          //   ElevatedButton(
                          //     onPressed: () {
                          //       Navigator.push(context,
                          //           MaterialPageRoute(builder: ((context) {
                          //         return TitleReviews(
                          //             imdbId: externalLinks!.imdbId!);
                          //       })));
                          //     },
                          //     child: const Text('Reviews'),
                          //   ),
                          // ],
                        )),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}

class ShimmerBase extends StatelessWidget {
  const ShimmerBase({Key? key, required this.child, required this.isDark})
      : super(key: key);

  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade900 : Colors.grey.shade300,
      highlightColor:
          isDark ? Colors.grey.shade800.withOpacity(0.1) : Colors.grey.shade200,
      child: child,
    );
  }
}

class LeadingDot extends StatelessWidget {
  const LeadingDot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String appLang = Provider.of<SettingsProvider>(context).appLanguage;
    return Container(
      color: Theme.of(context).primaryColor,
      width: 13,
      height: 13,
      margin: appLang == 'ar'
          ? const EdgeInsets.only(left: 8)
          : const EdgeInsets.only(right: 8),
    );
  }
}

class ExternalPlay extends StatelessWidget {
  const ExternalPlay({Key? key, required this.sources}) : super(key: key);

  final Map<String, String> sources;

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];

    for (int i = 0; i < sources.length; i++) {
      final url = Uri.encodeFull(sources.entries.elementAt(i).value);
      items.add(TextButton(
          onPressed: () async {
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(sources.entries.elementAt(i).value),
                  mode: LaunchMode.externalNonBrowserApplication);
            }
          },
          child: Text(sources.entries.elementAt(i).key)));
    }
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Open in external player',
              style: Theme.of(context).textTheme.headlineSmall,
              maxLines: 3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            Wrap(
              spacing: 10,
              children: items,
            ),
          ],
        ),
      ),
    );
  }
}
