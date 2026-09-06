import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Streamed.pk REST API – matches and streams. No auth required.
/// https://streamed.pk/docs

const String _streamedBase = 'https://streamed.pk';

/// Maps ESPN/sport display name to Streamed API sport ID.
String? sportToStreamedId(String? sport) {
  if (sport == null || sport.isEmpty) return null;
  final s = sport.toLowerCase().trim();
  const map = <String, String>{
    'basketball': 'basketball',
    'baseball': 'baseball',
    'american football': 'american-football',
    'nfl': 'american-football',
    'ncaaf': 'american-football',
    'college football': 'american-football',
    'ice hockey': 'hockey',
    'hockey': 'hockey',
    'soccer': 'football',
    'football': 'football',
    'ufc': 'fight',
    'mma': 'fight',
    'boxing': 'fight',
    'tennis': 'tennis',
    'golf': 'golf',
    'nascar': 'motor-sports',
    'f1': 'motor-sports',
    'formula 1': 'motor-sports',
    'rugby': 'rugby',
    'cricket': 'cricket',
    'darts': 'darts',
  };
  return map[s];
}

class StreamedMatch {
  final String id;
  final String title;
  final String category;
  final int? date;
  final String? poster;
  final bool popular;
  final StreamedTeams? teams;
  final List<StreamedSource> sources;

  StreamedMatch({
    required this.id,
    required this.title,
    required this.category,
    this.date,
    this.poster,
    this.popular = false,
    this.teams,
    required this.sources,
  });

  factory StreamedMatch.fromJson(Map<String, dynamic> json) {
    final raw = json['sources'];
    final list = raw is List
        ? raw
            .map((e) =>
                e is Map<String, dynamic> ? StreamedSource.fromJson(e) : null)
            .whereType<StreamedSource>()
            .toList()
        : <StreamedSource>[];
    StreamedTeams? teams;
    final t = json['teams'];
    if (t is Map<String, dynamic>) {
      teams = StreamedTeams.fromJson(t);
    }
    return StreamedMatch(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      date: json['date'] is int ? json['date'] as int : null,
      poster: json['poster']?.toString(),
      popular: json['popular'] == true,
      teams: teams,
      sources: list,
    );
  }

  String? get homeBadge => teams?.home?.badge;
  String? get awayBadge => teams?.away?.badge;
}

class StreamedTeams {
  final StreamedTeam? home;
  final StreamedTeam? away;

  StreamedTeams({this.home, this.away});

  factory StreamedTeams.fromJson(Map<String, dynamic> json) {
    StreamedTeam? home;
    StreamedTeam? away;
    final h = json['home'];
    final a = json['away'];
    if (h is Map<String, dynamic>) home = StreamedTeam.fromJson(h);
    if (a is Map<String, dynamic>) away = StreamedTeam.fromJson(a);
    return StreamedTeams(home: home, away: away);
  }
}

class StreamedTeam {
  final String name;
  final String badge;

  StreamedTeam({required this.name, required this.badge});

  factory StreamedTeam.fromJson(Map<String, dynamic> json) {
    return StreamedTeam(
      name: json['name']?.toString() ?? '',
      badge: json['badge']?.toString() ?? '',
    );
  }
}

class StreamedSource {
  final String source;
  final String id;

  StreamedSource({required this.source, required this.id});

  factory StreamedSource.fromJson(Map<String, dynamic> json) {
    return StreamedSource(
      source: json['source']?.toString() ?? '',
      id: json['id']?.toString() ?? '',
    );
  }
}

class StreamedStream {
  final String id;
  final int streamNo;
  final String language;
  final bool hd;
  final String embedUrl;
  final String source;

  StreamedStream({
    required this.id,
    required this.streamNo,
    required this.language,
    required this.hd,
    required this.embedUrl,
    required this.source,
  });

  factory StreamedStream.fromJson(Map<String, dynamic> json) {
    return StreamedStream(
      id: json['id']?.toString() ?? '',
      streamNo: json['streamNo'] is int ? json['streamNo'] as int : 0,
      language: json['language']?.toString() ?? 'English',
      hd: json['hd'] == true,
      embedUrl: json['embedUrl']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
    );
  }
}

