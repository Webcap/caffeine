import 'package:caffiene/services/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:provider/provider.dart';
import 'package:startapp_sdk/startapp.dart';

class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final remoteAdsEnabled =
        Provider.of<AppDependencyProvider>(context).enableADS;
    final bannerAd = context.watch<AdService>().bannerAd;

    if (remoteAdsEnabled && bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: StartAppBanner(bannerAd),
      );
    }
    return const SizedBox.shrink();
  }
}
