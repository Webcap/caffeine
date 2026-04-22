import 'package:open_file/open_file.dart';

class FileOpener {
  Future<OpenResult> open(String path, {String? type}) {
    return OpenFile.open(path, type: type);
  }
}
