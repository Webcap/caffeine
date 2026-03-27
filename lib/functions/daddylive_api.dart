import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/models/live_tv.dart';
import 'package:caffiene/utils/constant.dart';

/// Maps ESPN sport labels to Daddylive channel name keywords (prefer first match).
const Map<String, List<String>> _sportToChannelKeywords = {
  'basketball': ['espn', 'nba', 'tnt', 'abc'],
  'american football': ['espn', 'nfl', 'cbs', 'fox', 'nbc'],
  'baseball': ['espn', 'mlb', 'fox', 'tbs'],
  'ice hockey': ['espn', 'nhl', 'nbc'],
  'hockey': ['espn', 'nhl', 'sky sports'],
  'soccer': ['sky sports', 'bein', 'espn', 'nbcsn', 'peacock'],
  'football': ['sky sports', 'bein', 'espn', 'nbcsn'],
  'ufc': ['espn', 'ppv', 'fight'],
  'mma': ['espn', 'ppv', 'fight'],
  'boxing': ['espn', 'ppv', 'dazn', 'showtime'],
  'tennis': ['espn', 'tennis'],
  'golf': ['espn', 'golf', 'nbc'],
  'nascar': ['espn', 'nascar', 'fox'],
  'f1': ['sky sports', 'f1', 'espn'],
  'formula 1': ['sky sports', 'f1', 'espn'],
  'rugby': ['sky sports', 'rugby'],
  'cricket': ['sky sports', 'espn', 'cricket'],
};

/// Cached live channels response (base_url, trailing_url, channels).
DaddyliveLiveResponse? _cachedLive;
DateTime? _cachedLiveAt;
const _cacheTtl = Duration(minutes: 10);

class DaddyliveLiveResponse {
  DaddyliveLiveResponse({
    required this.baseUrl,
    required this.trailingUrl,
    required this.referrer,
    required this.userAgent,
    required this.channels,
  });

  final String baseUrl;
  final String trailingUrl;
  final String referrer;
  final String userAgent;
  final List<Channel> channels;

  factory DaddyliveLiveResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['channels'];
    final list = raw is List
        ? raw
            .map((e) => e is Map<String, dynamic> ? Channel.fromJson(e) : null)
            .whereType<Channel>()
            .toList()
        : <Channel>[];
    return DaddyliveLiveResponse(
      baseUrl: json['base_url']?.toString() ?? '',
      trailingUrl: json['trailing_url']?.toString() ?? '',
      referrer: json['referrer']?.toString() ?? '',
      userAgent: json['user_agent']?.toString() ?? '',
      channels: list,
    );
  }
}

/// Fetches Daddylive 24/7 channels from our API (direct HLS, no ads).
Future<DaddyliveLiveResponse?> fetchDaddyliveChannels() async {
  if (_cachedLive != null &&
      _cachedLiveAt != null &&
      DateTime.now().difference(_cachedLiveAt!) < _cacheTtl) {
    return _cachedLive;
  }
  try {
    final url = Endpoints.getIPTVEndpoint(caffeineApiUrl);
    debugPrint('[Daddylive] GET $url');
    final res =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) return _cachedLive;
    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) return null;
    _cachedLive = DaddyliveLiveResponse.fromJson(decoded);
    _cachedLiveAt = DateTime.now();
    debugPrint('[Daddylive] Loaded ${_cachedLive!.channels.length} channels');
    return _cachedLive;
  } catch (e) {
    debugPrint('[Daddylive] fetchChannels failed: $e');
    return _cachedLive;
  }
}

/// Picks best channel for a sport from 24/7 list. Returns channel ID or null.
int? pickChannelForSport(DaddyliveLiveResponse live, String sport) {
  final s = sport.toLowerCase().trim();
  final keywords =
      _sportToChannelKeywords[s] ?? _sportToChannelKeywords['football'] ?? [];
  if (keywords.isEmpty) return null;
  final lower = keywords.map((k) => k.toLowerCase()).toList();
  for (final kw in lower) {
    for (final ch in live.channels) {
      final name = (ch.channelName ?? '').toLowerCase();
      if (name.contains(kw)) return ch.channelId;
    }
  }
  return null;
}

/// Builds direct HLS URL for a 24/7 channel (no ads).
String buildDirectHls(DaddyliveLiveResponse live, int channelId) {
  final base = live.baseUrl.endsWith('/') ? live.baseUrl : '${live.baseUrl}/';
  final trail = live.trailingUrl.startsWith('/')
      ? live.trailingUrl
      : '/${live.trailingUrl}';
  return '$base$channelId$trail';
}

/// Result of resolving a Daddylive stream for a sport.
class DaddyliveStreamResult {
  const DaddyliveStreamResult({
    required this.hls,
    this.referrer = 'https://lewblivehdplay.ru/',
    this.userAgent =
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4.1 Mobile/15E148 Safari/604.1',
  });
  final String hls;
  final String referrer;
  final String userAgent;
}

/// Returns direct HLS URL for the sport, or null if no matching channel.
/// Uses 24/7 channels – ad-free streams.
Future<DaddyliveStreamResult?> getDaddyliveHlsForSport(String sport) async {
  final live = await fetchDaddyliveChannels();
  if (live == null || live.channels.isEmpty) return null;
  final id = pickChannelForSport(live, sport);
  if (id == null) return null;
  final hls = buildDirectHls(live, id);
  debugPrint('[Daddylive] Sport "$sport" -> channel $id -> direct HLS');
  return DaddyliveStreamResult(
    hls: hls,
    referrer: live.referrer,
    userAgent: live.userAgent,
  );
}

/// Extracts HLS from a Daddylive embed or watch page via our API.
Future<String?> extractHlsFromDaddyliveEmbed(String embedUrl) async {
  if (embedUrl.trim().isEmpty) return null;
  try {
    final url = Endpoints.getDaddyliveExtractHls(caffeineApiUrl, embedUrl);
    debugPrint('[Daddylive] Extracting HLS from embed via API');
    final res =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) return null;
    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) return null;
    final hls = decoded['hls']?.toString();
    if (hls != null && hls.isNotEmpty) {
      debugPrint('[Daddylive] Extracted HLS OK');
      return hls;
    }
    return null;
  } catch (e) {
    debugPrint('[Daddylive] extractHls failed: $e');
    return null;
  }
}
