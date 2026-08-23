import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Synchronizes release metadata and download URLs directly to the ReelRiot Update Center (Supabase / Caffeine API).
Future<void> main(List<String> args) async {
  final options = _parseArgs(args);
  final projectRoot = _getProjectRoot();

  final envMap = _loadEnv(projectRoot);

  final supabaseUrl = options['supabase-url'] ?? envMap['SUPABASE_URL'];
  final serviceRoleKey = options['service-key'] ?? envMap['SUPABASE_SERVICE_ROLE_KEY'];
  final caffeineApiUrl = options['caffeine-api-url'] ?? envMap['CAFFEINE_API_URL'];
  final caffeineApiKey = options['caffeine-api-key'] ?? envMap['CAFFEINE_API_KEY'];

  final platform = (options['platform'] ?? 'android').toLowerCase();
  var environment = (options['environment'] ?? 'production').toLowerCase();
  if (environment == 'prod') environment = 'production';
  if (environment == 'dev') environment = 'development';

  final version = options['version'] ?? _getVersionFromPubspec(projectRoot);
  final versionClean = version.replaceAll('+', '_');
  final repoName = options['repo'] ?? envMap['GITHUB_REPOSITORY'] ?? 'Webcap/reelriot';

  // Enforce Universal APK link for the update center
  String downloadUrl = options['download-url'] ?? '';
  if (downloadUrl.isEmpty) {
    downloadUrl = 'https://github.com/$repoName/releases/download/v$version/ReelRiot-$environment-v$versionClean-universal.apk';
  }

  final storeUrl = options['store-url'] ??
      (platform == 'android' ? 'https://play.google.com/store/apps/details?id=media.webcap.reelriot' : '');
  final isForced = options['forced'] == 'true' || options['forced'] == true;

  String changelog = '';
  if (options['changelog-file'] != null) {
    final file = File(options['changelog-file']);
    if (file.existsSync()) {
      changelog = file.readAsStringSync();
    }
  } else if (options['changelog'] != null) {
    changelog = options['changelog'];
  }

  stdout.writeln('======================================================');
  stdout.writeln('         Syncing to ReelRiot Update Center            ');
  stdout.writeln('======================================================');
  stdout.writeln(' Platform   : $platform');
  stdout.writeln(' Environment: $environment');
  stdout.writeln(' Version    : $version');
  stdout.writeln(' Package    : Universal APK (All ABIs)');
  stdout.writeln(' DownloadUrl: $downloadUrl');
  stdout.writeln(' Forced     : $isForced');
  stdout.writeln('======================================================');

  bool synced = false;

  // 1. Primary Sync: Supabase Direct Upsert (Single source of truth)
  if (supabaseUrl != null && serviceRoleKey != null && supabaseUrl.isNotEmpty && serviceRoleKey.isNotEmpty) {
    try {
      final sanitizedBaseUrl = supabaseUrl.endsWith('/') ? supabaseUrl.substring(0, supabaseUrl.length - 1) : supabaseUrl;
      final uri = Uri.parse('$sanitizedBaseUrl/rest/v1/app_updates?on_conflict=platform,environment');

      final headers = <String, String>{
        'apikey': serviceRoleKey,
        'Authorization': 'Bearer $serviceRoleKey',
        'Content-Type': 'application/json',
        'Prefer': 'resolution=merge-duplicates,return=representation',
      };

      final payload = jsonEncode({
        'platform': platform,
        'environment': environment,
        'latest_version': version,
        'is_forced': isForced,
        'rollout_percentage': 100,
        'download_url': downloadUrl,
        'store_url': storeUrl,
        'changelog': changelog,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });

      final response = await http.post(uri, headers: headers, body: payload);

      if (response.statusCode == 200 || response.statusCode == 201) {
        stdout.writeln('✓ Successfully updated app_updates table in Supabase.');
        synced = true;

        // Record history entry
        try {
          final historyUri = Uri.parse('$sanitizedBaseUrl/rest/v1/app_update_history');
          final historyPayload = jsonEncode({
            'platform': platform,
            'environment': environment,
            'version': version,
            'is_forced': isForced,
            'rollout_percentage': 100,
            'changelog': changelog,
          });
          await http.post(historyUri, headers: headers, body: historyPayload);
          stdout.writeln('✓ Successfully recorded deployment entry in app_update_history.');
        } catch (_) {}
      } else {
        stdout.writeln('⚠️ Supabase sync returned status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      stdout.writeln('⚠️ Supabase direct update failed: $e');
    }
  }

  // 2. Secondary Sync: Caffeine API /admin/updates (if available)
  if (!synced && caffeineApiUrl != null && caffeineApiKey != null && caffeineApiUrl.isNotEmpty) {
    try {
      final sanitizedBaseUrl = caffeineApiUrl.endsWith('/') ? caffeineApiUrl.substring(0, caffeineApiUrl.length - 1) : caffeineApiUrl;
      final uri = Uri.parse('$sanitizedBaseUrl/admin/updates');

      final headers = <String, String>{
        'x-api-key': caffeineApiKey,
        'Content-Type': 'application/json',
      };

      final payload = jsonEncode({
        'platform': platform,
        'environment': environment,
        'latest_version': version,
        'is_forced': isForced,
        'rollout_percentage': 100,
        'download_url': downloadUrl,
        'store_url': storeUrl,
        'changelog': changelog,
      });

      final response = await http.post(uri, headers: headers, body: payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        stdout.writeln('✓ Successfully updated Caffeine API update center.');
        synced = true;
      } else {
        stdout.writeln('⚠️ Caffeine API returned status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      stdout.writeln('⚠️ Caffeine API update failed: $e');
    }
  }

  if (synced) {
    stdout.writeln('🚀 Update Center is now pointing users to version $version.');
  } else {
    stdout.writeln('ℹ️ Update center sync completed with warnings or missing credentials.');
  }
}

Map<String, dynamic> _parseArgs(List<String> args) {
  final map = <String, dynamic>{};
  for (int i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg.startsWith('--') && i + 1 < args.length) {
      final key = arg.substring(2);
      map[key] = args[++i];
    }
  }
  return map;
}

String _getProjectRoot() {
  final scriptDir = File(Platform.script.toFilePath()).parent;
  return scriptDir.parent.path;
}

Map<String, String> _loadEnv(String projectRoot) {
  final envFile = File('$projectRoot/.env');
  final map = <String, String>{};
  if (envFile.existsSync()) {
    for (final line in envFile.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final eq = trimmed.indexOf('=');
      if (eq > 0) {
        map[trimmed.substring(0, eq).trim()] = trimmed.substring(eq + 1).trim();
      }
    }
  }
  return map;
}

String _getVersionFromPubspec(String projectRoot) {
  final pubspec = File('$projectRoot/pubspec.yaml');
  if (pubspec.existsSync()) {
    final match = RegExp(r'^version:\s*([^\r\n]+)', multiLine: true)
        .firstMatch(pubspec.readAsStringSync());
    if (match != null) {
      return match.group(1)!.trim();
    }
  }
  return 'unreleased';
}
