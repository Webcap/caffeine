import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/utils/constant.dart';
import 'dart:async';
import 'dart:convert';

enum CaffeinePlayerEventType {
  initialized,
  play,
  pause,
  seek,
  bufferingStart,
  bufferingEnd,
  finished,
  error,
  controlsVisible,
  controlsHiddenStart,
  controlsHiddenEnd,
  progress,
}

class CaffeinePlayerEvent {
  final CaffeinePlayerEventType type;
  final Duration? position;
  final String? message;

  CaffeinePlayerEvent(this.type, {this.position, this.message});
}

class CaffeinePlayerSubtitlesSource {
  final String? name;
  final String? url;
  final String? data;
  final List<String>? urls;
  final bool isDefault;

  CaffeinePlayerSubtitlesSource({
    this.name,
    this.url,
    this.data,
    this.urls,
    this.isDefault = false,
  });
}

class CaffeinePlayerController extends ChangeNotifier {
  late final Player player;
  late final VideoController videoController;

  String name = '';
  String? watchingText;

  final List<void Function(CaffeinePlayerEvent)> _listeners = [];
  final StreamController<bool> _controlsVisibilityStreamController =
      StreamController<bool>.broadcast();

  bool _isBuffering = false;
  // ignore: unused_field
  bool _controlsVisible = false;

  final List<StreamSubscription> _subscriptions = [];

  CaffeinePlayerController() {
    player = Player();
    videoController = VideoController(
      player,
      configuration: const VideoControllerConfiguration(
        hwdec: 'mediacodec-copy',
      ),
    );
    _setupListeners();
  }

  Stream<bool> get controlsVisibilityStream =>
      _controlsVisibilityStreamController.stream;

  void _setupListeners() {
    _subscriptions.add(player.stream.completed.listen((completed) {
      if (completed) _emit(CaffeinePlayerEventType.finished);
    }));

    _subscriptions.add(player.stream.error.listen((error) {
      debugPrint('[PlayerController] ❌ Error: $error');
      _emit(CaffeinePlayerEventType.error, message: error);
    }));

    _subscriptions.add(player.stream.buffering.listen((buffering) {
      debugPrint('[PlayerController] ⏳ Buffering: $buffering');
      _isBuffering = buffering;
      _emit(buffering
          ? CaffeinePlayerEventType.bufferingStart
          : CaffeinePlayerEventType.bufferingEnd);
    }));

    _subscriptions.add(player.stream.playing.listen((playing) {
      debugPrint('[PlayerController] ▶️ Playing: $playing');
      _emit(
        playing ? CaffeinePlayerEventType.play : CaffeinePlayerEventType.pause,
      );
    }));

    _subscriptions.add(player.stream.duration.listen((duration) {
      debugPrint('[PlayerController] 🕒 Duration: $duration');
    }));

    _subscriptions.add(player.stream.width.listen((width) {
      debugPrint('[PlayerController] 📏 Width: $width');
    }));

    _subscriptions.add(player.stream.height.listen((height) {
      debugPrint('[PlayerController] 📏 Height: $height');
    }));

    _subscriptions.add(player.stream.position.listen((position) {
      _emit(CaffeinePlayerEventType.progress, position: position);
    }));
  }

  void _emit(
    CaffeinePlayerEventType type, {
    Duration? position,
    String? message,
  }) {
    final event = CaffeinePlayerEvent(
      type,
      position: position,
      message: message,
    );
    for (var listener in _listeners.toList()) {
      listener(event);
    }
    notifyListeners();
  }

  void addEventsListener(void Function(CaffeinePlayerEvent) listener) {
    _listeners.add(listener);
  }

  void removeEventsListener(void Function(CaffeinePlayerEvent) listener) {
    _listeners.remove(listener);
  }

  void toggleControlsVisibility(bool visible) {
    _controlsVisible = visible;
    _controlsVisibilityStreamController.add(visible);
    _emit(
      visible
          ? CaffeinePlayerEventType.controlsVisible
          : CaffeinePlayerEventType.controlsHiddenEnd,
    );
  }

  // ---------------------------------------------------------------------------
  // Proxy routing
  // ---------------------------------------------------------------------------

  /// Domains whose streams must be fetched via the Caffeine server proxy.
  /// The proxy adds proper browser Sec-Fetch-* headers and rewrites all HLS
  /// segment URLs through itself so every request arrives from the server IP.
  static const _proxiedDomains = [
    'wfty.st',
    'lb4.wfty.st',
    'vixsrc.to',
    'vix-content.net',
    'vodvidl.site',
    'vodvid.site',
    'strmd.st',
  ];

  /// Returns true when [url]'s host matches a CDN-protected domain.
  static bool _needsProxy(String url) {
    try {
      final host = Uri.parse(url).host.toLowerCase();
      return _proxiedDomains.any((d) => host == d || host.endsWith('.$d'));
    } catch (_) {
      return false;
    }
  }

  /// Builds a Caffeine proxy URL for [targetUrl] with upstream [headers].
  /// The proxy route accepts the app API key as ?key= for authorization.
  static String _buildCaffeineProxyUrl(
    String targetUrl,
    Map<String, String> headers,
  ) {
    final base = caffeineApiUrl.endsWith('/')
        ? caffeineApiUrl.substring(0, caffeineApiUrl.length - 1)
        : caffeineApiUrl;
    // Use standard base64url (no padding) — the proxy's b64Decode handles it.
    final urlB64 = base64Url.encode(utf8.encode(targetUrl));
    final headersB64 = base64Url.encode(utf8.encode(jsonEncode(headers)));
    final key = caffeineApiKey;
    final keyParam =
        key.isNotEmpty ? '&key=${Uri.encodeQueryComponent(key)}' : '';
    return '$base/proxy/stream/video.m3u8'
        '?url=${Uri.encodeQueryComponent(urlB64)}'
        '&headers=${Uri.encodeQueryComponent(headersB64)}'
        '$keyParam';
  }

