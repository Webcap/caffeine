import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

const _ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36';

class _Variant {
  final String url;
  final int bandwidth;
  final String? audioGroup;
  _Variant(this.url, this.bandwidth, this.audioGroup);
}

/// Fetches the m3u8 playlist tree on the phone, rewrites every URL so that
/// playlist files are served from a tiny local HTTPS-less server while video
/// segments point directly at the CDN (which doesn't check headers).
///
/// Flow:
///  1. Phone fetches master → picks best quality → fetches sub-playlist.
///  2. Inspects segment URLs. If they're on a different host (CDN), the
///     Chromecast can grab them directly.
///  3. A local server hands back the pre-fetched & rewritten playlists
///     under clean paths (`/master.m3u8`, `/0.m3u8`, …).
///  4. The Chromecast LOADs `http://<phone>:<port>/master.m3u8`.
class CastStreamServer {
  HttpServer? _server;
  String? _localIp;
  int? _port;

  /// path → content (pre-fetched & rewritten playlists).
  final Map<String, String> _files = {};

  /// path → raw bytes (proxied encryption keys, init segments, etc.).
  final Map<String, List<int>> _rawFiles = {};

  /// local path → remote CDN URL (for on-the-fly segment proxying).
  final Map<String, String> _proxyMap = {};

  /// Persistent client for proxying segment requests.
  HttpClient? _proxyClient;

  final Map<String, String> _globalHeaders = {};

  bool get isRunning => _server != null;
  String? get baseUrl =>
      _localIp != null && _port != null ? 'http://$_localIp:$_port' : null;

  // ── public API ───────────────────────────────────────────────────────────

  /// Prepares the stream for casting: fetches the playlist tree, rewrites
  /// URLs, starts the local server, and returns the URL to LOAD on the
  /// Chromecast.
  /// Safely closes the response; catches SocketException when client has
  /// already disconnected (e.g. Chromecast stopped, network drop).
  /// Resolves [path] against [base], preserving query parameters if the
  /// host is the same (essential for proxy-based CDNs).
  String _resolve(Uri base, String path) {
    var resolved = base.resolve(path);
    if (resolved.query.isEmpty && base.query.isNotEmpty) {
      if (resolved.host == base.host) {
        resolved = resolved.replace(queryParameters: base.queryParameters);
      }
    }
    return resolved.toString();
  }

  Future<void> _safeCloseResponse(HttpResponse res) async {
    try {
      await res.close();
    } on SocketException {
      debugPrint('[CastStream] Client disconnected (broken pipe)');
    }
  }

