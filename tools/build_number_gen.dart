// ignore_for_file: avoid_print
import 'dart:io';

/// Build Number & Version Generator for ReelRiot Mobile.
///
/// Features:
/// - Auto-increment build number (+1)
/// - CalVer (YYYY.MM.DD) or custom SemVer version name
/// - Git commit-count based build number
/// - Timestamp based build number
/// - Updates pubspec.yaml and generates lib/utils/app_version.g.dart
///
/// Usage:
///   dart run tools/build_number_gen.dart                 # Updates date to today & increments build number
///   dart run tools/build_number_gen.dart --git           # Updates date to today & sets build number to git commit count
///   dart run tools/build_number_gen.dart --timestamp     # Sets build number to YYMMddHHmm
///   dart run tools/build_number_gen.dart --build 1750    # Sets build number explicitly
///   dart run tools/build_number_gen.dart --version 2.0.0 # Sets version name explicitly
///   dart run tools/build_number_gen.dart --no-date       # Keeps current version name, only increments build number
///   dart run tools/build_number_gen.dart --sync          # Only syncs pubspec.yaml version to app_version.g.dart
///   dart run tools/build_number_gen.dart --dry-run       # Previews output without writing files

void main(List<String> args) {
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    stderr.writeln('Error: pubspec.yaml not found. Please run from the project root.');
    exit(1);
  }

  final pubspecContent = pubspecFile.readAsStringSync();
  final versionRegex = RegExp(r'^version:\s*([^\s+]+)(?:\+(\d+))?', multiLine: true);
  final match = versionRegex.firstMatch(pubspecContent);

  if (match == null) {
    stderr.writeln('Error: Could not find valid "version:" entry in pubspec.yaml');
    exit(1);
  }

  final currentVersionName = match.group(1) ?? '1.0.0';
  final currentBuildNumber = int.tryParse(match.group(2) ?? '1') ?? 1;

  // Parse arguments
  bool isDryRun = args.contains('--dry-run');
  bool isSyncOnly = args.contains('--sync') || args.contains('--sync-only');
  bool useGit = args.contains('--git');
  bool useTimestamp = args.contains('--timestamp');
  bool noDate = args.contains('--no-date');

  String? customVersion;
  int? customBuild;

  for (int i = 0; i < args.length; i++) {
    if (args[i] == '--version' || args[i] == '-v') {
      if (i + 1 < args.length) customVersion = args[i + 1];
    } else if (args[i] == '--build' || args[i] == '-b') {
      if (i + 1 < args.length) customBuild = int.tryParse(args[i + 1]);
    } else if (args[i] == '--help' || args[i] == '-h') {
      _printHelp();
      return;
    }
  }

  if (isSyncOnly) {
    final fullVersion = match.group(2) != null
        ? '$currentVersionName+$currentBuildNumber'
        : currentVersionName;
    _writeGeneratedDartFile(fullVersion, isDryRun);
    print('Synced current version ($fullVersion) to lib/utils/app_version.g.dart');
    return;
  }

  // Calculate new version name
  String newVersionName;
  if (customVersion != null) {
    newVersionName = customVersion;
  } else if (!noDate) {
    final now = DateTime.now();
    final yyyy = now.year.toString();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    newVersionName = '$yyyy.$mm.$dd';
  } else {
    newVersionName = currentVersionName;
  }

  // Calculate new build number
  int newBuildNumber;
  if (customBuild != null) {
    newBuildNumber = customBuild;
  } else if (useGit) {
    newBuildNumber = _getGitCommitCount() ?? (currentBuildNumber + 1);
  } else if (useTimestamp) {
    final now = DateTime.now();
    // Android versionCode limit is 2,100,000,000 (signed 32-bit int).
    // Using single-digit year (e.g. 6 for 2026) -> 6MMddHHmm (e.g. 608231355) fits safely within 32-bit limit.
    final y = (now.year % 10).toString();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    final hh = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    newBuildNumber = int.tryParse('$y$mm$dd$hh$min') ?? (currentBuildNumber + 1);
  } else {
    newBuildNumber = currentBuildNumber + 1;
  }

  final newFullVersion = '$newVersionName+$newBuildNumber';
  final oldFullVersion = '$currentVersionName+$currentBuildNumber';

  print('========================================');
  print('ReelRiot Mobile Build Generator');
  print('========================================');
  print('Previous Version : $oldFullVersion');
  print('New Version      : $newFullVersion');
  print('Version Name     : $newVersionName');
  print('Build Number     : $newBuildNumber');
  print('Dry Run          : $isDryRun');
  print('========================================');

  if (isDryRun) {
    print('[Dry Run] No files modified.');
    return;
  }

  // 1. Update pubspec.yaml
  final updatedPubspec = pubspecContent.replaceFirst(
    versionRegex,
    'version: $newFullVersion',
  );
  pubspecFile.writeAsStringSync(updatedPubspec);
  print('Updated pubspec.yaml -> version: $newFullVersion');

  // 2. Generate lib/utils/app_version.g.dart
  _writeGeneratedDartFile(newFullVersion, false);
  print('Updated lib/utils/app_version.g.dart');
  print('\nSuccess! Build version set to $newFullVersion');
}

void _writeGeneratedDartFile(String version, bool dryRun) {
  if (dryRun) return;
  final out = File('lib/utils/app_version.g.dart');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(
    "// Generated by tools/build_number_gen.dart – do not edit.\n"
    "part of 'config.dart';\n\n"
    "const String currentAppVersion = '$version';\n",
  );
}

int? _getGitCommitCount() {
  try {
    final result = Process.runSync('git', ['rev-list', '--count', 'HEAD']);
    if (result.exitCode == 0) {
      return int.tryParse(result.stdout.toString().trim());
    }
  } catch (_) {}
  return null;
}

void _printHelp() {
  print('''
ReelRiot Mobile Build Number & Version Generator

Usage:
  dart run tools/build_number_gen.dart [options]

Options:
  --help, -h          Show this help message
  --dry-run           Preview version changes without writing to files
  --sync              Sync pubspec.yaml version into app_version.g.dart without incrementing
  --no-date           Do not update the version name with today's date (keeps existing name)
  --version, -v <val> Specify custom version name (e.g. 2026.08.22 or 1.2.0)
  --build, -b <num>   Specify custom build number integer (e.g. 1720)
  --git               Use git commit count as build number
  --timestamp         Use timestamp (YYMMddHHmm) as build number

Default behavior (no args):
  Updates version date to today (YYYY.MM.DD) and increments build number by +1.
''');
}
