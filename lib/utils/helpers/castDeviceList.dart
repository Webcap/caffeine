import 'package:cast/cast.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  // void _connectToYourApp(BuildContext context, CastDevice device) {
  //   // Connect to the device
  //   CastService().connect(device);
  //   // Launch the app
  //   CastService().launchApp();
  //   // Show a snackbar message
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('Connected to ${device.name}'),
  //     ),
  //   );
  // }

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
              onTap: () {
              // _connectToYourApp(context, device);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
