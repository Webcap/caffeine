import 'package:caffiene/models/update.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/utils/config_api.dart' as api;

class UpdateApiService {
  Future<AppUpdateInfo> fetchUpdateInfo(AppDependencyProvider provider) {
    return api.fetchUpdateInfoFromApi(provider);
  }
}
