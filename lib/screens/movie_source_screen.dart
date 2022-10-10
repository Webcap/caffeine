import 'package:flutter/material.dart';

class movieSourceSelect extends StatefulWidget {
  const movieSourceSelect({super.key});

  @override
  State<movieSourceSelect> createState() => _movieSourceSelectState();
}

class _movieSourceSelectState extends State<movieSourceSelect> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
                    Column(children: [
                      StreamListWidget(
                        streamName: 'Stream one (multiple player options)',
                        streamLink:
                            'https://2embed.biz/embed/movie?tmdb=${widget.id}',
                        movieName: "name",
                      ),
                    ])
                  ],
                ),
              ),
            ),
          )
        ],
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
          // return MovieStream(
          //   streamUrl: streamLink,
          //   movieName: movieName,
          // );
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
            //color: isDark ? Colors.white54 : Colors.black54,
          )
        ],
      ),
    );
  }
}
