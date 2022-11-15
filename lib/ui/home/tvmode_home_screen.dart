import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:login/models/genres.dart';
import 'package:login/models/poster.dart';
import 'package:login/models/slide.dart';
import 'package:login/models/channel.dart' as model;
import 'package:login/ui/home/homeTab.dart';
import 'package:login/utils/config.dart';
import 'package:need_resume/need_resume.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class tvModeHome extends StatefulWidget {
  tvModeHome({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<tvModeHome> createState() => _tvModeHomeState();
}

class _tvModeHomeState extends ResumableState<tvModeHome> {
  int _counter = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 35, 40, 50),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: <Widget>[
                Text(widget.title),
                SizedBox(width: 50),
                TabBar(
                  isScrollable: true,
                  indicatorColor: Color.fromARGB(255, 255, 60, 70),
                  tabs: <Widget>[
                    Tab(text: 'Home'),
                    Tab(text: 'Movies'),
                    Tab(text: 'Shows')
                  ],
                )
              ],
            ),
            actions: <Widget>[
              IconButton(icon: Icon(Icons.search), onPressed: () {}),
              IconButton(icon: Icon(Icons.settings), onPressed: () {}),
            ],
          ),
          body: Center(
              child: TabBarView(
            children: <Widget>[
              HomeTab(),
              // MoviesTab(),
              // ShowsTab()
            ],
          )),
        ));
  }
}
