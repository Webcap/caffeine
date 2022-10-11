import 'package:flutter/material.dart';
import 'package:login/utils/config.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';


class MixpanelProvider with ChangeNotifier {
  late Mixpanel mixpanel;

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init(mixpanelKey,
        optOutTrackingDefault: false, trackAutomaticEvents: true);
    notifyListeners();
  }
}
