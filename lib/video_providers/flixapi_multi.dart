/// FlixAPI Multi-provider response model (vixsrc, pstream, showbox)
class FlixAPIMultiResponse {
  late bool success;
  String? provider;
  FlixAPIMultiMedia? media;
  List<FlixAPIMultiLink>? links;

  FlixAPIMultiResponse({
    this.success = false,
    this.provider,
    this.media,
    this.links,
  });

  FlixAPIMultiResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    provider = json['provider'];
    media = json['media'] != null
        ? FlixAPIMultiMedia.fromJson(json['media'] as Map<String, dynamic>)
        : null;
    if (json['links'] != null) {
      links = [];
      for (final v in json['links'] as List) {
        links!.add(FlixAPIMultiLink.fromJson(v as Map<String, dynamic>));
      }
    }
  }
}

class FlixAPIMultiMedia {
  String? type;
  String? title;
  int? releaseYear;
  String? tmdbId;

  FlixAPIMultiMedia.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    title = json['title'];
    releaseYear = json['releaseYear'];
    tmdbId = json['tmdbId']?.toString();
  }
}

class FlixAPIMultiLink {
  String? server;
  String? url;
  bool? isM3U8;
  String? quality;
  List<FlixAPIMultiSubtitle>? subtitles;
  Map<String, String>? headers;

  FlixAPIMultiLink.fromJson(Map<String, dynamic> json) {
    server = json['server'];
    url = json['url'];
    isM3U8 = json['isM3U8'];
    quality = json['quality'];
    if (json.containsKey('headers') && json['headers'] != null) {
      headers = Map<String, String>.from(json['headers'] as Map);
    }
    if (json['subtitles'] != null) {
      subtitles = [];
      for (final v in json['subtitles'] as List) {
        subtitles!
            .add(FlixAPIMultiSubtitle.fromJson(v as Map<String, dynamic>));
      }
    }
  }
}

class FlixAPIMultiSubtitle {
  String? file;
  String? label;
  String? kind;
  bool? isDefault;

  FlixAPIMultiSubtitle.fromJson(Map<String, dynamic> json) {
    file = json['file'];
    label = json['label'];
    kind = json['kind'];
    isDefault = json['default'] ?? false;
  }
}
