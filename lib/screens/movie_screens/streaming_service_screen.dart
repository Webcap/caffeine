import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/movie_screens/widgets/particular_streaming_service.dart';
import 'package:provider/provider.dart';

class StreamingServicesMovies extends StatelessWidget {
  final int providerId;
  final String providerName;
  const StreamingServicesMovies(
      {Key? key, required this.providerId, required this.providerName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr("streaming_service_movie", namedArgs: {"provider": providerName}),
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
          includeAdult: Provider.of<SettingsProvider>(context).isAdult,
          providerID: providerId,
          api: Endpoints.watchProvidersMovies(providerId, 1, lang),
          watchRegion: Provider.of<SettingsProvider>(context).defaultCountry,
        ),
      ),
    );
  }
}
