import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:login/api/movies_api.dart';
import 'package:login/models/movie_models.dart';
import 'package:login/provider/imagequality_provider.dart';
import 'package:login/tv_mode/widgets/poster.dart';
import 'package:login/utils/config.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class Cover extends StatefulWidget {
  const Cover({
    Key? key,
    required this.item,
    required this.onTap,
    required this.onFocus,
  }) : super(key: key);

  final Movie item;
  final Function onTap;
  final Function onFocus;

  @override
  _CoverState createState() => _CoverState();
}

class _CoverState extends State<Cover> with SingleTickerProviderStateMixin {
  late FocusNode _node;
  late AnimationController _controller;
  late Animation<double> _animation;
  int _focusAlpha = 100;

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
    _animation =
        CurvedAnimation(parent: _controller, curve: Cubic(0.0, 0, 0.0, 0.0));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _node.dispose();
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

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: _onTap,
      focusNode: _node,
      focusColor: Colors.transparent,
      focusElevation: 0,
      child: buildCover(context),
    );
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
              //child: buildPosterImage(context),
              child: Stack(children: <Widget>[
                Poster(widget.item),
                new Container(
                  // child: Text(
                  //   widget.item.genres.map((e) => e.name).join("\n"),
                  //   style: TextStyle(
                  //       color: Color.fromARGB(255, 255, 180, 10), fontSize: 9),
                  // ),
                  padding: EdgeInsets.fromLTRB(2, 0, 2, 2),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                  ),
                ),
              ]),
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
                child: Text(widget.item.title.toString(),
                    maxLines: 2,
                    style: TextStyle(color: Colors.white, fontSize: 12)),
                alignment: Alignment.center),
            Align(
                // child: AddotionalInfo(
                //     Icons.star,
                //     Color.fromARGB(70, 255, 255, 255),
                //     "${widget.item.imdbRating}, ${widget.item.year}"),
                alignment: Alignment.center),
          ],
        ),
      ),
    );
  }
}
