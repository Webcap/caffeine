import 'package:flutter/material.dart';
import 'package:login/utils/config.dart';
import 'package:pod_player/pod_player.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class Player extends StatefulWidget {
  const Player({required this.videoUrl, required this.videoTitle, Key? key})
      : super(key: key);
  final List<VideoQalityUrls> videoUrl;
  final String videoTitle;
  // final List<QualitiesList> qualitiesList;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  late final PodPlayerController controller;

  @override
  void initState() {
    controller = PodPlayerController(
      podPlayerConfig:
          const PodPlayerConfig(videoQualityPriority: [0, 360, 480, 720, 1080]),
      playVideoFrom: PlayVideoFrom.networkQualityUrls(
        videoPlayerOptions: VideoPlayerOptions(),
        videoUrls: widget.videoUrl,
        formatHint: VideoFormat.hls,
      ),
    )..initialise();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            //color: isDark ? const Color(0xFF202124) : const Color(0xFFFFFFFF),
            width: double.infinity,
            height: double.infinity,
            child: PodVideoPlayer(
              controller: controller,
              matchFrameAspectRatioToVideo: true,
              matchVideoAspectRatioToFrame: true,
              alwaysShowProgressBar: false,
              videoTitle: Text(widget.videoTitle),
              podProgressBarConfig: const PodProgressBarConfig(
                padding: kIsWeb
                    ? EdgeInsets.zero
                    : EdgeInsets.only(
                        bottom: 20,
                        left: 20,
                        right: 20,
                      ),
                playingBarColor: maincolor,
                circleHandlerColor: maincolor,
                backgroundColor: Colors.blueGrey,
                bufferedBarColor: maincolor2,
                alwaysVisibleCircleHandler: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
