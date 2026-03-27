import 'package:caffiene/utils/helpers/no_connection_screen.dart';
import 'package:caffiene/utils/routes/app_pages.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Check InterNet Connectivity ///
class NetworkStatusService extends GetxService {
  NetworkStatusService() {
    Connectivity().onConnectivityChanged.listen((result) {
      _getNetworkStatus(result);
    });
  }

  Future<void> _getNetworkStatus(List<ConnectivityResult> result) async {
    final auth = Supabase.instance.client.auth;
    final isOffline =
        result.length == 1 && result.first == ConnectivityResult.none;
    if (auth.currentUser != null) {
      if (isOffline) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(
            () => const NetworkErrorItem(),
          );
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed(Routes.dash);
        });
      }
    } else {
      if (isOffline) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(
            () => const NetworkErrorItem(),
          );
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed(Routes.login);
        });
      } // If internet loss then it will show the NetworkErrorItem widget
    }
  }
}
