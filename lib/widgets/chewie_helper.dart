import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ChewieHelper extends StatefulWidget {
  final VideoPlayerController videoPlayerController;

  const ChewieHelper({
    Key? key,
    required this.videoPlayerController,
  }) : super(key: key);

  @override
  State<ChewieHelper> createState() => _ChewieHelperState();
}

class _ChewieHelperState extends State<ChewieHelper> {
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();

    _chewieController = ChewieController(
      videoPlayerController: widget.videoPlayerController,
      aspectRatio: 16 / 9,
      autoInitialize: true,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Chewie(
          controller: _chewieController,
        ));
  }

  @override
  void dispose() {
    super.dispose();
    widget.videoPlayerController.dispose();
    _chewieController.dispose();
  }
}
