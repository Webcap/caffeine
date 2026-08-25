import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class UrlWebPage extends StatefulWidget {
  final String url;

  /// When true, only the WebView is shown (no AppBar). Use when embedding inside another screen (e.g. live event default view).
  final bool embedded;

  /// When true, injects JS to hide ads and trigger video play (for stream embeds).
  final bool blockAds;

  /// When true, runs JS to extract HLS (m3u8) from the page and calls [onHlsExtracted]. Runs on load and retries.
  final bool tryExtractHls;

  /// Optional initial playback timestamp in seconds to seek HTML5 video / embedded players upon loading.
  final int? startAtSeconds;

  /// Called when live playback progress is detected from HTML5 video / player inside WebView.
  final void Function(double currentTime, double duration)? onProgressUpdate;

  /// Called when HLS URL is extracted via JS (only if [tryExtractHls] is true).
  final void Function(String hls)? onHlsExtracted;

  /// Called when the webview enters or exits fullscreen custom view.
  final void Function(bool isFullscreen)? onFullscreenChanged;

  const UrlWebPage({
    super.key,
    required this.url,
    this.embedded = false,
    this.blockAds = false,
    this.tryExtractHls = false,
    this.startAtSeconds,
    this.onProgressUpdate,
    this.onHlsExtracted,
    this.onFullscreenChanged,
  });

  @override
  UrlWebPageState createState() => UrlWebPageState();
}

class UrlWebPageState extends State<UrlWebPage> {
  late final WebViewController controller;

  static const String _adBlockJs = r'''
    (function() {
      // 1. Intercept and block popup windows (window.open)
      try {
        window.open = function() {
          console.log("[AdBlock] Blocked window.open");
          return null;
        };
        Object.defineProperty(window, 'open', {
          value: function() { console.log("[AdBlock] Blocked window.open"); return null; },
          writable: false,
          configurable: false
        });
      } catch(e) {}

      // 2. Disable alert/confirm/prompt scam popups
      try {
        window.alert = function() {};
        window.confirm = function() { return false; };
        window.prompt = function() { return null; };
      } catch(e) {}

      // 3. Helper to check if a URL belongs to the player domain
      function isAllowedUrl(url) {
        try {
          if (!url) return false;
          if (url.startsWith('/') || url.startsWith('#') || url.startsWith('javascript:') || url.startsWith('blob:') || url.startsWith('data:')) return true;
          var a = document.createElement('a');
          a.href = url;
          var curHost = window.location.hostname.toLowerCase();
          var tgtHost = (a.hostname || '').toLowerCase();
          if (!tgtHost || curHost === tgtHost) return true;
          var curParts = curHost.split('.');
          var tgtParts = tgtHost.split('.');
          if (curParts.length >= 2 && tgtParts.length >= 2) {
            var curRoot = curParts.slice(-2).join('.');
            var tgtRoot = tgtParts.slice(-2).join('.');
            return curRoot === tgtRoot;
          }
          return false;
        } catch(e) { return false; }
      }

      // 4. Remove intrusive ad overlays, popups, and click-hijacking layers
      function cleanAdLayers() {
        try {
          var hideSelectors = [
            '[id*="ad"]', '[class*="ad"]', '.adsbygoogle', 'ins.adsbygoogle',
            'iframe[src*="doubleclick"]', 'iframe[src*="googlesyndication"]', 'iframe[src*="ads"]',
            'iframe[src*="pop"]', 'iframe[src*="banner"]', 'iframe[src*="traffic"]',
            '.ad-overlay', '.ad-container', '.ad-overlay-alt', '[class*="overlay"][class*="ad"]',
            '[id*="pop"]', '[class*="pop"]', '[class*="sponsor"]', '[id*="sponsor"]'
          ];
          hideSelectors.forEach(function(sel) {
            try {
              document.querySelectorAll(sel).forEach(function(el) {
                if (!el.querySelector('video') && el.tagName !== 'VIDEO') {
                  el.style.display = 'none';
                  el.remove();
                }
              });
            } catch(e) {}
          });

          // Remove transparent overlay divs that hijack taps
          document.querySelectorAll('div, a, span, section').forEach(function(el) {
            if (el.tagName === 'VIDEO' || el.querySelector('video') || el.classList.contains('vjs-tech')) return;
            var style = window.getComputedStyle(el);
            var zIndex = parseInt(style.zIndex, 10);
            if (zIndex > 50 && (style.position === 'fixed' || style.position === 'absolute')) {
              var rect = el.getBoundingClientRect();
              if (rect.width > window.innerWidth * 0.7 && rect.height > window.innerHeight * 0.7) {
                el.remove();
              }
            }
          });

          // Neutralize external anchor tags
          document.querySelectorAll('a').forEach(function(a) {
            var href = a.getAttribute('href') || '';
            if (a.target === '_blank' || (href.startsWith('http') && !isAllowedUrl(href))) {
              a.removeAttribute('target');
              a.setAttribute('data-blocked-href', href);
              a.removeAttribute('href');
              a.onclick = function(e) {
                e.preventDefault();
                e.stopPropagation();
                return false;
              };
            }
          });
        } catch(e) {}
      }

      // 5. Intercept click events at the capture phase to block popunder redirects
      if (!window.__reelriot_click_intercepted) {
        window.__reelriot_click_intercepted = true;
        window.addEventListener('click', function(e) {
          var target = e.target;
          while (target && target !== document.body && target !== document.documentElement) {
            if (target.tagName === 'A') {
              var href = target.getAttribute('href') || target.getAttribute('data-blocked-href') || '';
              if (href && !isAllowedUrl(href)) {
                e.preventDefault();
                e.stopPropagation();
                e.stopImmediatePropagation();
                return false;
              }
            }
            target = target.parentElement;
          }
        }, true);
      }

      cleanAdLayers();
      if (!window.__reelriot_ad_interval) {
        window.__reelriot_ad_interval = setInterval(cleanAdLayers, 1000);
      }
    })();
  ''';

