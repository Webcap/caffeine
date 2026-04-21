import 'package:caffiene/video_providers/regularVideoLinks.dart';
import 'package:caffiene/services/player/caffeine_player_controller.dart';

class VideoUtils {
  /// Returns true if the URL likely points to an HLS stream (m3u8/playlist).
  /// Used to set videoFormat hint so ExoPlayer uses HlsMediaSource instead of
  /// progressive extractors, which fail on HLS URLs without .m3u8 extension.
  static bool looksLikeHls(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('m3u8') || lower.contains('playlist')) return true;
    final uri = Uri.tryParse(url);
    final path = uri?.path ?? '';
    if (path.endsWith('.mp4') ||
        path.endsWith('.mkv') ||
        path.endsWith('.webm') ||
        path.endsWith('.avi')) {
      return false;
    }
    return true;
  }

  /// Convert video links to a map format for the player
  static Map<String, String> convertVideoLinksToMap(
      List<RegularVideoLinks> vids) {
    final Map<String, String> videos = {};
    for (int k = 0; k < vids.length; k++) {
      final quality = vids[k].quality ?? 'unknown quality';
      final url = vids[k].url ?? '';
      if (quality == 'unknown quality') {
        videos['$quality $k'] = url;
      } else {
        videos[quality] = url;
      }
    }
    return videos;
  }

  /// Process VTT file timestamps to fix formatting issues
  static String processVttFileTimestamps(String vttContent) {
    if (vttContent.trim().isEmpty) return '';
    
    final lines = vttContent.split('\n');
    final processedLines = <String>[];
    
    if (!vttContent.trim().startsWith('WEBVTT')) {
      processedLines.add('WEBVTT\n');
    }

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();
      if (trimmed.contains('-->') && trimmed.length == 23) {
        // MM:SS.mmm --> MM:SS.mmm (23 chars)
        // Convert to HH:MM:SS.mmm --> HH:MM:SS.mmm (29 chars)
        final startTime = trimmed.substring(0, 9);
        final endTime = trimmed.substring(14);
        processedLines.add('00:$startTime --> 00:$endTime');
      } else {
        processedLines.add(line);
      }
    }

    return processedLines.join('\n');
  }

  /// Parse and create subtitle tracks from subtitle links
  static Future<List<CaffeinePlayerSubtitlesSource>> parseSubtitles({
    required List<RegularSubtitleLinks> subtitles,
    required String defaultLanguage,
    required bool fetchAllLanguages,
    required Future<String> Function(String) getVttContent,
  }) async {
    final List<CaffeinePlayerSubtitlesSource> subs = [];

    if (subtitles.isEmpty) {
      return subs;
    }

    // 1. Identify which subtitles match the preferred language
    final preferredIndices = <int>{};
    int? bestPreferredIndex;
    for (int i = 0; i < subtitles.length; i++) {
      final lang = (subtitles[i].language ?? '').toLowerCase();
      if (lang.startsWith(defaultLanguage.toLowerCase()) ||
          lang == defaultLanguage.toLowerCase()) {
        preferredIndices.add(i);
        bestPreferredIndex ??= i;
      }
    }

    // 2. If no preferred language found, try to find English as fallback if it wasn't the default
    if (preferredIndices.isEmpty &&
        defaultLanguage.toLowerCase() != 'english') {
      for (int i = 0; i < subtitles.length; i++) {
        if (_isDefaultEnglish(subtitles[i].language ?? '')) {
          preferredIndices.add(i);
          bestPreferredIndex ??= i;
          break; // Just one fallback is enough
        }
      }
    }

    // 3. Fallback to the first one if still nothing
    if (preferredIndices.isEmpty) {
      preferredIndices.add(0);
      bestPreferredIndex = 0;
    }

    // 4. Determine which subtitles to fetch
    final List<int> indicesToFetch = [];
    if (fetchAllLanguages) {
      indicesToFetch.addAll(Iterable.generate(subtitles.length));
    } else {
      // Just fetch the preferred ones (or the fallback)
      indicesToFetch.addAll(preferredIndices);
    }

    // 5. Fetch and process
    for (final i in indicesToFetch) {
      try {
        final url = subtitles[i].url ?? '';
        if (url.isEmpty) continue;

        final content = await getVttContent(url);
        final isDefault = i == bestPreferredIndex;

        subs.add(
          CaffeinePlayerSubtitlesSource(
            name: subtitles[i].language ?? 'Unknown',
            data: url.toLowerCase().endsWith('srt')
                ? content
                : processVttFileTimestamps(content),
            isDefault: isDefault,
          ),
        );
      } catch (e) {
        continue;
      }
    }

    return subs;
  }

  static bool _isDefaultEnglish(String language) {
    return language == 'English' ||
        language == 'English - English' ||
        language == 'English - SDH' ||
        language == 'English 1' ||
        language == 'English - English [CC]' ||
        language == 'en';
  }

  /// Reverse video quality map for player (highest quality first)
  static Map<String, String> reverseVideoQualityMap(
      Map<String, String> videos) {
    final List<MapEntry<String, String>> reversedVideoList =
        videos.entries.toList().reversed.toList();
    return Map.fromEntries(reversedVideoList);
  }

  /// Extract headers from a list of video links
  static Map<String, String>? extractHeaders(List<RegularVideoLinks> vids) {
    for (var vid in vids) {
      if (vid.headers != null && vid.headers!.isNotEmpty) {
        return vid.headers;
      }
    }
    return null;
  }
}
