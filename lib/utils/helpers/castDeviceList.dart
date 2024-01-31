import 'package:cast/cast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CastDeviceList extends StatefulWidget {
  @override
  _CastDeviceListState createState() => _CastDeviceListState();
}

class _CastDeviceListState extends State<CastDeviceList> {
  // This function returns a Future<List<CastDevice>> value
  // It uses the CastDiscoveryService to search for cast devices
  Future<List<CastDevice>> _searchCastDevices() async {
    return CastDiscoveryService().search();
  }

  // This function takes a context and a device as parameters
  // It connects to the device and launches the app
  Future<void> _connectToYourApp(
      BuildContext context, CastDevice object) async {
    final session = await CastSessionManager().startSession(object);

    session.stateStream.listen((state) {
      if (state == CastSessionState.connected) {
        final snackBar = SnackBar(content: Text('Connected'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        _sendMessageToYourApp(session);
      }
    });

    session.messageStream.listen((message) {
      print('receive message: $message');
    });

    session.sendMessage(CastSession.kNamespaceReceiver, {
      'type': 'LAUNCH',
      'appId': 'Youtube', // set the appId of your app here
    });
  }

  void _sendMessageToYourApp(CastSession session) {
    print('_sendMessageToYourApp');

    session.sendMessage('urn:x-cast:namespace-of-the-app', {
      'type': 'sample',
    });
  }

  Future<void> _connectAndPlayMedia(
      BuildContext context, CastDevice object) async {
    final session = await CastSessionManager().startSession(object);

    session.stateStream.listen((state) {
      if (state == CastSessionState.connected) {
        Get.back();
        final snackBar = SnackBar(content: Text('Connected'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });

    var index = 0;

    session.messageStream.listen((message) {
      index += 1;

      print('receive message: $message');

      if (index == 2) {
        Future.delayed(Duration(seconds: 5)).then((x) {
          _sendMessagePlayVideo(session);
        });
      }
    });

    session.sendMessage(CastSession.kNamespaceReceiver, {
      'type': 'LAUNCH',
      'appId': 'CC1AD845', // set the appId of your app here
    });
  }

  void _sendMessagePlayVideo(CastSession session) {
    print('_sendMessagePlayVideo');

    var message = {
      // Here you can plug an URL to any mp4, webm, mp3 or jpg file with the proper contentType.
      'contentId':
          'http://commondatastorage.googleapis.com/gtv-videos-bucket/big_buck_bunny_1080p.mp4',
      'contentType': 'video/mp4',
      'streamType': 'BUFFERED', // or LIVE

      // Title and cover displayed while buffering
      'metadata': {
        'type': 0,
        'metadataType': 0,
        'title': "Big Buck Bunny",
        'images': [
          {
            'url':
                'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg'
          }
        ]
      }
    };

    session.sendMessage(CastSession.kNamespaceMedia, {
      'type': 'LOAD',
      'autoPlay': true,
      'currentTime': 0,
      'media': message,
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CastDevice>>(
      future: _searchCastDevices(), // async work
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // If the future has an error, return a widget to show the error
          return Center(
            child: Text(
              'Error: ${snapshot.error.toString()}',
            ),
          );
        } else if (!snapshot.hasData) {
          // If the future has no data, return a widget to show the loading state
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data!.isEmpty) {
          // If the future has an empty list, return a widget to show no devices found
          return const Column(
            children: [
              Center(
                child: Text(
                  'No Chromecast founded',
                ),
              ),
            ],
          );
        }

        // If the future has a non-empty list, return a widget to show the list of devices
        return Column(
          children: snapshot.data!.map((device) {
            return ListTile(
              title: Text(device.name),
              enableFeedback: true,
              splashColor: Colors.blueAccent,
              onTap: () {
                _connectAndPlayMedia(context, device);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