  // ---------------------------------------------------------------------------
  // Playback
  // ---------------------------------------------------------------------------

  Future<void> setDataSource(
    String url, {
    Map<String, String>? headers,
    bool liveStream = false,
    Duration startAt = Duration.zero,
    List<CaffeinePlayerSubtitlesSource>? subtitles,
  }) async {
    // Inject a Chrome user agent to prevent Cloudflare bot blocking.
    final finalHeaders = Map<String, String>.from(headers ?? {});
    if (!finalHeaders.keys.any((k) => k.toLowerCase() == 'user-agent')) {
      finalHeaders['User-Agent'] = browserUserAgent;
    }

    // Route CDN-protected streams through the Caffeine server proxy.
    // The proxy adds Sec-Fetch-* and other browser-only headers that libmpv
    // cannot send, and rewrites every HLS segment URL through itself — exactly
    // replicating what the web player does in a real browser.
    String playUrl = url;
    Map<String, String> playHeaders = finalHeaders;
    if (_needsProxy(url)) {
      playUrl = _buildCaffeineProxyUrl(url, finalHeaders);
      // The proxy handles all upstream auth; we only need UA for our own API.
      playHeaders = {'User-Agent': browserUserAgent};
      debugPrint('[PlayerController] 🌐 Routing via Caffeine proxy');
      debugPrint('[PlayerController] original: $url');
    } else {
      debugPrint('[PlayerController] setDataSource: $url');
    }

    debugPrint('[PlayerController] headers: $playHeaders');

    // Performance and stability optimizations for Android
    (player.platform as dynamic).setProperty('vd-lavc-dr', 'no'); // MUST be 'no' on Android to prevent SELinux dmabuf AVC denials
    (player.platform as dynamic).setProperty('hwdec', 'mediacodec-copy');

    if (liveStream) {
      // Stability optimizations for live streams
      (player.platform as dynamic).setProperty('demuxer-readahead-secs', '10');
      (player.platform as dynamic).setProperty('cache-secs', '15');
    }

    // Handle subtitles
    if (subtitles != null && subtitles.isNotEmpty) {
      for (var sub in subtitles) {
        final track = sub.url != null
            ? SubtitleTrack.uri(sub.url!, title: sub.name)
            : sub.urls != null && sub.urls!.isNotEmpty
                ? SubtitleTrack.uri(sub.urls!.first, title: sub.name)
                : sub.data != null
                    ? SubtitleTrack.data(sub.data!, title: sub.name)
                    : null;

        if (track != null) {
          player.setSubtitleTrack(track);
          // If this is the default one, it will remain selected (since it's usually the last or specifically picked)
          // However, we should prioritize the one marked as isDefault.
          if (sub.isDefault) {
            // We'll set it again after the loop or just rely on it being the "most important" one.
          }
        }
      }

      // Explicitly select default if found
      try {
        final defaultSub = subtitles.firstWhere((s) => s.isDefault);
        setSubtitleSource(defaultSub);
      } catch (_) {
        // No default sub found
      }
    }

    await player.open(
      Media(
        playUrl,
        httpHeaders: playHeaders,
      ),
      play: false,
    );

    if (startAt > Duration.zero) {
      await player.seek(startAt);

      StreamSubscription<Duration>? sub;
      sub = player.stream.duration.listen((d) {
        if (d > Duration.zero) {
          player.seek(startAt);
          sub?.cancel();
        }
      });
    }

    await player.play();

    _emit(CaffeinePlayerEventType.initialized);
  }

  // Bridge for legacy code
  Future<void> setupDataSource(dynamic dataSource) async {
    try {
      final url = (dataSource as dynamic).url as String;
      return setDataSource(url);
    } catch (e) {
      debugPrint('[CaffeinePlayerController] ⚠️ setupDataSource failed: $e');
    }
  }

  Future<void> play() => player.play();
  Future<void> pause() => player.pause();
  Future<void> seekTo(Duration position) => player.seek(position);

  bool isPlaying() => player.state.playing;
  bool isBuffering() => _isBuffering;

  Duration get position => player.state.position;
  Duration get duration => player.state.duration;

  List<AudioTrack> get audioTracks => player.state.tracks.audio;
  List<SubtitleTrack> get subtitleTracks => player.state.tracks.subtitle;

  void setAudioTrack(AudioTrack track) => player.setAudioTrack(track);
  void setSubtitleTrack(SubtitleTrack track) => player.setSubtitleTrack(track);

  void setSubtitleSource(CaffeinePlayerSubtitlesSource source) {
    if (source.url != null) {
      player.setSubtitleTrack(SubtitleTrack.uri(source.url!, title: source.name));
    } else if (source.urls != null && source.urls!.isNotEmpty) {
      player.setSubtitleTrack(
          SubtitleTrack.uri(source.urls!.first, title: source.name));
    } else if (source.data != null) {
      player.setSubtitleTrack(SubtitleTrack.data(source.data!, title: source.name));
    }
  }

  bool isVideoInitialized() =>
      player.state.width != null && player.state.height != null;

  @override
  Future<void> dispose() async {
    _controlsVisibilityStreamController.close();
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    try {
      await player.pause();
      await player.dispose();
    } catch (e) {
      debugPrint('[CaffeinePlayerController] Error during dispose: $e');
    }
    super.dispose();
  }
}
