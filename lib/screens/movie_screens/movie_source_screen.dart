import 'package:flutter/material.dart';
import 'package:login/screens/movie_screens/movie_stream.dart';
import 'package:login/utils/config.dart';
import 'package:login/widgets/stream_list_widget.dart';

class MovieStreamSelect extends StatefulWidget {
  final String movieName;
  final int movieId;
  final dynamic movieImdbId;
  const MovieStreamSelect({
    Key? key,
    required this.movieName,
    required this.movieId,
    this.movieImdbId,
  }) : super(key: key);

  @override
  State<MovieStreamSelect> createState() => _MovieStreamSelectState();
}

class _MovieStreamSelectState extends State<MovieStreamSelect> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: maincolor2,
        title: Text(
          'Watch: ${widget.movieName}',
        ),
        leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        children: [
                          StreamListWidget(
                            streamName: '2embed',
                            streamLink:
                                'https://2embed.biz/embed/movie?tmdb=${widget.movieId}',
                            movieName: widget.movieName,
                          ),
                          Visibility(
                            visible: widget.movieImdbId == null ? false : true,
                            child: StreamListWidget(
                              streamName:
                                  '123Movie',
                              streamLink:
                                  'https://api.123movie.cc/imdb.php?imdb=${widget.movieImdbId}&server=vcu',
                              movieName: widget.movieName,
                            ),
                          ),
                          StreamListWidget(
                            streamName:
                                '2embed (multiple player options)',
                            streamLink:
                                'https://www.2embed.to/embed/tmdb/movie?id=${widget.movieId}',
                            movieName: widget.movieName,
                          ),
                          StreamListWidget(
                            streamName: 'onionflix (multiple player options)',
                            streamLink:
                                'https://onionflix.org/embed/movie?tmdb=${widget.movieId}',
                            movieName: widget.movieName,
                          ),
                          StreamListWidget(
                            streamName: 'smashystream (multiple player options)',
                            streamLink:
                                'https://hub.smashystream.com/embed/movie?tmdb=${widget.movieId}',
                            movieName: widget.movieName,
                          ),
                          StreamListWidget(
                            streamName: 'embedworld (multiple player options)',
                            streamLink:
                                'https://embedworld.xyz/public/embed/movie?tmdb=${widget.movieId}',
                            movieName: widget.movieName,
                          ),
                          StreamListWidget(
                            streamName:
                                'cinedb (multiple player options)',
                            streamLink:
                                'https://cinedb.top/embed/movie?tmdb=${widget.movieId}',
                            movieName: widget.movieName,
                          ),
                          StreamListWidget(
                            streamName:
                                'fembed (multiple player options)',
                            streamLink:
                                'https://fembed.ro/embed/movie?tmdb=${widget.movieId}',
                            movieName: widget.movieName,
                          ),
                          StreamListWidget(
                            streamName: 'moviehab (multiple player options)',
                            streamLink:
                                'https://moviehab.com/embed/movie?tmdb=${widget.movieId}',
                            movieName: widget.movieName,
                          ),
                          StreamListWidget(
                            streamName: 'vidsrc.me (multiple player options)',
                            streamLink:
                                'https://vidsrc.me/embed/${widget.movieId}/',
                            movieName: widget.movieName,
                          ),
                          StreamListWidget(
                            streamName: 'databasegdriveplayer (360p)',
                            streamLink:
                                'https://databasegdriveplayer.co/player.php?tmdb=${widget.movieId}',
                            movieName: widget.movieName,
                          ),
                          StreamListWidget(
                            streamName:
                                'openvids (multiple player options)',
                            streamLink:
                                'https://openvids.io/tmdb/movie/${widget.movieId}',
                            movieName: widget.movieName,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class StreamListWidget extends StatelessWidget {
  final String streamName;
  final String streamLink;
  final String movieName;
  const StreamListWidget({
    Key? key,
    required this.streamName,
    required this.streamLink,
    required this.movieName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return MovieStream(
            streamUrl: streamLink,
            movieName: movieName,
          );
        }));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              const Icon(Icons.play_circle_outline),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    child: Text(
                      streamName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style:
                          const TextStyle(fontFamily: 'Poppins', fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(
            color: Colors.white54,
          )
        ],
      ),
    );
  }
}
