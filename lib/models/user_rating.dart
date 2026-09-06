class UserRating {
  final String mediaType;
  final int mediaId;
  final int? seasonNum;
  final int? episodeNum;
  final int rating;
  final DateTime? updatedAt;

  UserRating({
    required this.mediaType,
    required this.mediaId,
    this.seasonNum,
    this.episodeNum,
    required this.rating,
    this.updatedAt,
  });

  factory UserRating.fromJson(Map<String, dynamic> json) {
    return UserRating(
      mediaType: json['media_type']?.toString() ?? '',
      mediaId: json['media_id'] is int
          ? json['media_id'] as int
          : int.tryParse(json['media_id']?.toString() ?? '0') ?? 0,
      seasonNum: json['season_num'] != null
          ? (json['season_num'] as num).toInt()
          : null,
      episodeNum: json['episode_num'] != null
          ? (json['episode_num'] as num).toInt()
          : null,
      rating: json['rating'] is int
          ? json['rating'] as int
          : int.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'media_type': mediaType,
      'media_id': mediaId,
      if (seasonNum != null) 'season_num': seasonNum,
      if (episodeNum != null) 'episode_num': episodeNum,
      'rating': rating,
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  String get compositeKey {
    if (mediaType == 'tv' && seasonNum != null && episodeNum != null) {
      return '$mediaType:$mediaId:$seasonNum:$episodeNum';
    }
    return '$mediaType:$mediaId';
  }

  static String makeKey(String mediaType, int mediaId,
      {int? seasonNum, int? episodeNum}) {
    if (mediaType == 'tv' && seasonNum != null && episodeNum != null) {
      return '$mediaType:$mediaId:$seasonNum:$episodeNum';
    }
    return '$mediaType:$mediaId';
  }
}
