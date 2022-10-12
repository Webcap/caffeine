import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}