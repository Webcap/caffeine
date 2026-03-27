import 'package:open_file/open_file.dart';

class FileOpener {
  Future<OpenResult> open(String path) {
    return OpenFile.open(path);
  }
}
