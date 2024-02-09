import 'package:caffiene/video_providers/regularVideoLinks.dart';

/// Currently available providers from the FlixQuest API: flixhq, zoe, gomovies, vidsrc, showbox

class CaffeineAPIStreamSources {
  CaffeineAPIStreamSources(
      {required this.videoLinks,
      required this.videoSubtitles,
      required this.messageExists});

  List<FlixQuestAPIVideoLinks>? videoLinks;
  List<FlixQuestAPISubLinks>? videoSubtitles;

  bool? messageExists;

  CaffeineAPIStreamSources.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('sources') && json['sources'] != null) {
      videoLinks = [];
      json['sources'].forEach((v) {
        videoLinks!.add(FlixQuestAPIVideoLinks.fromJson(v));
      });
    }
    if (json.containsKey('subtitles') && json['subtitles'] != null) {
      videoSubtitles = [];
      json['subtitles'].forEach((v) {
        videoSubtitles!.add(FlixQuestAPISubLinks.fromJson(v));
      });
    }
    if (json.containsKey('message')) {
      messageExists = true;
    }
  }
}

class FlixQuestAPIVideoLinks extends RegularVideoLinks {
  FlixQuestAPIVideoLinks.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);
}

class FlixQuestAPISubLinks extends RegularSubtitleLinks {
  FlixQuestAPISubLinks.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);
}
