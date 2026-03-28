/// API-driven update info (single source of truth from GET /config).
class AppUpdateInfo {
  final String latestVersion;
  final bool forcedUpdate;
  final String? updateDownloadUrl;
  final String? updateStoreUrl;
  final String? updateChangelog;

  AppUpdateInfo({
    required this.latestVersion,
    required this.forcedUpdate,
    this.updateDownloadUrl,
    this.updateStoreUrl,
    this.updateChangelog,
  });

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

    // Support both old 'forced_update' and new 'is_forced' fields.
    final bool isForced = json['is_forced'] == true ||
        json['is_forced']?.toString().toLowerCase() == 'true' ||
        json['forced_update'] == true ||
        json['forced_update']?.toString().toLowerCase() == 'true';

    return AppUpdateInfo(
      latestVersion: s('latest_version') ?? '',
      forcedUpdate: isForced,
      updateDownloadUrl: s('download_url') ?? s('update_download_url'),
      updateStoreUrl: s('store_url') ?? s('update_store_url'),
      updateChangelog: s('changelog') ?? s('update_changelog'),
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
