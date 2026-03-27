/// Parses a version string (e.g. "1.2.3" or "2.0.0") into comparable segments.
List<int> _parseVersionSegments(String version) {
  if (version.trim().isEmpty) return [0];
  final parts = version.trim().split(RegExp(r'[.\-_+]'));
  return parts.map((s) {
    final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }).toList();
}

/// Compares two version strings. Returns negative if [a] < [b], 0 if equal, positive if [a] > [b].
/// Handles "1.7.1" vs "2.0.0" and "2.0" vs "2.0.0" correctly.
int compareVersions(String a, String b) {
  final sa = _parseVersionSegments(a);
  final sb = _parseVersionSegments(b);
  final len = sa.length > sb.length ? sa.length : sb.length;
  for (var i = 0; i < len; i++) {
    final va = i < sa.length ? sa[i] : 0;
    final vb = i < sb.length ? sb[i] : 0;
    if (va != vb) return va - vb;
  }
  return 0;
}

/// Returns true when [latest] is a newer version than [current].
bool isUpdateAvailable(String current, String latest) {
  if (latest.trim().isEmpty) return false;
  return compareVersions(current, latest) < 0;
}
