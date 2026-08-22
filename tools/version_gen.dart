import 'build_number_gen.dart' as build_gen;

/// Legacy entry point: syncs pubspec.yaml version to lib/utils/app_version.g.dart
/// or passes CLI arguments to build_number_gen.
void main(List<String> args) {
  if (args.isEmpty) {
    build_gen.main(['--sync']);
  } else {
    build_gen.main(args);
  }
}
