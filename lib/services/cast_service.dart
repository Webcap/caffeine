import 'dart:async';

import 'package:reelriot/services/stream_proxy.dart';
import 'package:cast_plus/cast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CastState { idle, scanning, connecting, connected, error }

/// Manages Chromecast discovery, connection, and media control.
class CastService extends ChangeNotifier {
  static const String _receiverAppId = 'CC1AD845';
  static const _wakeCh = MethodChannel('media.webcap.caffeine/cast_wake');

  CastState _state = CastState.idle;
  CastState get state => _state;
  bool get isConnected => _state == CastState.connected;
  bool get isScanning => _state == CastState.scanning;

  String? _connectedDeviceName;
  String? get connectedDeviceName => _connectedDeviceName;

  String? _nowPlayingTitle;
  String? get nowPlayingTitle => _nowPlayingTitle;

  CastSession? _session;
  StreamSubscription? _stateSubscription;
  StreamSubscription? _messageSubscription;
  final CastStreamServer _streamServer = CastStreamServer();

  int _mediaSessionId = 0;

  /// Last known playback position on the Chromecast (seconds).
  int _castPositionSeconds = 0;
  int get castPositionSeconds => _castPositionSeconds;

  /// Position when casting ended (for resuming local playback). Cleared when starting a new cast.
  int? _lastCastPositionOnDisconnect;
  int? get lastCastPositionOnDisconnect => _lastCastPositionOnDisconnect;

  List<CastDevice> _devices = [];
  List<CastDevice> get devices => List.unmodifiable(_devices);

  String? _lastError;
  String? get lastError => _lastError;

  /// Total duration of the media being cast (seconds).
  int _totalMediaDurationSeconds = 0;
  int get totalMediaDurationSeconds => _totalMediaDurationSeconds;

  /// Whether the media has reached 100% completion on the cast device.
  bool _isMediaFinishedOnCast = false;
  bool get isMediaFinishedOnCast => _isMediaFinishedOnCast;

  void clearFinishedStatus() {
    if (_isMediaFinishedOnCast) {
      _isMediaFinishedOnCast = false;
      notifyListeners();
    }
  }

  Future<List<CastDevice>> scanForDevices(
      {Duration timeout = const Duration(seconds: 5)}) async {
    _state = CastState.scanning;
    _devices = [];
    _lastError = null;
    notifyListeners();
    try {
      _devices = await CastDiscoveryService().search(timeout: timeout);
      debugPrint('[CastService] Found ${_devices.length} device(s)');
    } catch (e) {
      _devices = [];
      _lastError = e.toString();
      debugPrint('[CastService] Scan error: $e');
    }
    _state = isConnected ? CastState.connected : CastState.idle;
    notifyListeners();
    return _devices;
  }

  Future<void> connectAndPlay({
    required CastDevice device,
    required String streamUrl,
    required String title,
    String? posterUrl,
    int elapsedSeconds = 0,
    Map<String, String>? headers,
  }) async {
    await disconnect(silent: true);

    _lastCastPositionOnDisconnect = null;
    _state = CastState.connecting;
    _connectedDeviceName = device.name;
    _nowPlayingTitle = title;
    _lastError = null;
    _mediaSessionId = 0;
    _totalMediaDurationSeconds = 0;
    _isMediaFinishedOnCast = false;
    notifyListeners();

    debugPrint(
        '[CastService] Connecting to ${device.name} (${device.host}:${device.port})');

    try {
      await _streamServer.stop(reason: 'connectAndPlay');
      final castUrl = await _streamServer.prepare(streamUrl, overrideHeaders: headers);
      final loadUrl = castUrl ?? streamUrl;
      debugPrint('[CastService] Cast URL: $loadUrl');

      _session = await CastSessionManager().startSession(device);

      _messageSubscription = _session!.messageStream.listen((msg) {
        debugPrint('[CastService] Receiver message: ${msg['type']}');

        final type = msg['type'] as String?;
        if (type == 'MEDIA_STATUS') {
          final statuses = msg['status'] as List?;
          if (statuses != null && statuses.isNotEmpty) {
            final first = statuses[0] as Map<String, dynamic>;
            _mediaSessionId =
                (first['mediaSessionId'] as num?)?.toInt() ?? _mediaSessionId;
            final curTime = (first['currentTime'] as num?)?.toInt();
            if (curTime != null && curTime > 0) {
              _castPositionSeconds = curTime;
            }
            final playerState = first['playerState'];
            final idleReason = first['idleReason'];

            final mediaObj = first['media'] as Map<String, dynamic>?;
            final duration = (mediaObj?['duration'] as num?)?.toInt();
            if (duration != null && duration > 0) {
              _totalMediaDurationSeconds = duration;
            }

            debugPrint(
                '[CastService] playerState=$playerState idleReason=$idleReason pos=${_castPositionSeconds}s duration=${_totalMediaDurationSeconds}s mediaSessionId=$_mediaSessionId');

            if (playerState == 'IDLE' && idleReason == 'FINISHED') {
              _isMediaFinishedOnCast = true;
              notifyListeners();
            }

            if (idleReason == 'ERROR') {
              _lastError = 'Chromecast failed to load media';
              notifyListeners();
            }
          }
        } else if (type == 'LOAD_FAILED' || type == 'INVALID_REQUEST') {
          debugPrint('[CastService] LOAD error: $msg');
          _lastError = msg['reason']?.toString() ?? 'Load failed on Chromecast';
          notifyListeners();
        }
      }, onError: (e) {
        debugPrint('[CastService] Message stream error: $e');
      });

      _stateSubscription = _session!.stateStream.listen((castState) async {
        debugPrint('[CastService] Session state: $castState');
        if (castState == CastSessionState.connected &&
            _state == CastState.connecting) {
          _state = CastState.connected;
          _wakeCh.invokeMethod('acquire').catchError((_) {});
          notifyListeners();
          Future.delayed(const Duration(milliseconds: 2000), () {
            _sendLoad(loadUrl, title, posterUrl, elapsedSeconds);
          });
        } else if (castState == CastSessionState.closed) {
          _lastCastPositionOnDisconnect =
              _castPositionSeconds > 0 ? _castPositionSeconds : null;
          _state = CastState.idle;
          _connectedDeviceName = null;
          _nowPlayingTitle = null;
          _session = null;
          await _streamServer.stop(reason: 'session_closed');
          notifyListeners();
        }
      }, onError: (e) {
        debugPrint('[CastService] State stream error: $e');
      });

      _session!.sendMessage(CastSession.kNamespaceReceiver, {
        'type': 'LAUNCH',
        'appId': _receiverAppId,
      });
    } catch (e) {
      debugPrint('[CastService] Connect error: $e');
      _state = CastState.error;
      _lastError = e.toString();
      _connectedDeviceName = null;
      _session = null;
      notifyListeners();
    }
  }

