import 'package:open_file/open_file.dart';
import 'package:flutter_app_installer/flutter_app_installer.dart';
import 'dart:io';

class FileOpener {
  final FlutterAppInstaller _appInstaller = FlutterAppInstaller();

  Future<dynamic> open(String path, {String? type}) async {
    if (Platform.isAndroid && path.toLowerCase().endsWith('.apk')) {
      return _appInstaller.installApk(filePath: path);
    }
    return OpenFile.open(path, type: type);
  }
}
