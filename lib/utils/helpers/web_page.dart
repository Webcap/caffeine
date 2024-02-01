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
  UrlWebPage({super.key, required this.url});

  @override
  _UrlWebPageState createState() => _UrlWebPageState();
}

class _UrlWebPageState extends State<UrlWebPage> {
  late WebViewController controller;

  @override
  Widget build(BuildContext context) {
    log("Web Url :: ${widget.url}");
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
        body: Stack(
          children: [
            Builder(builder: (BuildContext context) {
              return WebView(
                initialUrl: widget.url,
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (controller) {
                  this.controller = controller;
                },
                javascriptChannels: <JavascriptChannel>{
                  _toasterJavascriptChannel(context),
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message.message),
            ),
          );
        });
  }
}
