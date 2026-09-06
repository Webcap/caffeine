import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reelriot/services/offline_sync_manager.dart';

/// Service that monitors network connectivity non-destructively,
/// exposing reactive state for UI indicators and auto-flushing offline mutations.
class NetworkStatusService extends GetxService {
  final RxBool isOffline = false.obs;
  final RxBool isReconnecting = false.obs;
  bool _wasOffline = false;

  NetworkStatusService() {
    Connectivity().onConnectivityChanged.listen((result) {
      _getNetworkStatus(result);
    });
  }

  Future<void> _getNetworkStatus(List<ConnectivityResult> result) async {
    final offline =
        result.length == 1 && result.first == ConnectivityResult.none;

    if (offline) {
      if (!_wasOffline) {
        _wasOffline = true;
        isOffline.value = true;
        isReconnecting.value = false;
        debugPrint('[NetworkStatusService] Device transitioned to OFFLINE mode.');
      }
    } else {
      if (_wasOffline) {
        _wasOffline = false;
        isOffline.value = false;
        isReconnecting.value = true;
        debugPrint('[NetworkStatusService] Device regained connectivity. Syncing...');

        // Quietly refresh session without disrupting the user's active screen
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final auth = Supabase.instance.client.auth;
          if (auth.currentSession == null) {
            try {
              await auth.refreshSession();
            } catch (_) {
              // Refresh failed or no session; user remains on current view
            }
          }

          // Automatically flush any pending actions queued while offline
          try {
            await OfflineSyncManager.instance.flushPendingActions();
          } catch (e) {
            debugPrint('[NetworkStatusService] Error flushing offline actions: $e');
          }

          // Dismiss reconnecting banner after 3 seconds
          await Future.delayed(const Duration(seconds: 3));
          isReconnecting.value = false;
        });
      }
    }
  }
}

