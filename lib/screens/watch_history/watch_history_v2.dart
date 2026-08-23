import 'package:reelriot/widgets/size_configuration.dart';
import 'package:flutter/material.dart';

class WatchHistoryV2 extends StatefulWidget {
  const WatchHistoryV2({super.key});

  @override
  State<WatchHistoryV2> createState() => _WatchHistoryV2State();
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
