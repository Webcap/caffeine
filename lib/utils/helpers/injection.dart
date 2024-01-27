import 'package:caffiene/utils/helpers/check_internet.dart';
import 'package:get/get.dart';

class DependencyInjection {
  static void init() async {
    //services
    Get.put<NetworkStatusService>(NetworkStatusService(), permanent: true);
  }
}
