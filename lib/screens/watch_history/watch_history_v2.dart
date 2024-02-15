import 'package:caffiene/widgets/size_configuration.dart';
import 'package:flutter/material.dart';

class WatchHistoryV2 extends StatefulWidget {
  const WatchHistoryV2({ Key? key }) : super(key: key);

  @override
  _WatchHistoryV2State createState() => _WatchHistoryV2State();
}

class _WatchHistoryV2State extends State<WatchHistoryV2> {
  
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return const Scaffold(
      body: SingleChildScrollView(
        child: Placeholder(),
      ),
    );
  }
}