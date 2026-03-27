class RegularVideoLinks {
  String? url;
  String? quality;
  bool? isM3U8;
  Map<String, String>? headers;

  RegularVideoLinks({this.url, this.quality = 'unknown quality', this.isM3U8, this.headers});

  RegularVideoLinks.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    if (json.containsKey('quality')) {
      quality = json['quality'];
    } else {
      quality = 'unknown quality';
    }
    isM3U8 = json['isM3U8'];
    if (json.containsKey('headers') && json['headers'] != null) {
      headers = Map<String, String>.from(json['headers'] as Map);
    }
  }
}

class RegularSubtitleLinks {
  String? url;
  String? language;

  RegularSubtitleLinks({this.url, this.language});

  RegularSubtitleLinks.fromJson(Map<String, dynamic> json) {
    url = json['url'] ?? json['file'];
    language = json['lang'] ?? json['label'];
  }
}
