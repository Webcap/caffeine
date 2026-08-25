import 'package:reelriot/utils/helpers/no_connection_screen.dart';
import 'package:reelriot/utils/routes/app_pages.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Check InterNet Connectivity ///
class NetworkStatusService extends GetxService {
  bool _wasOffline = false;

  NetworkStatusService() {
    Connectivity().onConnectivityChanged.listen((result) {
      _getNetworkStatus(result);
    });
  }

  Future<void> _getNetworkStatus(List<ConnectivityResult> result) async {
    final isOffline =
        result.length == 1 && result.first == ConnectivityResult.none;

    if (isOffline) {
      if (!_wasOffline) {
        _wasOffline = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => const NetworkErrorItem());
        });
      }
    } else {
      if (_wasOffline) {
        _wasOffline = false;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final auth = Supabase.instance.client.auth;
          if (auth.currentSession == null) {
            // Session may not have finished restoring/refreshing yet right
            // after connectivity returns — give it one chance before
            // concluding the user is actually signed out.
            try {
              await auth.refreshSession();
            } catch (_) {
              // No session to refresh, or refresh failed — fall through to
              // the currentSession check below.
            }
          }
          if (auth.currentSession != null) {
            Get.offAllNamed(Routes.dash);
          } else {
            Get.offAllNamed(Routes.login);
          }
        });
      }
    }
  }
}
