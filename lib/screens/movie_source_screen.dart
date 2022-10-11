import 'package:flutter/material.dart';
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
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Watch: ${widget.movieName}",
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: [
                        StreamListWidget(
                          streamName: '2embed',
                          streamLink: 'https://2embed.biz/embed/movie?tmdb=${widget.movieId}',
                          movieName: widget.movieName,
                        )
                      ],
                    )
                  ]
                ),
              ),
            )
          ]
        )
      ),
    );
  }
}