/// Fetch matches for a sport (e.g. basketball, football, baseball).
Future<List<StreamedMatch>> fetchStreamedMatches(String sportId) async {
  final url = '$_streamedBase/api/matches/$sportId';
  debugPrint('[Streamed] GET $url');
  final res =
      await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
  if (res.statusCode != 200) {
    debugPrint('[Streamed] matches -> HTTP ${res.statusCode}');
    return [];
  }
  final raw = jsonDecode(res.body);
  if (raw is! List) return [];
  return raw
      .map((e) => e is Map<String, dynamic> ? StreamedMatch.fromJson(e) : null)
      .whereType<StreamedMatch>()
      .toList();
}

/// Fetch live matches (all sports).
Future<List<StreamedMatch>> fetchStreamedLiveMatches() async {
  const url = '$_streamedBase/api/matches/live';
  debugPrint('[Streamed] GET $url');
  final res =
      await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
  if (res.statusCode != 200) {
    debugPrint('[Streamed] live -> HTTP ${res.statusCode}');
    return [];
  }
  final raw = jsonDecode(res.body);
  if (raw is! List) return [];
  return raw
      .map((e) => e is Map<String, dynamic> ? StreamedMatch.fromJson(e) : null)
      .whereType<StreamedMatch>()
      .toList();
}

/// Fetch an embed page and try to extract the HLS (m3u8) stream URL.
/// Returns null if not found. Used to skip ads and play the direct stream.
Future<String?> extractHlsFromEmbedUrl(String embedUrl) async {
  try {
    debugPrint('[Streamed] Fetching embed page to extract HLS: $embedUrl');
    final res = await http.get(
      Uri.parse(embedUrl),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml',
        'Referer': 'https://streamed.pk/',
      },
    ).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) return null;
    final html = res.body;
    // Match m3u8 URLs in HTML/JS (common in player configs, src, loadSource, etc.)
    final m3u8Regex = RegExp(
      r'''https?://[^\s"'<>)\]]+\.m3u8[^\s"'<>)\]]*''',
      caseSensitive: false,
    );
    final matches = m3u8Regex.allMatches(html);
    for (final m in matches) {
      var found = m.group(0)!;
      found = found.replaceAll(RegExp(r'["\x27]+$'), '');
      if (found.length > 20 &&
          !found.toLowerCase().contains('/ad') &&
          !found.toLowerCase().contains('ad-')) {
        debugPrint(
            '[Streamed] Extracted HLS: ${found.length > 80 ? "${found.substring(0, 80)}..." : found}');
        return found;
      }
    }
    debugPrint('[Streamed] No HLS URL found in embed page');
    return null;
  } catch (e) {
    debugPrint('[Streamed] extractHls failed: $e');
    return null;
  }
}

/// Fetches an embed page and returns the first iframe src pointing to pooembed.eu.
/// Loading that URL directly in the WebView lets our JS run in the same origin as the player.
Future<String?> extractPooembedUrlFromEmbed(String embedUrl) async {
  try {
    final res = await http.get(
      Uri.parse(embedUrl),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml',
        'Referer': 'https://streamed.pk/',
      },
    ).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) return null;
    final html = res.body;
    final iframeRegex = RegExp(
      r'<iframe[^>]+src\s*=\s*["](https?://[^"]*pooembed\.eu[^"]*)["]',
      caseSensitive: false,
    );
    final iframeRegexSingle = RegExp(
      r"<iframe[^>]+src\s*=\s*['](https?://[^']*pooembed\.eu[^']*)[']",
      caseSensitive: false,
    );
    var match = iframeRegex.firstMatch(html);
    match ??= iframeRegexSingle.firstMatch(html);
    if (match != null) {
      final url = match.group(1)!.replaceAll(RegExp(r'&amp;'), '&');
      debugPrint('[Streamed] Extracted pooembed URL for direct load');
      return url;
    }
    return null;
  } catch (e) {
    debugPrint('[Streamed] extractPooembed failed: $e');
    return null;
  }
}

/// Fetch streams for a match source.
Future<List<StreamedStream>> fetchStreamedStreams(
    String source, String id) async {
  final url = '$_streamedBase/api/stream/$source/$id';
  debugPrint('[Streamed] GET $url');
  final res =
      await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
  if (res.statusCode != 200) {
    debugPrint('[Streamed] streams -> HTTP ${res.statusCode}');
    return [];
  }
  final raw = jsonDecode(res.body);
  if (raw is! List) return [];
  return raw
      .map((e) => e is Map<String, dynamic> ? StreamedStream.fromJson(e) : null)
      .whereType<StreamedStream>()
      .where((s) => s.embedUrl.isNotEmpty)
      .toList();
}
