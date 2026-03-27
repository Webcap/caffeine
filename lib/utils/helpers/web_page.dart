// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

// class UrlWebPage extends StatefulWidget {
//   String url;
//   UrlWebPage({super.key, required this.url});

//   @override
//   _UrlWebPageState createState() => _UrlWebPageState();
// }

// class _UrlWebPageState extends State<UrlWebPage> {
//   late final WebViewController _controller;

//   @override
//   void initState() {
//     super.initState();

//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..loadRequest(Uri.parse(widget.url))
//       ..addJavaScriptChannel(
//         'Toaster',
//         onMessageReceived: (JavaScriptMessage message) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(message.message)),
//           );
//         },
//       );
//   }

//   @override
//   Widget build(BuildContext context) {
//     log("Web Url :: ${widget.url}");
//     return WillPopScope(
//       onWillPop: () async {
//         if (await _controller.canGoBack()) {
//           _controller.goBack();
//         } else {
//           Get.back();
//         }
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(
//               Icons.arrow_back,
//             ),
//             onPressed: () async {
//               if (await _controller.canGoBack()) {
//                 _controller.goBack();
//               } else {
//                 Get.back();
//               }
//             },
//           ),
//         ),
//         body: Stack(
//           children: [
//             Builder(builder: (BuildContext context) {
//               return WebViewWidget(
//                 controller: _controller,
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }
// }

class UrlWebPage extends StatefulWidget {
  String url;

  /// When true, only the WebView is shown (no AppBar). Use when embedding inside another screen (e.g. live event default view).
  final bool embedded;

  /// When true, injects JS to hide ads and trigger video play (for stream embeds).
  final bool blockAds;

  /// When true, runs JS to extract HLS (m3u8) from the page and calls [onHlsExtracted]. Runs on load and retries.
  final bool tryExtractHls;

  /// Called when HLS URL is extracted via JS (only if [tryExtractHls] is true).
  final void Function(String hls)? onHlsExtracted;

  UrlWebPage({
    super.key,
    required this.url,
    this.embedded = false,
    this.blockAds = false,
    this.tryExtractHls = false,
    this.onHlsExtracted,
  });

  @override
  _UrlWebPageState createState() => _UrlWebPageState();
}

class _UrlWebPageState extends State<UrlWebPage> {
  late final WebViewController controller;

  static const String _adBlockJs = r'''
    (function() {
      var hide = function(sel) { try { document.querySelectorAll(sel).forEach(function(el){ el.style.display='none'; el.remove(); }); } catch(e){} };
      hide('[id*="ad"]'); hide('[class*="ad"]'); hide('.adsbygoogle'); hide('ins.adsbygoogle');
      hide('iframe[src*="doubleclick"]'); hide('iframe[src*="googlesyndication"]'); hide('iframe[src*="ads"]');
      hide('.ad-overlay'); hide('.ad-container'); hide('.ad-overlay-alt'); hide('[class*="overlay"][class*="ad"]');
      document.querySelectorAll('button, [role="button"], a').forEach(function(el){
        var t = (el.textContent||'').toLowerCase(); var c = (el.className||'')+''; var id = (el.id||'')+'';
        if(/close|skip|play|dismiss|x/.test(t) || /close|skip|dismiss/.test(c+id)) el.click();
      });
      document.querySelectorAll('video').forEach(function(v){ v.muted=false; v.play().catch(function(){}); });
      document.querySelectorAll('[class*="play"], .vjs-big-play-button').forEach(function(b){ b.click(); });
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

  void _runAdBlock() {
    if (!mounted || !widget.blockAds) return;
    controller.runJavaScript(_adBlockJs);
  }

  void _runInterceptHls() {
    if (!mounted || !widget.tryExtractHls || widget.onHlsExtracted == null)
      return;
    controller.runJavaScript(_interceptHlsJs);
  }

  void _runExtractHls() {
    if (!mounted || !widget.tryExtractHls || widget.onHlsExtracted == null)
      return;
    controller.runJavaScript(_extractHlsJs);
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
          onPageFinished: (_) {
            if (widget.blockAds) {
              _runAdBlock();
              for (final ms in [800, 2000, 4000]) {
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
    return WillPopScope(
      onWillPop: () async {
        if (await controller.canGoBack()) {
          controller.goBack();
        } else {
          Get.back();
        }
        return false;
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