  Future<String?> prepare(String masterUrl, {Map<String, String>? overrideHeaders}) async {
    _globalHeaders.clear();
    // Prioritize override headers (normalized to lowercase)
    if (overrideHeaders != null) {
      overrideHeaders.forEach((k, v) {
        _globalHeaders[k.toLowerCase()] = v;
      });
    }

    // Add secondary headers from URL query if they don't conflict
    try {
      final uri = Uri.tryParse(masterUrl);
      if (uri != null && uri.queryParameters.containsKey('headers')) {
        final hStr = uri.queryParameters['headers'];
        if (hStr != null && hStr.isNotEmpty) {
          final parsed = jsonDecode(hStr) as Map<String, dynamic>;
          for (final entry in parsed.entries) {
            final lowerKey = entry.key.toLowerCase();
            if (!_globalHeaders.containsKey(lowerKey)) {
              _globalHeaders[lowerKey] = entry.value.toString();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[CastStream] Error parsing headers: $e');
    }
    debugPrint('[CastStream] Normalized global headers: $_globalHeaders');

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);

    try {
      // ── 1. fetch & follow redirects on the master playlist ─────────────
      final resolvedMaster = await _followRedirects(client, masterUrl);
      final masterBody = await _fetchPlaylist(client, resolvedMaster);
      if (masterBody == null) {
        debugPrint('[CastStream] prepare: masterBody is null for $resolvedMaster');
        return null;
      }

      debugPrint(
          '[CastStream] Master playlist fetched (${masterBody.length} bytes)');

      final isMaster = masterBody.contains('#EXT-X-STREAM-INF');

      if (!isMaster) {
        return await _handleMediaPlaylist(
            client, masterBody, resolvedMaster, 'stream.m3u8');
      }

      // Log a preview so we can see if audio tracks are declared.
      final masterPreview = masterBody.split('\n').take(30).join('\n');
      debugPrint('[CastStream] Master preview:\n$masterPreview');

      // ── 2. pick best quality variant ──────────────────────────────────
      final best = _pickBestVariant(masterBody, resolvedMaster);
      if (best == null) {
        debugPrint('[CastStream] No streams found in master playlist');
        return null;
      }
      debugPrint('[CastStream] Best variant: bw=${best.bandwidth} '
          'audio=${best.audioGroup}');

      final resolvedVideo = await _followRedirects(client, best.url);
      final videoBody = await _fetchPlaylist(client, resolvedVideo);
      if (videoBody == null) {
        debugPrint('[CastStream] prepare: videoBody is null for $resolvedVideo');
        return null;
      }
      debugPrint('[CastStream] Video playlist fetched from $resolvedVideo');

      // ── 3. check for a separate audio track ───────────────────────────
      final masterBaseUri = Uri.parse(resolvedMaster);
      final audioUrl = best.audioGroup != null
          ? _findAudioUrl(masterBody, best.audioGroup!, masterBaseUri)
          : null;

      if (audioUrl != null) {
        debugPrint('[CastStream] Separate audio track: $audioUrl');

        final resolvedAudio = await _followRedirects(client, audioUrl);
        final audioBody = await _fetchPlaylist(client, resolvedAudio);

        // Process video playlist.
        await _handleMediaPlaylist(
            client, videoBody, resolvedVideo, 'video.m3u8');

        if (audioBody != null) {
          debugPrint('[CastStream] Audio playlist fetched from $resolvedAudio');
          await _handleMediaPlaylist(
              client, audioBody, resolvedAudio, 'audio.m3u8');
        }

        // Build a minimal master that references both.
        final localMaster = StringBuffer()
          ..writeln('#EXTM3U')
          ..writeln('#EXT-X-VERSION:3');

        if (audioBody != null) {
          localMaster.writeln('#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="a",'
              'DEFAULT=YES,AUTOSELECT=YES,URI="/audio.m3u8"');
          localMaster.writeln(
              '#EXT-X-STREAM-INF:BANDWIDTH=${best.bandwidth},AUDIO="a"');
        } else {
          localMaster.writeln('#EXT-X-STREAM-INF:BANDWIDTH=${best.bandwidth}');
        }
        localMaster.writeln('/video.m3u8');

        final masterContent = localMaster.toString();
        _files['/master.m3u8'] = masterContent;
        debugPrint('[CastStream] Local master:\n$masterContent');

        await _startServer();
        final castUrl = '$baseUrl/master.m3u8';
        debugPrint('[CastStream] Ready (video+audio) — cast URL: $castUrl');
        return castUrl;
      }

      // ── 4. no separate audio — serve video playlist directly ──────────
      debugPrint('[CastStream] No separate audio track');
      return await _handleMediaPlaylist(
          client, videoBody, resolvedVideo, 'stream.m3u8');
    } catch (e) {
      debugPrint('[CastStream] Error: $e');
      return null;
    } finally {
      client.close();
    }
  }

  /// Handles a media playlist: rewrites segment URLs to point at the CDN
  /// directly, proxies encryption keys / init segments that live on the
  /// restricted host, stores the rewritten playlist locally, and returns the
  /// local URL (or null if segments can't be accessed from the Chromecast).
  Future<String?> _handleMediaPlaylist(
    HttpClient client,
    String body,
    String playlistUrl,
    String localPath,
  ) async {
    final baseUri = Uri.parse(playlistUrl);
    final playlistHost = baseUri.host;
    final ns = localPath.replaceAll('.m3u8', '');

    // First pass – find the CDN host used by segments.
    String? segmentHost;
    for (final line in body.split('\n')) {
      final t = line.trim();
      if (t.isEmpty || t.startsWith('#')) continue;
      final abs = t.startsWith('http') ? t : _resolve(baseUri, t);
      segmentHost = Uri.parse(abs).host;
      break;
    }

    // Second pass – rewrite tags & proxy restricted resources.
    final buf = StringBuffer();
    String? firstSegmentUrl;
    var keyIdx = 0;
    var segIdx = 0;

    for (final line in body.split('\n')) {
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        buf.writeln();
      } else if (trimmed.startsWith('#')) {
        final uriMatch = _uriAttr.firstMatch(trimmed);
        if (uriMatch != null) {
          final rawUri = uriMatch.group(1)!;
          final absUri = rawUri.startsWith('http')
              ? rawUri
              : _resolve(baseUri, rawUri);
          final uriHost = Uri.parse(absUri).host;

          // Resource lives on the restricted playlist host → proxy it.
          if (segmentHost != null &&
              uriHost == playlistHost &&
              uriHost != segmentHost) {
            final proxyPath = '/key/$ns/$keyIdx';
            keyIdx++;
            final bytes = await _fetchRaw(client, absUri);
            if (bytes != null) {
              _rawFiles[proxyPath] = bytes;
              buf.writeln(
                  trimmed.replaceFirst('URI="$rawUri"', 'URI="$proxyPath"'));
              debugPrint(
                  '[CastStream] Proxied $absUri → $proxyPath (${bytes.length} B)');
            } else {
              buf.writeln(_rewriteUriAttrs(trimmed, baseUri));
            }
          } else {
            buf.writeln(_rewriteUriAttrs(trimmed, baseUri));
          }
        } else {
          buf.writeln(trimmed);
        }
      } else {
        final absolute = trimmed.startsWith('http')
            ? trimmed
            : _resolve(baseUri, trimmed);
        firstSegmentUrl ??= absolute;
        final segPath = '/seg/$ns/$segIdx';
        segIdx++;
        _proxyMap[segPath] = absolute;
        buf.writeln(segPath);
      }
    }

    if (firstSegmentUrl == null) {
      debugPrint('[CastStream] No segments found in media playlist');
      return null;
    }

    final segHost = Uri.parse(firstSegmentUrl).host;
    debugPrint('[CastStream] Playlist host: $playlistHost');
    debugPrint('[CastStream] Segment host:  $segHost');
    debugPrint('[CastStream] First segment:  $firstSegmentUrl');

    final segOk = await _probe(client, firstSegmentUrl);
    debugPrint('[CastStream] Segment probe ${segOk ? 'OK' : 'FAILED'}');

    final playlistContent = buf.toString();
    _files['/$localPath'] = playlistContent;

    // Log a preview so we can verify the rewritten playlist.
    final preview = playlistContent.split('\n').take(20).join('\n');
    debugPrint('[CastStream] Playlist preview:\n$preview');

    await _startServer();
    return '$baseUrl/$localPath';
  }

  // ── playlist helpers ─────────────────────────────────────────────────────

  _Variant? _pickBestVariant(String playlist, String baseUrl) {
    final baseUri = Uri.parse(baseUrl);
    final lines = playlist.split('\n');
    _Variant? best;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (!line.startsWith('#EXT-X-STREAM-INF')) continue;

      final bw = RegExp(r'BANDWIDTH=(\d+)').firstMatch(line);
      final bandwidth = bw != null ? int.parse(bw.group(1)!) : 0;
      final ag = RegExp(r'AUDIO="([^"]+)"').firstMatch(line);

      for (var j = i + 1; j < lines.length; j++) {
        final u = lines[j].trim();
        if (u.isEmpty || u.startsWith('#')) continue;
        if (best == null || bandwidth > best.bandwidth) {
          best = _Variant(
            u.startsWith('http') ? u : _resolve(baseUri, u),
            bandwidth,
            ag?.group(1),
          );
        }
        break;
      }
    }
    return best;
  }

  /// Finds the URI of the default (or first) audio rendition in [groupId].
  String? _findAudioUrl(String master, String groupId, Uri baseUri) {
    String? firstUrl;
    for (final line in master.split('\n')) {
      final t = line.trim();
      if (!t.startsWith('#EXT-X-MEDIA:')) continue;
      if (!t.contains('TYPE=AUDIO')) continue;
      if (!t.contains('GROUP-ID="$groupId"')) continue;
      final m = RegExp(r'URI="([^"]+)"').firstMatch(t);
      if (m == null) continue;
      final raw = m.group(1)!;
      final url =
          raw.startsWith('http') ? raw : _resolve(baseUri, raw);
      if (t.contains('DEFAULT=YES')) return url;
      firstUrl ??= url;
    }
    return firstUrl;
  }

  static final _uriAttr = RegExp(r'URI="([^"]+)"');

  String _rewriteUriAttrs(String tag, Uri baseUri) {
    return tag.replaceAllMapped(_uriAttr, (m) {
      final raw = m.group(1)!;
      final absolute =
          raw.startsWith('http') ? raw : _resolve(baseUri, raw);
      return 'URI="$absolute"';
    });
  }

  // ── networking helpers ───────────────────────────────────────────────────

  Future<String> _followRedirects(HttpClient client, String url,
      {int maxHops = 5}) async {
    var current = url;
    for (var i = 0; i < maxHops; i++) {
      final req = await client.getUrl(Uri.parse(current));
      req.headers.set('User-Agent', _ua);
      _globalHeaders.forEach((k, v) { req.headers.set(k, v); });
      req.followRedirects = false;
      final res = await req.close();
      await res.drain();
      if (res.statusCode >= 300 && res.statusCode < 400) {
        final loc = res.headers.value('location');
        if (loc != null) {
          current = _resolve(Uri.parse(current), loc);
          continue;
        }
      }
      break;
    }
    return current;
  }

  Future<String?> _fetchPlaylist(HttpClient client, String url) async {
    final req = await client.getUrl(Uri.parse(url));
    req.headers.set('User-Agent', _ua);
    _globalHeaders.forEach((k, v) { req.headers.set(k, v); });
    final res = await req.close();
    if (res.statusCode != 200) {
      debugPrint('[CastStream] HTTP ${res.statusCode} fetching $url');
      await res.drain();
      return null;
    }
    return res.transform(utf8.decoder).join();
  }

  /// Fetches raw bytes (encryption keys, init segments, etc.).
  Future<List<int>?> _fetchRaw(HttpClient client, String url) async {
    try {
      final req = await client.getUrl(Uri.parse(url));
      req.headers.set('User-Agent', _ua);
      _globalHeaders.forEach((k, v) { req.headers.set(k, v); });
      final res = await req.close();
      if (res.statusCode != 200) {
        debugPrint('[CastStream] HTTP ${res.statusCode} fetching raw $url');
        await res.drain();
        return null;
      }
      final bytes = <int>[];
      await for (final chunk in res) {
        bytes.addAll(chunk);
      }
      return bytes;
    } catch (e) {
      debugPrint('[CastStream] Error fetching raw $url: $e');
      return null;
    }
  }

  /// HEAD / small-range GET to check if a URL is reachable without auth.
  Future<bool> _probe(HttpClient client, String url) async {
    try {
      final req = await client.getUrl(Uri.parse(url));
      req.headers.set('User-Agent', _ua);
      _globalHeaders.forEach((k, v) { req.headers.set(k, v); });
      final res = await req.close();
      await res.drain();
      return res.statusCode == 200 || res.statusCode == 206;
    } catch (_) {
      return false;
    }
  }

  // ── local HTTP server ────────────────────────────────────────────────────

  Future<void> _startServer() async {
    if (isRunning) return;

    _localIp = await _getLocalIp();
    _server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    _port = _server!.port;

    _proxyClient = HttpClient()..autoUncompress = false;

    _server!.listen((req) async {
      final path = req.uri.path;
      debugPrint('[CastStream] ${req.method} $path');

      try {
        final text = _files[path];
        final raw = _rawFiles[path];
        final remoteUrl = _proxyMap[path];

        if (text != null) {
          req.response.headers
            ..contentType = ContentType('application', 'x-mpegurl')
            ..add('Access-Control-Allow-Origin', '*');
          req.response.write(text);
          await _safeCloseResponse(req.response);
        } else if (raw != null) {
          debugPrint('[CastStream] Serving binary $path (${raw.length} B)');
          req.response.headers
            ..contentType = ContentType('application', 'octet-stream')
            ..contentLength = raw.length
            ..add('Access-Control-Allow-Origin', '*');
          req.response.add(raw);
          await _safeCloseResponse(req.response);
        } else if (remoteUrl != null) {
          try {
            final upstream = await _proxyClient!.getUrl(Uri.parse(remoteUrl));
            upstream.headers.set('User-Agent', _ua);
            _globalHeaders.forEach((k, v) { upstream.headers.set(k, v); });

            // Forward Range header from Chromecast if present.
            final range = req.headers.value('range');
            if (range != null) {
              upstream.headers.set('Range', range);
              debugPrint('[CastStream] Forwarding Range: $range');
            }

            final upRes = await upstream.close();
            debugPrint('[CastStream] CDN ${upRes.statusCode} for $path '
                '(${upRes.contentLength} bytes)');

            req.response.statusCode = upRes.statusCode;
            req.response.headers.add('Access-Control-Allow-Origin', '*');
            final ct = upRes.headers.contentType;
            if (path.contains('/seg/')) {
              // Force MPEG-TS for segments even if CDN disguises them as JPG/etc.
              req.response.headers.contentType = ContentType('video', 'mp2t');
            } else if (ct != null) {
              req.response.headers.contentType = ct;
            }
            if (upRes.contentLength >= 0) {
              req.response.contentLength = upRes.contentLength;
            }

            // Copy all helpful headers from upstream (but skip we handle manually).
            upRes.headers.forEach((name, values) {
              final n = name.toLowerCase();
              if (n == 'content-type' || n == 'content-length' || n == 'access-control-allow-origin') return;
              for (final v in values) {
                req.response.headers.add(name, v);
              }
            });

            final sw = Stopwatch()..start();
            try {
              await upRes.pipe(req.response);
              sw.stop();
              debugPrint('[CastStream] Done proxying $path in ${sw.elapsedMilliseconds}ms');
            } on SocketException catch (e) {
              debugPrint(
                  '[CastStream] Client disconnected during pipe $path: $e');
            } on IOException catch (e) {
              debugPrint('[CastStream] IO error during pipe $path: $e');
            }
          } catch (e) {
            debugPrint('[CastStream] Proxy error $path: $e');
            try {
              req.response.statusCode = 502;
              req.response.write('Proxy error');
            } on SocketException {
              debugPrint(
                  '[CastStream] Client disconnected during error response');
            }
            await _safeCloseResponse(req.response);
          }
        } else {
          debugPrint('[CastStream] 404 $path');
          req.response.statusCode = 404;
          req.response.write('Not found');
          await _safeCloseResponse(req.response);
        }
      } on SocketException catch (e) {
        debugPrint('[CastStream] Client disconnected $path: $e');
      } catch (e) {
        debugPrint('[CastStream] Request error $path: $e');
      }
    }, onError: (e) {
      debugPrint('[CastStream] Server error: $e');
    });

    debugPrint('[CastStream] Listening on $baseUrl');
  }

  Future<String> _getLocalIp() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLinkLocal: false,
    );
    for (final iface in interfaces) {
      if (iface.name.startsWith('lo')) continue;
      for (final addr in iface.addresses) {
        if (!addr.isLoopback) return addr.address;
      }
    }
    return '127.0.0.1';
  }

  Future<void> stop({String? reason}) async {
    await _server?.close(force: true);
    _server = null;
    _proxyClient?.close(force: true);
    _proxyClient = null;
    _localIp = null;
    _port = null;
    _files.clear();
    _rawFiles.clear();
    _proxyMap.clear();
    debugPrint('[CastStream] Stopped${reason != null ? ': $reason' : ''}');
    if (kDebugMode) {
      debugPrint(StackTrace.current.toString());
    }
  }
}
