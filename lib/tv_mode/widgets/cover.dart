import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:login/api/movies_api.dart';
import 'package:login/models/movie_models.dart';
import 'package:login/utils/config.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class Cover extends StatefulWidget {
  final String api, title;
  final dynamic discoverType;
  final bool isTrending;
  const Cover({
    Key? key,
    required this.api,
    required this.title,
    this.discoverType,
    required this.isTrending,
    required this.onTap,
    required this.onFocus,
  }) : super(key: key);

  final Function onTap;
  final Function onFocus;

  @override
  _CoverState createState() => _CoverState();
}

class _CoverState extends State<Cover> with SingleTickerProviderStateMixin {
  late FocusNode _node;
  late AnimationController _controller;
  late Animation<double> _animation;
  List<Movie>? moviesList;
  int _focusAlpha = 100;
  final ScrollController _scrollController = ScrollController();

  int pageNum = 2;
  bool isLoading = false;
  bool requestFailed = false;

  Future<String> getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });
        if (widget.isTrending == false) {
          var response = await http.get(
            Uri.parse(
                "$TMDB_API_BASE_URL/movie/${widget.discoverType}?api_key=$TMDB_API_KEY&include_adult=false&page=$pageNum"),
          );
          setState(() {
            pageNum++;
            isLoading = false;
            var newlistMovies = (json.decode(response.body)['results'] as List)
                .map((i) => Movie.fromJson(i))
                .toList();
            moviesList!.addAll(newlistMovies);
          });
        } else if (widget.isTrending == true) {
          var response = await http.get(
            Uri.parse(
                "$TMDB_API_BASE_URL/trending/movie/week?api_key=$TMDB_API_KEY&language=en-US&include_adult=false&page=$pageNum"),
          );
          setState(() {
            pageNum++;
            isLoading = false;
            var newlistMovies = (json.decode(response.body)['results'] as List)
                .map((i) => Movie.fromJson(i))
                .toList();
            moviesList!.addAll(newlistMovies);
          });
        }
      }
    });

    return "success";
  }

  late Widget image;

  @override
  void initState() {
    _node = FocusNode();
    _node.addListener(_onFocusChange);
    _controller = AnimationController(
        duration: const Duration(milliseconds: 100),
        vsync: this,
        lowerBound: 0.9,
        upperBound: 1);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    getMoreData();
    super.initState();
  }

  void getData() {
    moviesApi().fetchMovies('${widget.api}&include_adult=false').then((value) {
      setState(() {
        moviesList = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (moviesList == null) {
        setState(() {
          requestFailed = true;
          moviesList = [];
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _node.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_node.hasFocus) {
      _controller.forward();
      if (widget.onFocus != null) {
        widget.onFocus();
      }
    } else {
      _controller.reverse();
    }
  }

  void _onTap() {
    _node.requestFocus();
    if (widget.onTap != null) {
      widget.onTap();
    }
  }

  // void _openDetails() {
  //   Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(widget.item)));
  // }

  // bool _onKey(FocusNode node, RawKeyEvent event) {
  //   if(event is RawKeyDownEvent) {
  //     if(event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
  //       _onTap();
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   }
  //   return false;
  // }

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: _onTap,
      focusNode: _node,
      focusColor: Colors.transparent,
      focusElevation: 0,
      child: buildCover(context),
    );

    // return Focus(
    //     focusNode: _node,
    //     onKey: _onKey,
    //     child: Builder(
    //       builder: (context) {
    //         return buildCover(context);
    //       }
    //     ),
    // );
  }

  Widget buildCover(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: _onTap,
        child: Column(
          children: <Widget>[
            Container(
              child: Text("hey"),
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(_focusAlpha),
                  blurRadius: 15,
                  offset: Offset(10, 15),
                )
              ]),
            ),
            SizedBox(height: 5),
            Align(
              // child: Text(
              //   widget.item.title,
              //   maxLines: 1,
              //   style: TextStyle(color: Colors.white),
              // ),
              alignment: Alignment.topLeft,
            ),
            Align(
              // child: Text(widget.item.year.toString(),
              //     style: TextStyle(
              //         color: Color.fromARGB(70, 255, 255, 255), fontSize: 10)),
              // alignment: Alignment.topLeft,
            ),
          ],
        ),
      ),
    );
  }

  // FutureProvider<FanartItem> buildPosterImage(BuildContext context) {
  //   return FutureProvider<FanartItem>(
  //     create: (_) => Provider.of<FanartService>(context).getImages(widget.item),
  //     child: Consumer<FanartItem>(
  //       builder: (context, fanart, _) {
  //         if (fanart != null && fanart.poster != null) {
  //           widget.item.fanart = fanart;
  //           return FadeInImage.memoryNetwork(
  //             placeholder: kTransparentImage,
  //             image: widget.item.fanart.poster,
  //             fit: BoxFit.fill,
  //           );
  //         } else {
  //           return Image.memory(kTransparentImage, fit: BoxFit.fill);
  //           // return Image.memory(kTransparentImage);
  //         }
  //       },
  //     ),
  //   );
  // }
}

//   Widget CoverListView(BuildContext context, String endpoint) {
//     return FutureProvider<List<TraktModel>>(
//       create: (_) {
//         switch (endpoint) {
//           case 'movies':
//             return Provider.of<TraktService>(context).getMovies(6);
//           case 'shows':
//             return Provider.of<TraktService>(context).getShows(6);
//         }
//       },
//       child: Consumer<List<TraktModel>>(
//         builder: (context, items, _) {
//           if (items != null) {
//             return OrientationBuilder(builder: (context, orientation) {
//               int itemCount = orientation == Orientation.landscape ? 3 : 6;
//               return GridView.builder(
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: itemCount, childAspectRatio: 0.55),
//                 itemCount: itemCount,
//                 shrinkWrap: true,
//                 itemBuilder: (BuildContext context, int index) {
//                   TraktModel item = items[index];
//                   return Cover(
//                     item: item,
//                     onTap: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => DetailPage(item)));
//                     },
//                   );
//                 },
//               );
//             });
//           }
//           return Text('loading');
//         },
//       ),
//     );
//   }
// }
