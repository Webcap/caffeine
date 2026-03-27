import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

const String _ppvStreamsUrl = 'https://old.ppv.to/api/streams';

/// Result from PPV streams API – embed URL (pooembed.eu) for WebView or HLS extraction.
class PpvStreamResult {
  const PpvStreamResult({
    required this.embedUrl,
    this.posterUrl,
    this.streamName,
  });
  final String embedUrl;
  final String? posterUrl;
  final String? streamName;
}

/// Cached response (API recommends caching; poll ~1 min).
Map<String, dynamic>? _cachedResponse;
DateTime? _cachedAt;
const _cacheTtl = Duration(minutes: 2);

/// Fetches all streams from old.ppv.to API.
Future<Map<String, dynamic>?> _fetchStreams() async {
  if (_cachedResponse != null &&
      _cachedAt != null &&
      DateTime.now().difference(_cachedAt!) < _cacheTtl) {
    return _cachedResponse;
  }
  try {
    debugPrint('[PPV] GET $_ppvStreamsUrl');
    final res = await http
        .get(Uri.parse(_ppvStreamsUrl))
        .timeout(const Duration(seconds: 25));
    if (res.statusCode != 200) return _cachedResponse;
    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic> || decoded['success'] != true)
      return null;
    _cachedResponse = decoded;
    _cachedAt = DateTime.now();
    return _cachedResponse;
  } catch (e) {
    debugPrint('[PPV] fetch failed: $e');
    return _cachedResponse;
  }
}

/// Collects all stream objects from the API response.
List<Map<String, dynamic>> _collectStreams(Map<String, dynamic> data) {
  final streams = <Map<String, dynamic>>[];
  final raw = data['streams'];
  if (raw is! List) return streams;
  for (final cat in raw) {
    if (cat is! Map<String, dynamic>) continue;
    final list = cat['streams'];
    if (list is! List) continue;
    for (final s in list) {
      if (s is Map<String, dynamic>) streams.add(s);
    }
  }
  return streams;
}

/// Normalizes event title for matching (lowercase, collapse spaces, handle "at" vs "vs").
String _normalizeTitle(String s) {
  String t = s
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r'\s+at\s+'), ' vs ')
      .replaceAll(RegExp(r'\s+vs\.?\s+'), ' vs ')
      .trim();
  return t;
}

/// Checks if normalized ESPN title matches PPV stream name (word overlap).
bool _titlesMatch(String espnNorm, String ppvName) {
  final ppvNorm = _normalizeTitle(ppvName);
  if (espnNorm == ppvNorm) return true;
  final espnWords = espnNorm.split(RegExp(r'\s+vs\s+'));
  if (espnWords.length != 2) return false;
  final left =
      espnWords[0].split(RegExp(r'\s+')).where((w) => w.length > 1).toSet();
  final right =
      espnWords[1].split(RegExp(r'\s+')).where((w) => w.length > 1).toSet();
  final ppvParts = ppvNorm.split(RegExp(r'\s+vs\.?\s+'));
  if (ppvParts.length != 2) return false;
  final ppvLeft =
      ppvParts[0].split(RegExp(r'\s+')).where((w) => w.length > 1).toSet();
  final ppvRight =
      ppvParts[1].split(RegExp(r'\s+')).where((w) => w.length > 1).toSet();
  final leftOverlap = left.intersection(ppvLeft).isNotEmpty;
  final rightOverlap = right.intersection(ppvRight).isNotEmpty;
  if (leftOverlap && rightOverlap) return true;
  final leftRight = left.intersection(ppvRight).isNotEmpty;
  final rightLeft = right.intersection(ppvLeft).isNotEmpty;
  return leftRight && rightLeft;
}

/// Finds best matching PPV stream for an ESPN event.
Future<PpvStreamResult?> findPpvStream(String espnEventName,
    [String? sportFilter]) async {
  final data = await _fetchStreams();
  if (data == null) return null;
  final streams = _collectStreams(data);
  final espnNorm = _normalizeTitle(espnEventName);
  Map<String, dynamic>? best;
  for (final s in streams) {
    final name = s['name']?.toString() ?? '';
    if (name.isEmpty) continue;
    if (sportFilter != null && sportFilter.isNotEmpty) {
      final cat = (s['category_name'] ?? '').toString().toLowerCase();
      final sport = sportFilter.toLowerCase();
      if (!cat.contains(sport) && !_sportMatches(sport, cat)) {
        continue;
      }
    }
    final iframe = s['iframe']?.toString() ?? '';
    if (iframe.isEmpty || !iframe.startsWith('http')) continue;
    if (_titlesMatch(espnNorm, name)) {
      best = s;
      break;
    }
  }
  if (best == null) {
    for (final s in streams) {
      final name = s['name']?.toString() ?? '';
      if (name.isEmpty) continue;
      final iframe = s['iframe']?.toString() ?? '';
      if (iframe.isEmpty || !iframe.startsWith('http')) continue;
      final a =
          espnNorm.split(RegExp(r'\s+')).where((w) => w.length > 1).toSet();
      final b = _normalizeTitle(name)
          .split(RegExp(r'\s+'))
          .where((w) => w.length > 1)
          .toSet();
      if (a.intersection(b).length >= 2) {
        best = s;
        break;
      }
    }
  }
  if (best == null) return null;
  final embed = best['iframe']?.toString() ?? '';
  return PpvStreamResult(
    embedUrl: embed,
    posterUrl: best['poster']?.toString(),
    streamName: best['name']?.toString(),
  );
}

bool _sportMatches(String sport, String category) {
  final m = <String, List<String>>{
    'basketball': ['basketball', 'nba', 'ncaab', 'cbb'],
    'football': ['football', 'soccer'],
    'american football': ['football', 'nfl'],
    'ice hockey': ['hockey', 'ice hockey', 'nhl'],
    'hockey': ['hockey', 'ice hockey', 'nhl'],
    'baseball': ['baseball', 'mlb'],
    'soccer': ['football', 'soccer'],
  };
  final keywords = m[sport] ?? [sport];
  final cat = category.toLowerCase();
  return keywords.any((k) => cat.contains(k));
}
