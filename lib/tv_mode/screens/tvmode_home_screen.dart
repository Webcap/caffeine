import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:login/tv_mode/widget/homeTab.dart';
import 'package:login/utils/config.dart';

class tvModeHome extends StatefulWidget {
  const tvModeHome({Key? key, required this.title}) :super(key: key);

   final String title;

  @override
  State<tvModeHome> createState() => _tvModeHomeState();
}

class _tvModeHomeState extends State<tvModeHome> {
  int _counter = 0;

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
          LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
        },
        child: Scaffold(
          backgroundColor: maincolor3,
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
                    Tab(text: 'TV Shows'),
                  ],
                )
              ],
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: TabBarView(
                children: <Widget>[
                  homeTab(),
                  // tvTab(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
