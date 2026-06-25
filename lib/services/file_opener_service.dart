import 'package:open_file/open_file.dart';
import 'package:install_plugin_v2/install_plugin_v2.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

class FileOpener {
  Future<dynamic> open(String path, {String? type}) async {
    if (Platform.isAndroid && path.toLowerCase().endsWith('.apk')) {
      final info = await PackageInfo.fromPlatform();
      return InstallPlugin.installApk(path, info.packageName);
    }
    return OpenFile.open(path, type: type);
  }
}
