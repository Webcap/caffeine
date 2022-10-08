import 'package:flutter/material.dart';

class Backgroupimage extends StatelessWidget {
  const Backgroupimage({Key? key, required this.imageback}) : super(key: key);

  final String imageback;
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
      image: DecorationImage(
          fit: BoxFit.fill,
          image: NetworkImage(
            imageback,
          )),
    ));
  }
}
