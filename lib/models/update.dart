/// API-driven update info (single source of truth from GET /config).
class AppUpdateInfo {
  final String latestVersion;
  final bool forcedUpdate;
  final String? updateDownloadUrl;
  final String? updateStoreUrl;
  final String? updateChangelog;
  final Map<String, String>? downloadUrls;

  AppUpdateInfo({
    required this.latestVersion,
    required this.forcedUpdate,
    this.updateDownloadUrl,
    this.updateStoreUrl,
    this.updateChangelog,
    this.downloadUrls,
  });

  /// Resolves the optimal APK download URL for the user's specific CPU architecture.
  String getBestDownloadUrl({List<String>? supportedAbis}) {
    if (downloadUrls != null && downloadUrls!.isNotEmpty) {
      if (supportedAbis != null && supportedAbis.isNotEmpty) {
        for (final rawAbi in supportedAbis) {
          final normalized = rawAbi.toLowerCase().replaceAll('-', '_');
          if (downloadUrls!.containsKey(normalized) &&
              downloadUrls![normalized] != null &&
              downloadUrls![normalized]!.trim().isNotEmpty) {
            return downloadUrls![normalized]!.trim();
          }
        }
      }
      if (downloadUrls!['primary']?.trim().isNotEmpty == true) {
        return downloadUrls!['primary']!.trim();
      }
      if (downloadUrls!['arm64_v8a']?.trim().isNotEmpty == true) {
        return downloadUrls!['arm64_v8a']!.trim();
      }
      if (downloadUrls!['universal']?.trim().isNotEmpty == true) {
        return downloadUrls!['universal']!.trim();
      }
    }
    return updateDownloadUrl ?? '';
  }

  /// From API config JSON (e.g. GET /config or GET /v1/updates).
  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    String? s(String key) {
      final v = json[key];
      if (v == null) {
        return null;
      }
      final t = v.toString().trim();
      return t.isEmpty ? null : t;
    }

    Map<String, String>? parseUrls(dynamic val) {
      if (val is Map) {
        final res = <String, String>{};
        val.forEach((k, v) {
          if (k != null && v != null && v.toString().trim().isNotEmpty) {
            res[k.toString().toLowerCase().replaceAll('-', '_')] = v.toString().trim();
          }
        });
        return res.isNotEmpty ? res : null;
      }
      return null;
    }

    // Support both old 'forced_update' and new 'is_forced' fields.
    final bool isForced = json['is_forced'] == true ||
        json['is_forced']?.toString().toLowerCase() == 'true' ||
        json['forced_update'] == true ||
        json['forced_update']?.toString().toLowerCase() == 'true';

    final urlsMap = parseUrls(json['download_urls']) ?? parseUrls(json['update_download_urls']);

    return AppUpdateInfo(
      latestVersion: s('latest_version') ?? '',
      forcedUpdate: isForced,
      updateDownloadUrl: s('download_url') ?? s('update_download_url'),
      updateStoreUrl: s('store_url') ?? s('update_store_url'),
      updateChangelog: s('changelog') ?? s('update_changelog'),
      downloadUrls: urlsMap,
    );
  }
}

/// Legacy model for external update.json (deprecated; prefer AppUpdateInfo from API).
class UpdateChecker {
  String? versionNumber;
  String? downloadLink;
  String? changeLog;
  UpdateChecker({this.changeLog, this.downloadLink, this.versionNumber});

  UpdateChecker.fromJson(Map<String, dynamic> json) {
    changeLog = json['changelog'];
    downloadLink = json['downloadlink'];
    versionNumber = json['versionnumber'];
  }
}
