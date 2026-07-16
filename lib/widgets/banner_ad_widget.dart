import 'package:reelriot/services/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:provider/provider.dart';
import 'package:startapp_sdk/startapp.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  StartAppBannerAd? _bannerAd;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final remoteAdsEnabled =
        Provider.of<AppDependencyProvider>(context).enableADS;
    final adService = Provider.of<AdService>(context);

    if (remoteAdsEnabled &&
        _bannerAd == null &&
        !_loading &&
        adService.isEnabled) {
      _loadAd(adService);
    } else if ((!remoteAdsEnabled || !adService.isEnabled) && _bannerAd != null) {
      setState(() {
        _bannerAd = null;
      });
    }
  }

  Future<void> _loadAd(AdService adService) async {
    _loading = true;
    final ad = await adService.loadNewBannerAd();
    if (mounted) {
      setState(() {
        _bannerAd = ad;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final remoteAdsEnabled =
        Provider.of<AppDependencyProvider>(context).enableADS;
    final adService = Provider.of<AdService>(context);

    if (remoteAdsEnabled && adService.isEnabled && _bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: StartAppBanner(_bannerAd!),
      );
    }
    return const SizedBox.shrink();
  }
}
