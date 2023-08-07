import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/movie_screens/movie_stream.dart';
import 'package:caffiene/utils/admob.dart';
import 'package:caffiene/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/models/movie_models.dart';
import 'package:caffiene/screens/movie_screens/widgets/movie_video_loader.dart';
import 'package:caffiene/utils/config.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class WatchNowButton extends StatefulWidget {
  const WatchNowButton({
    Key? key,
    required this.thumbnail,
    required this.movieId,
    this.movieName,
    this.movieImdbId,
    this.api,
    required this.releaseYear,
    this.adult,
  }) : super(key: key);
  final String? movieName;
  final int movieId;
  final int? movieImdbId;
  final bool? adult;
  final String? api;
  final int releaseYear;
  final String? thumbnail;

  @override
  State<WatchNowButton> createState() => _WatchNowButtonState();
}

class _WatchNowButtonState extends State<WatchNowButton> {
  Moviedetail? movieDetails;
  bool? isVisible = false;
  bool adLoaded = false;
  double? buttonWidth = 150;

  // google ads
  late InterstitialAd _interstitialAd;

  _loadIntel() async {
    if (showAds == false) {
      return false;
    }
    InterstitialAd.load(
        adUnitId: kInterstitial,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            debugPrint("AD LOADED");
            _interstitialAd = ad;
            adLoaded = true;
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  @override
  void initState() {
    super.initState();
    _loadIntel();
  }

  void streamSelectBottomSheet(
      {required String movieName,
      required String thumbnail,
      bool? adult,
      required int releaseYear,
      required int movieId}) {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          final mixpanel = Provider.of<SettingsProvider>(context).mixpanel;
          return Container(
              child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Watch with:',
                      style: kTextSmallHeaderStyle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: GestureDetector(
                    onTap: () {
                      mixpanel.track('Most viewed movies', properties: {
                        'Movie name': movieName,
                        'Movie id': movieId,
                        'Is Movie adult?': adult ?? 'unknown',
                      });

                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: ((context) {
                        return MovieVideoLoader(
                          releaseYear: releaseYear,
                          thumbnail: thumbnail,
                          videoTitle: movieName,
                          interstitialAd: _interstitialAd,
                          movieId: widget.movieId,
                        );
                      })));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'caffiene player (recommended)',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: GestureDetector(
                    onTap: () {
                      mixpanel.track('Most viewed movies', properties: {
                        'Movie name': movieName,
                        'Movie id': movieId,
                        'Is Movie adult?': adult ?? 'unknown',
                      });
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: ((context) {
                        return MovieStream(
                            streamUrl:
                                'https://2embed.to/embed/tmdb/movie?id=$movieId',
                            movieName: movieName);
                      })));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'Legacy (Webview)',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextButton(
        style: ButtonStyle(
          maximumSize: MaterialStateProperty.all(Size(buttonWidth!, 50)),
        ).copyWith(
            backgroundColor: MaterialStateProperty.all(
          Theme.of(context).colorScheme.primary,
        )),
        onPressed: () async {
          final mixpanel =
              Provider.of<SettingsProvider>(context, listen: false).mixpanel;
          mixpanel.track('Most viewed movies', properties: {
            'Movie name': widget.movieName,
            'Movie id': widget.movieId,
            'Is Movie adult?': widget.adult ?? 'unknown',
          });
          
          if (adLoaded == true) {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return MovieVideoLoader(
                videoTitle: widget.movieName!,
                releaseYear: widget.releaseYear,
                thumbnail: widget.thumbnail,
                interstitialAd: _interstitialAd,
                movieId: widget.movieId,
              );
            }));
          } else {
            openSnackbar(context, PROCESSING_VIDEO, Colors.red);
          }
        },
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                Icons.play_circle,
                color: Colors.white,
              ),
            ),
            const Text(
              'WATCH NOW',
              style: TextStyle(color: Colors.white),
            ),
            Visibility(
              visible: isVisible!,
              child: const Padding(
                padding: EdgeInsets.only(
                  left: 10.0,
                ),
                child: SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