  /// Intercept fetch/XHR so any .m3u8 request made after this runs is captured (like Web Video Caster).
  static const String _interceptHlsJs = r'''
    (function() {
      function send(url) {
        if (!url || url.length < 20 || url.indexOf('.m3u8') === -1) return;
        if (url.indexOf('/ad') !== -1 || url.indexOf('ad.') !== -1 || url.indexOf('ads.') !== -1) return;
        try { if (typeof HlsExtracted !== 'undefined') HlsExtracted.postMessage(url); } catch (e) {}
      }
      var _fetch = window.fetch;
      if (_fetch) {
        window.fetch = function(input) {
          var url = typeof input === 'string' ? input : (input && input.url);
          if (url) send(url);
          return _fetch.apply(this, arguments);
        };
      }
      var XHR = window.XMLHttpRequest;
      if (XHR) {
        var _open = XHR.prototype.open;
        XHR.prototype.open = function(method, url) {
          this._hlsUrl = url;
          return _open.apply(this, arguments);
        };
        var _send = XHR.prototype.send;
        XHR.prototype.send = function() {
          if (this._hlsUrl) send(this._hlsUrl);
          return _send.apply(this, arguments);
        };
      }
    })();
  ''';

  static const String _extractHlsJs = r'''
    (function() {
      var logMsg = function(msg) { try { if (typeof ConsoleLog !== 'undefined') ConsoleLog.postMessage(msg); } catch(e) {} };
      function find() {
        try {
          var v = document.querySelector('video');
          if (v) {
            var s = v.querySelector('source[src*=".m3u8"]');
            if (s && s.src) return s.src;
            if (v.src && v.src.indexOf('.m3u8') !== -1) return v.src;
            if (v.currentSrc && v.currentSrc.indexOf('.m3u8') !== -1) return v.currentSrc;
          }
          if (typeof Hls !== 'undefined' && Hls.instances && Hls.instances.length) {
            for (var i = 0; i < Hls.instances.length; i++) {
              var u = Hls.instances[i].url || (Hls.instances[i].media && Hls.instances[i].media.src);
              if (u && u.indexOf('.m3u8') !== -1) return u;
            }
          }
          if (typeof hls !== 'undefined' && hls.url) return hls.url;
          if (typeof videojs !== 'undefined') {
            var players = videojs.getPlayers ? videojs.getPlayers() : {};
            for (var k in players) {
              var p = players[k];
              var src = (p.currentSrc && p.currentSrc()) ? p.currentSrc() : (p.el_ && p.el_().querySelector('source') && p.el_().querySelector('source').src);
              if (src && src.indexOf('.m3u8') !== -1) return src;
            }
          }
          if (typeof jwplayer === 'function') {
            logMsg("jwplayer is a function");
            try {
              var p = jwplayer();
              logMsg("jwplayer() returned: " + (p ? "object" : "null"));
              if (p && p.getPlaylist) {
                var pl = p.getPlaylist();
                logMsg("jwplayer playlist length: " + (pl ? pl.length : "null"));
                if (pl && pl.length > 0 && pl[0].file) {
                  logMsg("jwplayer file: " + pl[0].file);
                  if (pl[0].file.indexOf('.m3u8') !== -1) {
                    return pl[0].file;
                  }
                }
              }
            } catch(e) { logMsg("jwplayer extract error: " + e.toString()); }
          } else {
             logMsg("jwplayer is NOT a function, typeof = " + (typeof jwplayer));
          }
          if (typeof window.player !== 'undefined' && window.player.core && window.player.core.getCurrentPlayback) {
            try {
              var pb = window.player.core.getCurrentPlayback();
              if (pb && pb.options && pb.options.src && pb.options.src.indexOf('.m3u8') !== -1) return pb.options.src;
              if (pb && pb._src && pb._src.indexOf('.m3u8') !== -1) return pb._src;
            } catch(e) {}
          }
          var scripts = document.querySelectorAll('script');
          for (var i = 0; i < scripts.length; i++) {
            var m = (scripts[i].textContent || '').match(/https?:\/\/[^\s"'<>]+\.m3u8[^\s"'<>]*/g);
            if (m) for (var j = 0; j < m.length; j++) if (m[j].indexOf('/ad') === -1 && m[j].indexOf('ad.') === -1) return m[j].replace(/['")}\]]+$/, '');
          }
        } catch (e) { logMsg("Global extract error: " + e.toString()); }
        return null;
      }
      var u = find();
      logMsg("extractHlsJs Result: " + (u || "null"));
      if (u && u.length > 20 && u.indexOf('/ad') === -1 && u.indexOf('ad.') === -1 && u.indexOf('ads.') === -1) {
        if (typeof HlsExtracted !== 'undefined') HlsExtracted.postMessage(u);
      }
    })();
  ''';

