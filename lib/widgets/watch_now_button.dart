import 'package:caffiene/utils/admob.dart';
import 'package:caffiene/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/models/movie_models.dart';
import 'package:caffiene/screens/movie_screens/movie_source_screen.dart';
import 'package:caffiene/screens/movie_screens/movie_stream.dart';
import 'package:caffiene/screens/movie_screens/widgets/movie_video_loader.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/utils/next_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:caffiene/api/movies_api.dart';

class WatchNowButton extends StatefulWidget {
  const WatchNowButton({
    Key? key,
    required this.thumbnail,
    required this.movieId,
    this.movieName,
    this.movieImdbId,
    this.api,
    required this.releaseYear,
    required this.adult,
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
