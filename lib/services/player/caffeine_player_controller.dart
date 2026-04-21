import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter/material.dart';
import 'dart:async';

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
    videoController = VideoController(player);
    _setupListeners();
  }

  Stream<bool> get controlsVisibilityStream =>
      _controlsVisibilityStreamController.stream;

  void _setupListeners() {
    _subscriptions.add(player.stream.buffering.listen((isBuffering) {
      _isBuffering = isBuffering;
      _emit(
        isBuffering
            ? CaffeinePlayerEventType.bufferingStart
            : CaffeinePlayerEventType.bufferingEnd,
      );
    }));

    _subscriptions.add(player.stream.completed.listen((completed) {
      if (completed) _emit(CaffeinePlayerEventType.finished);
    }));

    _subscriptions.add(player.stream.error.listen((error) {
      _emit(CaffeinePlayerEventType.error, message: error);
    }));

    _subscriptions.add(player.stream.playing.listen((playing) {
      _emit(
        playing ? CaffeinePlayerEventType.play : CaffeinePlayerEventType.pause,
      );
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

  Future<void> setDataSource(
    String url, {
    Map<String, String>? headers,
    bool liveStream = false,
    Duration startAt = Duration.zero,
    List<CaffeinePlayerSubtitlesSource>? subtitles,
  }) async {
    if (headers != null && headers.isNotEmpty) {
      final headerString = headers.entries
          .map((e) => "${e.key}: ${e.value}")
          .join("\r\n");
      (player.platform as dynamic).setProperty('http-header-fields', headerString);
    }

    if (liveStream) {
      // Stability optimizations for live streams
      (player.platform as dynamic).setProperty('demuxer-readahead-secs', '10');
      (player.platform as dynamic).setProperty('cache-secs', '15');
      (player.platform as dynamic).setProperty('hwdec', 'mediacodec');
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
      Media(url),
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
