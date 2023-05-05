import 'package:flutter/material.dart';
import 'package:caffiene/api/movies_api.dart';
import 'package:caffiene/models/watch_providers.dart';

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

    moviesApi().fetchWatchProviders(widget.api, widget.country).then((value) {
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
        child: const Text(
          'Watch providers',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
