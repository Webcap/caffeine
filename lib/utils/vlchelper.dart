// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

// class vlcHelper extends StatefulWidget {
//   final VideoPlayerController videoPlayerController;

//   const vlcHelper({
//     Key? key,
//     required this.videoPlayerController,
//   }) : super(key: key);

//   @override
//   State<vlcHelper> createState() => _vlcHelperState();
// }

// class _vlcHelperState extends State<vlcHelper> {
//   late vlcHelper _vlcHelperController;

//   @override
//   void initState() {
//     super.initState();

//     _vlcHelperController = vlcHelperController(
//       videoPlayerController: widget.videoPlayerController,
//       aspectRatio: 16 / 9,
//       autoInitialize: true,
//       errorBuilder: (context, errorMessage) {
//         return Center(
//           child: Text(
//             errorMessage,
//             style: TextStyle(color: Colors.white),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Chewie(
//           controller: _chewieController,
//         ));
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     widget.videoPlayerController.dispose();
//     _chewieController.dispose();
//   }
// }
