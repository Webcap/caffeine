import 'package:caffiene/utils/helpers/no_connection_screen.dart';
import 'package:caffiene/utils/routes/app_pages.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:data_connection_checker_nulls/data_connection_checker_nulls.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// Check InterNet Connectivity ///
class NetworkStatusService extends GetxService {
  NetworkStatusService() {
    DataConnectionChecker().onStatusChange.listen(
      (status) async {
        _getNetworkStatus(status);
      },
    );
  }

  Future<void> _getNetworkStatus(DataConnectionStatus status) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (auth.currentUser != null) {
      if (connectivityResult == ConnectivityResult.none) {
        Get.offAll(
          () => const NetworkErrorItem(),
        );
      } else {
        Get.offAllNamed(Routes.dash);
      }
    } else {
      if (connectivityResult == ConnectivityResult.none) {
        Get.offAll(
          () => const NetworkErrorItem(),
        );
      } else {
        Get.offAllNamed(Routes.landingScreen);
      } // If internet loss then it will show the NetworkErrorItem widget
    }
  }
}
