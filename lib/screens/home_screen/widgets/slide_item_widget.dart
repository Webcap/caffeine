// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:caffiene/models/slide.dart';

class SlideItemWidget extends StatelessWidget {
  int index;

  Slide slide;
  SlideItemWidget({Key? key, required this.index, required this.slide})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(left: 50, right: 50),
      child: Stack(
        children: [
          Container(
            margin:
                EdgeInsets.only(right: MediaQuery.of(context).size.width / 3),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  slide.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 45,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 25),
                if (slide.channel != null || slide.poster != null)
                  Row(
                    children: [
                      Text(
                        "${(slide.poster != null)
                                    ? slide.poster?.rating
                                    : (slide.channel != null)
                                        ? slide.channel?.rating
                                        : ""} / 5",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800),
                      ),
                      RatingBar.builder(
                        // initialRating: ((slide.poster != null)
                        //     ? slide.poster?.rating
                        //     : (slide.channel != null)
                        //         ? slide.channel?.rating
                        //         : 0),
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 15.0,
                        ignoreGestures: true,
                        unratedColor: Colors.amber.withOpacity(0.4),
                        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          print(rating);
                        },
                      ),
                      const SizedBox(width: 10),
                      if (slide.poster != null)
                        Text(
                          "•  ${slide.poster?.imdb} / 10 ",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800),
                        ),
                      if (slide.poster != null)
                        Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                          decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(5)),
                          child: const Text(
                            "IMDb",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800),
                          ),
                        )
                    ],
                  ),
                const SizedBox(height: 10),
                if (slide.channel != null)
                  Row(
                    children: [
                      Text(
                        " ${slide.channel!.classification}  ${slide.channel!.getCategoriesList()}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900),
                      ),
                      // for (Country g in slide.channel.countries)
                      //   Row(
                      //     children: [
                      //       Text(
                      //         " • ",
                      //         style: TextStyle(
                      //             color: Colors.white,
                      //             fontSize: 20,
                      //             fontWeight: FontWeight.w800),
                      //       ),
                      //       CachedNetworkImage(imageUrl: g.image, width: 25),
                      //     ],
                      //   ),
                    ],
                  ),
                if (slide.poster != null)
                  Text(
                    "${slide.poster?.year} • ${slide.poster?.classification} • ${slide.poster!.duration} • ${slide.poster!.getGenresList()}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900),
                  ),
                if (slide.channel != null || slide.poster != null)
                  const SizedBox(height: 25),
                if (slide.channel != null || slide.poster != null)
                  Text(
                    ((slide.poster != null)
                            ? slide.poster?.description
                            : (slide.channel != null)
                                ? slide.channel?.description
                                : "")
                        .toString(),
                    style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        height: 1.5,
                        fontWeight: FontWeight.normal),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 40,
            child: GestureDetector(
              onTap: () {
                if (slide.channel != null) {
                  Future.delayed(const Duration(milliseconds: 50), () {
                    // Navigator.push(
                    //   context,
                    //   PageRouteBuilder(
                    //     pageBuilder: (context, animation1, animation2) =>
                    //         ChannelDetail(channel: slide.channel),
                    //     transitionDuration: Duration(seconds: 0),
                    //   ),
                    // );
                  });
                }
                if (slide.poster != null) {
                  Future.delayed(const Duration(milliseconds: 50), () {
                    // Navigator.push(
                    //   context,
                    //   PageRouteBuilder(
                    //     pageBuilder: (context, animation1, animation2) =>
                    //         (slide.poster?.type == "serie")
                    //             ? Serie(serie: slide.poster)
                    //             : Movie(movie: slide.poster),
                    //     transitionDuration: Duration(seconds: 0),
                    //   ),
                    // );
                  });
                }
              },
              child: GestureDetector(
                onTap: () {
                  if (slide.channel != null) {
                    Future.delayed(const Duration(milliseconds: 50), () {
                      // Navigator.push(
                      //   context,
                      //   PageRouteBuilder(
                      //     pageBuilder: (context, animation1, animation2) =>
                      //         ChannelDetail(channel: slide.channel),
                      //     transitionDuration: Duration(seconds: 0),
                      //   ),
                      // );
                    });
                  }
                  if (slide.poster != null) {
                    // Future.delayed(Duration(milliseconds: 50), () {
                    //   Navigator.push(
                    //     context,
                    //     PageRouteBuilder(
                    //       pageBuilder: (context, animation1, animation2) =>
                    //           (slide.poster.type == "serie")
                    //               ? Serie(serie: slide.poster)
                    //               : Movie(movie: slide.poster),
                    //       transitionDuration: Duration(seconds: 0),
                    //     ),
                    //   );
                    // });
                  }
                },
                child: Container(
                  height: 40,
                  width: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white30,
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                            border: Border(
                                right: BorderSide(
                                    width: 1, color: Colors.black12))),
                        child: const Center(
                            child: Icon(Icons.play_arrow,
                                size: 30, color: Colors.white)),
                      ),
                      const Expanded(
                          child: Center(
                              child: Text(
                        "Watch Now",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500),
                      )))
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
