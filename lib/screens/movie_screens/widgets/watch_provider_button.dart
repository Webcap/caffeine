import 'package:caffiene/functions/network.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/models/watch_providers.dart';
import 'package:provider/provider.dart';

class WatchProvidersButton extends StatefulWidget {
  final Function()? onTap;
  final String api;
  final String country;
  const WatchProvidersButton({
    Key? key,
    this.onTap,
    required this.api,
    required this.country,
  }) : super(key: key);

  @override
  State<WatchProvidersButton> createState() => _WatchProvidersButtonState();
}

class _WatchProvidersButtonState extends State<WatchProvidersButton> {
  WatchProviders? watchProviders;
  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchWatchProviders(widget.api, widget.country, isProxyEnabled, proxyUrl)
        .then((value) {
      if (mounted) {
        setState(() {
          watchProviders = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            maximumSize: MaterialStateProperty.all(const Size(200, 60)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    )))),
        onPressed: () {
          widget.onTap!();
        },
        child: Text(
          tr("watch_providers"),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