  static const String _attachProgressJs = r'''
    (function() {
      function sendProgress(cur, dur) {
        try {
          if (typeof PlaybackProgress !== 'undefined' && cur > 0) {
            PlaybackProgress.postMessage(JSON.stringify({
              currentTime: cur,
              duration: dur || 0
            }));
          }
        } catch(e) {}
      }

      // Hook native <video> elements: timeupdate + seeked
      function hookVideos() {
        try {
          document.querySelectorAll('video').forEach(function(v) {
            if (!v.__rr_tracked) {
              v.__rr_tracked = true;
              // timeupdate fires while playing (~4Hz)
              v.addEventListener('timeupdate', function() {
                sendProgress(v.currentTime, v.duration || 0);
              });
              // seeked fires immediately when user drags the seek bar
              v.addEventListener('seeked', function() {
                sendProgress(v.currentTime, v.duration || 0);
              });
            }
          });
        } catch(e) {}

        // JWPlayer
        try {
          if (typeof jwplayer === 'function') {
            var jw = jwplayer();
            if (jw && jw.on && !jw.__rr_tracked) {
              jw.__rr_tracked = true;
              jw.on('time', function(e) {
                if (e && e.position > 0) sendProgress(e.position, e.duration || 0);
              });
              jw.on('seek', function(e) {
                if (e && e.offset > 0) sendProgress(e.offset, jw.getDuration ? jw.getDuration() : 0);
              });
            }
          }
        } catch(e) {}

        // Video.js
        try {
          if (typeof videojs !== 'undefined' && videojs.getPlayers) {
            var players = videojs.getPlayers();
            for (var k in players) {
              var p = players[k];
              if (p && !p.__rr_tracked) {
                p.__rr_tracked = true;
                p.on('timeupdate', function() {
                  try { sendProgress(this.currentTime(), this.duration()); } catch(e) {}
                });
                p.on('seeked', function() {
                  try { sendProgress(this.currentTime(), this.duration()); } catch(e) {}
                });
              }
            }
          }
        } catch(e) {}
      }

      hookVideos();
      if (!window.__rr_progress_interval) {
        window.__rr_progress_interval = setInterval(hookVideos, 1500);
      }

      // Cross-frame: vixsrc and most embed players emit window.postMessage events
      // with their own currentTime. Intercept them and forward to Flutter.
      if (!window.__rr_msg_tracked) {
        window.__rr_msg_tracked = true;
        window.addEventListener('message', function(e) {
          try {
            var d = e.data;
            if (typeof d === 'string') {
              try { d = JSON.parse(d); } catch(_) { return; }
            }
            if (!d || typeof d !== 'object') return;
            // vixsrc / plyr / various players use these key names
            var cur = d.currentTime || d.current_time || d.position || d.time;
            var dur = d.duration || d.totalTime || d.total_time || 0;
            if (cur && cur > 0) sendProgress(cur, dur);
          } catch(ex) {}
        });
      }

      // Poll cross-origin iframes by asking them for their currentTime
      if (!window.__rr_iframe_poll) {
        window.__rr_iframe_poll = setInterval(function() {
          try {
            document.querySelectorAll('iframe').forEach(function(f) {
              try {
                if (f.contentWindow) {
                  f.contentWindow.postMessage({ type: 'getPosition' }, '*');
                  f.contentWindow.postMessage({ type: 'getCurrentTime' }, '*');
                }
              } catch(e) {}
            });
          } catch(e) {}
        }, 3000);
      }
    })();
  ''';

