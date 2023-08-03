import 'package:flutter/material.dart';

class MoviePageButtons extends StatefulWidget {
  const MoviePageButtons({Key? key}) : super(key: key);

  @override
  State<MoviePageButtons> createState() => _MoviePageButtonsState();
}

class _MoviePageButtonsState extends State<MoviePageButtons> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xff292837),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff292837).withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1
                )
              ]
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 35,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color(0xff292837),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xff292837).withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1)
                ]),
            child: const Icon(
              Icons.favorite_border,
              color: Colors.white,
              size: 35,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color(0xff292837),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xff292837).withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1)
                ]),
            child: const Icon(
              Icons.download,
              color: Colors.white,
              size: 35,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color(0xff292837),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xff292837).withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1)
                ]),
            child: const Icon(
              Icons.share,
              color: Colors.white,
              size: 35,
            ),
          ),
        ],
      ),
    );
  }
}