  void _sendLoad(
      String url, String title, String? posterUrl, int elapsedSeconds) {
    if (_session == null) {
      debugPrint('[CastService] _sendLoad aborted: session is null');
      return;
    }

    final isHls = _looksLikeHls(url);
    final contentType = isHls ? 'application/x-mpegurl' : 'video/mp4';
    debugPrint(
        '[CastService] LOAD url=$url contentType=$contentType elapsed=$elapsedSeconds');

    _session!.sendMessage(CastSession.kNamespaceMedia, {
      'type': 'LOAD',
      'autoplay': true,
      'currentTime': elapsedSeconds.toDouble(),
      'media': {
        'contentId': url,
        'contentUrl': url,
        'contentType': contentType,
        'streamType': 'BUFFERED',
        if (isHls) ...{
          'hlsSegmentFormat': 'ts',
          'hlsVideoSegmentFormat': 'mpeg2_ts',
        },
        'metadata': {
          'type': 0,
          'metadataType': 0,
          'title': title,
          if (posterUrl != null && posterUrl.isNotEmpty)
            'images': [
              {'url': posterUrl}
            ],
        },
      },
    });
  }

  void pause() {
    _session?.sendMessage(CastSession.kNamespaceMedia, {
      'type': 'PAUSE',
      'mediaSessionId': _mediaSessionId,
    });
  }

  void resume() {
    _session?.sendMessage(CastSession.kNamespaceMedia, {
      'type': 'PLAY',
      'mediaSessionId': _mediaSessionId,
    });
  }

  void seekTo(int seconds) {
    _session?.sendMessage(CastSession.kNamespaceMedia, {
      'type': 'SEEK',
      'currentTime': seconds.toDouble(),
      'mediaSessionId': _mediaSessionId,
    });
  }

  Future<void> disconnect({bool silent = false}) async {
    _stateSubscription?.cancel();
    _stateSubscription = null;
    _messageSubscription?.cancel();
    _messageSubscription = null;

    if (_session != null) {
      try {
        _session!.sendMessage(CastSession.kNamespaceReceiver, {
          'type': 'STOP',
          'sessionId': '',
        });
        await _session!.close();
      } catch (_) {}
      _session = null;
    }
    await _streamServer.stop(reason: 'disconnect(silent: $silent)');
    _wakeCh.invokeMethod('release').catchError((_) {});
    _lastCastPositionOnDisconnect =
        _castPositionSeconds > 0 ? _castPositionSeconds : null;
    _state = CastState.idle;
    _connectedDeviceName = null;
    _nowPlayingTitle = null;
    _mediaSessionId = 0;
    if (!silent) notifyListeners();
  }

  static bool _looksLikeHls(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('m3u8') || lower.contains('playlist')) return true;
    final uri = Uri.tryParse(url);
    final path = uri?.path ?? '';
    return !(path.endsWith('.mp4') ||
        path.endsWith('.mkv') ||
        path.endsWith('.webm'));
  }
}
