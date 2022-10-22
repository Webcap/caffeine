import 'package:flutter/material.dart';
import 'package:login/models/movie_models.dart';
import 'package:transparent_image/transparent_image.dart';

class Poster extends StatelessWidget {
  final Movie item;
  const Poster(
    this.item,
  );

  @override
  Widget build(BuildContext context) {
    if (item.posterPath != null) {
      return FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image: item.posterPath.toString(),
        fit: BoxFit.fill,
      );
    } else {
      return Image.memory(kTransparentImage, fit: BoxFit.fill);
    }
  }
}
