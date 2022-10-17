import 'package:flutter/material.dart';
import 'package:login/screens/movie_screens/streaming_service_screen.dart';
import 'package:login/utils/config.dart';

class MoviesFromWatchProviders extends StatefulWidget {
  const MoviesFromWatchProviders({Key? key}) : super(key: key);

  @override
  MoviesFromWatchProvidersState createState() =>
      MoviesFromWatchProvidersState();
}

class MoviesFromWatchProvidersState extends State<MoviesFromWatchProviders> {
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Streaming services',
              style: kTextHeaderStyle,
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 75,
            child: Row(
              children: [
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      StreamingServicesWidget(
                        imagePath: 'assets/images/netflix.png',
                        title: 'Netflix',
                        providerID: 8,
                      ),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/amazon_prime.png',
                        title: 'Amazon Prime',
                        providerID: 9,
                      ),
                      StreamingServicesWidget(
                          imagePath: 'assets/images/disney_plus.png',
                          title: 'Disney plus',
                          providerID: 337),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/hulu.png',
                        title: 'hulu',
                        providerID: 15,
                      ),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/hbo_max.png',
                        title: 'HBO Max',
                        providerID: 384,
                      ),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/apple_tv.png',
                        title: 'Apple TV plus',
                        providerID: 350,
                      ),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/peacock.png',
                        title: 'Peacock',
                        providerID: 387,
                      ),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/itunes.png',
                        title: 'iTunes',
                        providerID: 2,
                      ),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/youtube.png',
                        title: 'YouTube Premium',
                        providerID: 188,
                      ),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/paramount.png',
                        title: 'Paramount Plus',
                        providerID: 531,
                      ),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/netflix.png',
                        title: 'Netflix Kids',
                        providerID: 175,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]);
  }
}

class StreamingServicesWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final int providerID;
  const StreamingServicesWidget({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.providerID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return StreamingServicesMovies(
            providerId: providerID,
            providerName: title,
          );
        }));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 60,
          width: 200,
          decoration: BoxDecoration(
              color: maincolor3,
              borderRadius: BorderRadius.circular(15)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image(
                image: AssetImage(imagePath),
                height: 50,
                width: 50,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(title, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
