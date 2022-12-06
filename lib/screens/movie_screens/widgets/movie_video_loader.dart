import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:login/screens/player/player.dart';
import 'package:login/utils/config.dart';
import 'package:pod_player/pod_player.dart';
import 'package:web_scraper/web_scraper.dart';
import 'package:http/http.dart' as http;

class MovieVideoLoader extends StatefulWidget {
  const MovieVideoLoader({
    Key? key,
    required this.imdbID,
    required this.videoTitle,
  }) : super(key: key);

  final String imdbID;
  final String videoTitle;

  @override
  State<MovieVideoLoader> createState() => _MovieVideoLoaderState();
}

class _MovieVideoLoaderState extends State<MovieVideoLoader> {
  List<VideoQalityUrls>? videoUrls = [];
  late Uri completem3u8;
  final webScraper = WebScraper(TWOEMBED_BASE_URL);
  List<Map<String, dynamic>>? videoSrc;

  @override
  void initState() {
    parseHls();
    super.initState();
  }

  Future<void> parseHls([HlsMasterPlaylist? masterPlaylist]) async {
    if (await webScraper.loadWebPage('/play/movie.php?imdb=${widget.imdbID}')) {
      setState(() {
        videoSrc = webScraper.getElement('#player > source', ['src', 'type']);
      });
    }
    HlsPlaylist playlist;
    var dio = Dio();
    completem3u8 = await dio
        .getUri(
          Uri.parse('https://2embed.biz/play/'
              '${videoSrc![0]['attributes']['src']}'),
        )
        .then((value) => value.redirects[0].location);
    if (completem3u8.host.isEmpty) {
      SnackBar(content: Text('The video couldn\'t be found on the server :('));
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        'Couldn\'t find the video on the server :(',
        style: TextStyle(
            //color: widget.isDark ? Colors.white : Colors.black,
            fontFamily: 'PoppinsSB'),
      )));
    }
    final data = await http.get(completem3u8).then((res) => res.body);
    final bodyLength =
        await http.get(completem3u8).then((value) => value.bodyBytes.length);
    if (bodyLength <= 110) {
      videoUrls!.add(VideoQalityUrls(quality: 0, url: completem3u8.toString()));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: ((context) {
        return Player(
          videoUrl: videoUrls!,
          videoTitle: widget.videoTitle,
        );
      })));
    }
    playlist = await HlsPlaylistParser.create(masterPlaylist: masterPlaylist)
        .parseString(completem3u8, data);
    if (playlist is HlsMasterPlaylist) {
      // master m3u8 file
      playlist.variants
        ..sort((a, b) => b.format.bitrate! - a.format.bitrate!)
        ..forEach((v) {
          setState(() {
            videoUrls!.add(VideoQalityUrls(
                quality: v.format.height!, url: v.url.toString()));
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: ((context) {
              return Player(
                videoUrl: videoUrls!,
                videoTitle: widget.videoTitle,
              );
            })));
          });
        });
      videoUrls!
          .insert(0, VideoQalityUrls(quality: 0, url: completem3u8.toString()));

      return parseHls(playlist);
    } else if (playlist is HlsMediaPlaylist) {}
  }

  @override
  Widget build(BuildContext context) {
    SpinKitChasingDots spinKitChasingDots = SpinKitChasingDots(
      color: Colors.black,
      size: 60,
    );
    return Scaffold(
      body: Container(
        //color:
            //widget.isDark ? const Color(0xFF202124) : const Color(0xFFFFFFFF),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              spinKitChasingDots,
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Initializing player',
                  style: kTextSmallHeaderStyle,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