  void _runAdBlock() {
    if (!mounted || !widget.blockAds) return;
    controller.runJavaScript(_adBlockJs);
  }

  void _runInterceptHls() {
    if (!mounted || !widget.tryExtractHls || widget.onHlsExtracted == null) {
      return;
    }
    controller.runJavaScript(_interceptHlsJs);
  }

  void _runExtractHls() {
    if (!mounted || !widget.tryExtractHls || widget.onHlsExtracted == null) {
      return;
    }
    controller.runJavaScript(_extractHlsJs);
  }

  void _runProgressJs() {
    if (!mounted || widget.onProgressUpdate == null) return;
    controller.runJavaScript(_attachProgressJs);
  }

  void _runSeekJs() {
    if (!mounted || widget.startAtSeconds == null || widget.startAtSeconds! <= 3) return;
    final sec = widget.startAtSeconds!;
    final seekScript = '''
      (function() {
        var targetTime = $sec;
        function performSeek() {
          try {
            var videos = document.querySelectorAll('video');
            videos.forEach(function(v) {
              if (v && Math.abs(v.currentTime - targetTime) > 4) {
                try {
                  v.currentTime = targetTime;
                  v.play().catch(function(){});
                } catch(e) {}
              }
            });
            if (typeof jwplayer === 'function') {
              try {
                var jw = jwplayer();
                if (jw && jw.seek && Math.abs(jw.getPosition() - targetTime) > 4) {
                  jw.seek(targetTime);
                }
              } catch(e) {}
            }
            if (typeof videojs !== 'undefined' && videojs.getPlayers) {
              try {
                var players = videojs.getPlayers();
                for (var k in players) {
                  if (players[k] && players[k].currentTime) {
                    players[k].currentTime(targetTime);
                  }
                }
              } catch(e) {}
            }
            var frames = document.querySelectorAll('iframe');
            frames.forEach(function(f) {
              try {
                if (f.contentWindow) {
                  f.contentWindow.postMessage({ type: 'seek', time: targetTime }, '*');
                  f.contentWindow.postMessage({ event: 'seek', value: targetTime }, '*');
                  f.contentWindow.postMessage(JSON.stringify({ event: 'command', func: 'seekTo', args: [targetTime, true] }), '*');
                }
              } catch(e) {}
            });
          } catch(e) {}
        }
        performSeek();
      })();
    ''';
    controller.runJavaScript(seekScript);
  }

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      );

    if (widget.onProgressUpdate != null) {
      controller.addJavaScriptChannel(
        'PlaybackProgress',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final data = jsonDecode(message.message);
            if (data is Map) {
              final double cur =
                  (data['currentTime'] as num?)?.toDouble() ?? 0.0;
              final double dur =
                  (data['duration'] as num?)?.toDouble() ?? 0.0;
              if (cur > 0) {
                widget.onProgressUpdate!(cur, dur);
              }
            }
          } catch (_) {}
        },
      );
    }

    if (controller.platform is AndroidWebViewController) {
      final androidController =
          controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
      bool isFullscreenActive = false;
      androidController.setCustomWidgetCallbacks(
        onShowCustomWidget: (Widget customView, void Function() callback) {
          if (!mounted) return;
          log("[UrlWebPage] 📺 Pushing fullscreen custom view route");
          isFullscreenActive = true;
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
          widget.onFullscreenChanged?.call(true);

          Navigator.of(context).push<void>(
            PageRouteBuilder<void>(
              opaque: true,
              fullscreenDialog: true,
              transitionDuration: const Duration(milliseconds: 300),
              reverseTransitionDuration: const Duration(milliseconds: 250),
              pageBuilder: (context, animation, secondaryAnimation) {
                SystemChrome.setEnabledSystemUIMode(
                    SystemUiMode.immersiveSticky);
                return PopScope(
                  canPop: true,
                  onPopInvokedWithResult: (didPop, result) {
                    callback();
                  },
                  child: Scaffold(
                    backgroundColor: Colors.black,
                    body: Center(child: customView),
                  ),
                );
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                final curvedAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                );
                return FadeTransition(
                  opacity: curvedAnimation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.92, end: 1.0)
                        .animate(curvedAnimation),
                    child: child,
                  ),
                );
              },
            ),
          ).then((_) {
            isFullscreenActive = false;
            if (mounted) {
              SystemChrome.setEnabledSystemUIMode(
                  SystemUiMode.immersiveSticky);
              widget.onFullscreenChanged?.call(false);
            }
          });
        },
        onHideCustomWidget: () {
          log("[UrlWebPage] 📺 onHideCustomWidget called by webview");
          if (isFullscreenActive && mounted) {
            final nav = Navigator.of(context);
            if (nav.canPop()) {
              nav.pop();
            }
          }
          isFullscreenActive = false;
          if (mounted) {
            widget.onFullscreenChanged?.call(false);
          }
        },
      );
    }

    if (widget.tryExtractHls && widget.onHlsExtracted != null) {
      controller.addJavaScriptChannel(
        'HlsExtracted',
        onMessageReceived: (JavaScriptMessage message) {
          final url = message.message.trim();
          log("[UrlWebPage] HLS EXTRACTED: $url");
          if (url.isNotEmpty && url.contains('.m3u8')) {
            widget.onHlsExtracted!(url);
          }
        },
      );
    }
    controller.addJavaScriptChannel(
      'ConsoleLog',
      onMessageReceived: (JavaScriptMessage message) {
        log("[UrlWebPage JS] ${message.message}");
      },
    );
    controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (widget.blockAds || widget.embedded) {
              final reqUrl = request.url;

              // Allow initial URL and internal protocols/blobs
              if (reqUrl == widget.url ||
                  reqUrl.startsWith('about:') ||
                  reqUrl.startsWith('data:') ||
                  reqUrl.startsWith('blob:') ||
                  reqUrl.startsWith('javascript:')) {
                return NavigationDecision.navigate;
              }

              // Allow stream and video segments
              final lower = reqUrl.toLowerCase();
              if (lower.contains('.m3u8') ||
                  lower.contains('.mp4') ||
                  lower.contains('.webm') ||
                  lower.contains('.ts') ||
                  lower.contains('.key') ||
                  lower.contains('.m4s') ||
                  lower.contains('.mpd')) {
                return NavigationDecision.navigate;
              }

              // Allow navigation within the same root domain
              final uri = Uri.tryParse(reqUrl);
              final initialUri = Uri.tryParse(widget.url);
              if (uri != null &&
                  initialUri != null &&
                  uri.host.isNotEmpty &&
                  initialUri.host.isNotEmpty) {
                final reqHost = uri.host.toLowerCase();
                final initHost = initialUri.host.toLowerCase();
                if (reqHost == initHost ||
                    reqHost.endsWith('.$initHost') ||
                    initHost.endsWith('.$reqHost')) {
                  return NavigationDecision.navigate;
                }

                final reqParts = reqHost.split('.');
                final initParts = initHost.split('.');
                if (reqParts.length >= 2 && initParts.length >= 2) {
                  final reqRoot =
                      reqParts.sublist(reqParts.length - 2).join('.');
                  final initRoot =
                      initParts.sublist(initParts.length - 2).join('.');
                  if (reqRoot == initRoot) {
                    return NavigationDecision.navigate;
                  }
                }
              }

              // Block all other ad redirects and popup navigations
              log('[UrlWebPage] 🛑 Blocked ad navigation: $reqUrl');
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) {
            if (widget.blockAds) {
              _runAdBlock();
            }
          },
          onPageFinished: (_) {
            if (widget.blockAds) {
              _runAdBlock();
              for (final ms in [500, 1200, 2500, 5000]) {
                Future<void>.delayed(Duration(milliseconds: ms), _runAdBlock);
              }
            }
            if (widget.tryExtractHls && widget.onHlsExtracted != null) {
              _runInterceptHls();
              _runExtractHls();
              for (final ms in [500, 1500, 3500, 6000, 10000]) {
                Future<void>.delayed(
                    Duration(milliseconds: ms), _runExtractHls);
              }
            }
            if (widget.onProgressUpdate != null) {
              _runProgressJs();
              for (final ms in [1000, 2500, 5000]) {
                Future<void>.delayed(
                    Duration(milliseconds: ms), _runProgressJs);
              }
            }
            if (widget.startAtSeconds != null && widget.startAtSeconds! > 3) {
              _runSeekJs();
              for (final ms in [600, 1500, 3000, 5000, 8000]) {
                Future<void>.delayed(
                    Duration(milliseconds: ms), _runSeekJs);
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    log("Web Url :: ${widget.url}");
    final body = Stack(
      children: [
        Builder(builder: (BuildContext context) {
          return WebViewWidget(
            controller: controller,
          );
        }),
      ],
    );
    if (widget.embedded) {
      return body;
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await controller.canGoBack()) {
          controller.goBack();
        } else {
          Get.back();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () async {
              if (await controller.canGoBack()) {
                controller.goBack();
              } else {
                Get.back();
              }
            },
          ),
        ),
        body: body,
      ),
    );
  }
}
