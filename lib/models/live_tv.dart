/// Streameast-style live event from GET /streameast/events
class StreameastEvent {
  final String id;
  final String title;
  final String url;
  final String? sport;
  final String? logoUrl;
  final List<dynamic>? sources;

  StreameastEvent({
    required this.id,
    required this.title,
    required this.url,
    this.sport,
    this.logoUrl,
    this.sources,
  });

  factory StreameastEvent.fromJson(Map<String, dynamic> json) {
    return StreameastEvent(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      sport: json['sport']?.toString(),
      logoUrl: json['logo_url']?.toString() ?? json['logoUrl']?.toString(),
      sources: json['sources'] as List<dynamic>?,
    );
  }
}

/// Response from GET /streameast/events
class StreameastEventsResponse {
  final bool success;
  final String? baseUrl;
  final List<StreameastEvent> events;

  StreameastEventsResponse({
    required this.success,
    this.baseUrl,
    required this.events,
  });

  factory StreameastEventsResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['events'];
    final list = raw is List
        ? raw
            .map((e) =>
                e is Map<String, dynamic> ? StreameastEvent.fromJson(e) : null)
            .whereType<StreameastEvent>()
            .toList()
        : <StreameastEvent>[];
    return StreameastEventsResponse(
      success: json['success'] == true,
      baseUrl: json['base_url']?.toString(),
      events: list,
    );
  }
}

/// Response from GET /streameast/stream?url=...
class StreameastStreamResponse {
  final bool success;
  final String? url;
  final int count;
  final List<String> links;

  StreameastStreamResponse({
    required this.success,
    this.url,
    required this.count,
    required this.links,
  });

  factory StreameastStreamResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['links'];
    final list = raw is List
        ? raw.map((e) => e?.toString()).whereType<String>().toList()
        : <String>[];
    return StreameastStreamResponse(
      success: json['success'] == true,
      url: json['url']?.toString(),
      count: json['count'] is int ? json['count'] as int : list.length,
      links: list,
    );
  }
}

class FeaturedEvent {
  final String title;
  final String thumbnailUrl;
  final String videoUrl;
  final String? sport;
  final String? referrer;

  FeaturedEvent({
    required this.title,
    required this.thumbnailUrl,
    required this.videoUrl,
    this.sport,
    this.referrer,
  });
}
