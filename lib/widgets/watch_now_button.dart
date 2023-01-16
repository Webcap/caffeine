import 'package:flutter/material.dart';
import 'package:login/models/movie_models.dart';
import 'package:login/provider/mixpanel_provider.dart';
import 'package:login/screens/movie_screens/movie_source_screen.dart';
import 'package:login/screens/movie_screens/movie_stream.dart';
import 'package:login/screens/movie_screens/widgets/movie_video_loader.dart';
import 'package:login/utils/config.dart';
import 'package:login/utils/next_screen.dart';
import 'package:provider/provider.dart';
import 'package:login/api/movies_api.dart';

class WatchNowButton extends StatefulWidget {
  const WatchNowButton(
      {Key? key,
      required this.movieId,
      this.movieName,
      this.movieImdbId,
      this.api})
      : super(key: key);
  final String? movieName;
  final int? movieImdbId;
  final int movieId;
  final String? api;

  @override
  State<WatchNowButton> createState() => _WatchNowButtonState();
}

class _WatchNowButtonState extends State<WatchNowButton> {
  Moviedetail? movieDetails;
  bool? isVisible = false;
  double? buttonWidth = 150;

  @override
  void initState() {
    super.initState();
  }
  // disabled for now

  // void streamSelectBottomSheet(
  //     {required String mediaType,
  //     required String imdbId,
  //     required String videoTitle,
  //     required String movieName,
  //     required String id,
  //     }) {
  //   showModalBottomSheet(
  //       context: context,
  //       builder: (builder) {
  //         //final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
  //         return Container(
  //             color: const Color(0xFFFFFFFF),
  //             child: SingleChildScrollView(
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: [
  //                   const Center(
  //                     child: Padding(
  //                       padding: EdgeInsets.all(8.0),
  //                       child: Text(
  //                         'Watch with:',
  //                         style: kTextSmallHeaderStyle,
  //                       ),
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.all(30.0),
  //                     child: GestureDetector(
  //                       onTap: () {
  //                         // mixpanel
  //                         //     .track('Most viewed movie pages', properties: {
  //                         //   'Movie name': movieName,
  //                         //   'Movie id': id,
  //                         // });

  //                         Navigator.pushReplacement(context,
  //                             MaterialPageRoute(builder: ((context) {
  //                           return MovieVideoLoader(
  //                             imdbID: imdbId,
  //                             videoTitle: videoTitle,
  //                           );
  //                         })));
  //                       },
  //                       child: Container(
  //                         decoration: BoxDecoration(
  //                             color: maincolor,
  //                             borderRadius: BorderRadius.circular(10)),
  //                         child: const Padding(
  //                           padding: EdgeInsets.all(20.0),
  //                           child: Text(
  //                             'caffeine player, no subtitles (reccomended)',
  //                             textAlign: TextAlign.center,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.all(30.0),
  //                     child: GestureDetector(
  //                       onTap: () {
  //                         // mixpanel
  //                         //     .track('Most viewed movie pages', properties: {
  //                         //   'Movie name': movieName,
  //                         //   'Movie id': id,
  //                         // });
  //                         Navigator.pushReplacement(context,
  //                             MaterialPageRoute(builder: ((context) {
  //                           return MovieStreamSelect(
  //                             movieName: videoTitle,
  //                             movieId: widget.movieId,
  //                             movieImdbId: imdbId,
  //                           );
  //                         })));
  //                       },
  //                       child: Container(
  //                         decoration: BoxDecoration(
  //                             color: maincolor,
  //                             borderRadius: BorderRadius.circular(10)),
  //                         child: const Padding(
  //                           padding: EdgeInsets.all(20.0),
  //                           child: Text(
  //                             '3rd party websites. With ADs, not recommended, with subtitles',
  //                             textAlign: TextAlign.center,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             ));
  //       });
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextButton(
        style: ButtonStyle(
            maximumSize: MaterialStateProperty.all(Size(buttonWidth!, 50)),
            backgroundColor:
                MaterialStateProperty.all(const Color(0xFFF57C00))),
        onPressed: () async {
          setState(() {
            isVisible = true;
            buttonWidth = 170;
          });
          await moviesApi().fetchMovieDetails(widget.api!).then((value) {
            setState(() {
              movieDetails = value;
            });
          });
          setState(() {
            isVisible = false;
            buttonWidth = 150;
          });
          // streamSelectBottomSheet(
          //     imdbId: movieDetails!.imdbId.toString(),
          //     mediaType: 'movie',
          //     videoTitle: movieDetails!.originalTitle!,
          //     movieName: movieDetails!.originalTitle!,
          //     id: movieDetails!.id!.toString());

          // THE LINES BELOW ARE CONMMENTED OUT FOR A REASON FIND OUT LATER

          // Navigator.push(context, MaterialPageRoute(builder: (context) {
          //   return StreamOptionSelect(mediaType: 'movie');
          //   // return MovieVideoLoader(
          //   //   imdbID: movieDetails!.imdbId!,
          //   //   videoTitle: movieDetails!.originalTitle!,
          //   // );
          // }));

          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return MovieStream(
                streamUrl:
                    'https://www.2embed.to/embed/tmdb/movie?id=${widget.movieId}',
                movieName: widget.movieName!);
          }));
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
