import 'package:flutter/material.dart';
import 'package:login/api/endpoints.dart';
import 'package:login/screens/movie_screens/widgets/particular_streaming_service.dart';
import 'package:login/utils/config.dart';

class StreamingServicesMovies extends StatelessWidget {
  final int providerId;
  final String providerName;
  const StreamingServicesMovies(
      {Key? key, required this.providerId, required this.providerName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: maincolor2,
        title: Text(
          'Movies from $providerName',
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: ParticularStreamingServiceMovies(
          providerID: providerId,
          api: Endpoints.watchProvidersMovies(providerId, 1),
        ),
      ),
    );
  }
}
