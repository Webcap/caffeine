import 'package:cast/cast.dart';
import 'package:flutter/material.dart';

class CastButton extends StatefulWidget {
  const CastButton({super.key});

  @override
  State<CastButton> createState() => _CastButtonState();
}

class _CastButtonState extends State<CastButton> {
  Future<List<CastDevice>>? castSearch;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startSearch();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CastDevice>>(
        future: castSearch,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('ERROR: ${snapshot.error.toString()}');
          } else if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }
        
      );
  }

  void startSearch() {
    castSearch = CastDiscoveryService().search();
  }
}
