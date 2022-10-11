import 'package:flutter/material.dart';

class MovieStream extends StatefulWidget {
  final String streamUrl;
  final String movieName;
  const MovieStream({
    Key? key, required this.streamUrl, required this.movieName
  }) : super(key: key);

  @override
  State<MovieStream> createState() => _MovieStreamState();
}

class _MovieStreamState extends State<MovieStream> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
