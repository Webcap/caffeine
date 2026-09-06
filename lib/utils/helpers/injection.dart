import 'package:reelriot/utils/helpers/check_internet.dart';
import 'package:reelriot/services/offline_sync_manager.dart';
import 'package:get/get.dart';

class DependencyInjection {
  static void init() async {
    if (!Get.isRegistered<NetworkStatusService>()) {
      Get.put<NetworkStatusService>(NetworkStatusService(), permanent: true);
    }
    await OfflineSyncManager.instance.init();
  }
}

