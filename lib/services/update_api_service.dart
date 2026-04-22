import 'package:reelriot/models/update.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/utils/config_api.dart' as api;

class UpdateApiService {
  Future<AppUpdateInfo> fetchUpdateInfo(AppDependencyProvider provider) {
    return api.fetchUpdateInfoFromApi(provider);
  }
}
