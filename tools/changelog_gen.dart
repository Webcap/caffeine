import 'dart:io';

/// Automatic Changelog Generator based on Git commits.
/// Categorizes Conventional Commits into structured markdown sections.
void main(List<String> args) {
  final options = _parseArgs(args);
  final projectRoot = _getProjectRoot();

  // 1. Resolve target version
  final version = options['version'] ?? _getVersionFromPubspec(projectRoot);
  final dateStr = _getCurrentDateFormatted();

  // 2. Resolve commit range (from last tag to HEAD)
  final since = options['since'] ?? _getLatestTag();
  final gitRange = since.isNotEmpty ? '$since..HEAD' : 'HEAD';

  // 3. Fetch commits
  final commits = _fetchGitCommits(gitRange);

  if (commits.isEmpty) {
    stdout.writeln('No new commits found since $since.');
    if (options['stdout'] == true) {
      stdout.writeln('No changes detected in range $gitRange.');
    }
    return;
  }

  // 4. Categorize and build changelog markdown
  final changelogMarkdown = _buildChangelog(version, dateStr, commits);

  // 5. Output handling
  if (options['stdout'] == true || (options['write'] != true && options['output'] == null)) {
    stdout.writeln(changelogMarkdown);
  }

  if (options['output'] != null) {
    final outPath = options['output'] as String;
    File(outPath).writeAsStringSync(changelogMarkdown);
    stdout.writeln('✓ Changelog written to $outPath');
  }

  if (options['write'] == true) {
    _prependToChangelogFile(projectRoot, changelogMarkdown);
    stdout.writeln('✓ CHANGELOG.md updated successfully for version $version');
  }
}

class _Commit {
  final String hash;
  final String author;
  final String message;

  _Commit({required this.hash, required this.author, required this.message});
}

Map<String, dynamic> _parseArgs(List<String> args) {
  final map = <String, dynamic>{};
  for (int i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--write') {
      map['write'] = true;
    } else if (arg == '--stdout') {
      map['stdout'] = true;
    } else if (arg == '--since' && i + 1 < args.length) {
      map['since'] = args[++i];
    } else if (arg == '--output' && i + 1 < args.length) {
      map['output'] = args[++i];
    } else if (arg == '--version' && i + 1 < args.length) {
      map['version'] = args[++i];
    }
  }
  return map;
}

String _getProjectRoot() {
  final scriptDir = File(Platform.script.toFilePath()).parent;
  return scriptDir.parent.path;
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

String _getCurrentDateFormatted() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

String _getLatestTag() {
  try {
    final result = Process.runSync('git', ['describe', '--tags', '--abbrev=0']);
    if (result.exitCode == 0) {
      return (result.stdout as String).trim();
    }
  } catch (_) {}
  return '';
}

List<_Commit> _fetchGitCommits(String range) {
  try {
    final args = ['log', range, '--pretty=format:%h|||%an|||%s', '--no-merges'];
    final result = Process.runSync('git', args);
    if (result.exitCode != 0) {
      // Fallback to all commits if tag range fails
      final fallbackResult = Process.runSync('git', ['log', '-n', '30', '--pretty=format:%h|||%an|||%s', '--no-merges']);
      if (fallbackResult.exitCode != 0) return [];
      return _parseCommitLines(fallbackResult.stdout as String);
    }
    return _parseCommitLines(result.stdout as String);
  } catch (_) {
    return [];
  }
}

List<_Commit> _parseCommitLines(String raw) {
  final lines = raw.split('\n').where((l) => l.trim().isNotEmpty);
  final commits = <_Commit>[];
  for (final line in lines) {
    final parts = line.split('|||');
    if (parts.length >= 3) {
      commits.add(_Commit(
        hash: parts[0].trim(),
        author: parts[1].trim(),
        message: parts[2].trim(),
      ));
    }
  }
  return commits;
}

String _buildChangelog(String version, String dateStr, List<_Commit> commits) {
  final features = <String>[];
  final fixes = <String>[];
  final improvements = <String>[];
  final maintenance = <String>[];
  final other = <String>[];

  for (final commit in commits) {
    final msg = commit.message.trim();
    if (msg.isEmpty || msg.startsWith('Merge ') || msg.startsWith('chore(release)')) continue;

    final lower = msg.toLowerCase();
    final formattedLine = '- ${_cleanMessage(msg)} (`${commit.hash}`)';

    if (lower.startsWith('feat:') || lower.startsWith('feat(') || lower.startsWith('feature:')) {
      features.add(formattedLine);
    } else if (lower.startsWith('fix:') || lower.startsWith('fix(') || lower.startsWith('bugfix:')) {
      fixes.add(formattedLine);
    } else if (lower.startsWith('perf:') || lower.startsWith('optimize:') || lower.startsWith('ui:') || lower.startsWith('refactor:')) {
      improvements.add(formattedLine);
    } else if (lower.startsWith('chore:') || lower.startsWith('ci:') || lower.startsWith('build:') || lower.startsWith('test:')) {
      maintenance.add(formattedLine);
    } else {
      // Intelligently classify by keywords
      if (lower.contains('add ') || lower.contains('new ') || lower.contains('support ')) {
        features.add(formattedLine);
      } else if (lower.contains('fix ') || lower.contains('resolve ') || lower.contains('prevent ') || lower.contains('correct ')) {
        fixes.add(formattedLine);
      } else if (lower.contains('update ') || lower.contains('improve ') || lower.contains('clean ') || lower.contains('modernize ')) {
        improvements.add(formattedLine);
      } else {
        other.add(formattedLine);
      }
    }
  }

  final buffer = StringBuffer();
  buffer.writeln('## [$version] - $dateStr\n');

  if (features.isNotEmpty) {
    buffer.writeln('### 🚀 Features & Additions');
    for (final f in features) {
      buffer.writeln(f);
    }
    buffer.writeln();
  }

  if (fixes.isNotEmpty) {
    buffer.writeln('### 🐛 Bug Fixes');
    for (final f in fixes) {
      buffer.writeln(f);
    }
    buffer.writeln();
  }

  if (improvements.isNotEmpty) {
    buffer.writeln('### ⚡ Improvements & Optimizations');
    for (final i in improvements) {
      buffer.writeln(i);
    }
    buffer.writeln();
  }

  if (maintenance.isNotEmpty) {
    buffer.writeln('### 🔧 Maintenance & Infrastructure');
    for (final m in maintenance) {
      buffer.writeln(m);
    }
    buffer.writeln();
  }

  if (other.isNotEmpty) {
    buffer.writeln('### 📦 General Updates');
    for (final o in other) {
      buffer.writeln(o);
    }
    buffer.writeln();
  }

  return buffer.toString().trimRight();
}

String _cleanMessage(String raw) {
  // Strip conventional prefixes if present for cleaner reading
  var clean = raw;
  final prefixes = [
    RegExp(r'^(feat|fix|chore|perf|refactor|docs|style|test|build|ci)(\([^\)]+\))?:\s*', caseSensitive: false),
  ];
  for (final prefix in prefixes) {
    clean = clean.replaceFirst(prefix, '');
  }

  if (clean.isNotEmpty) {
    // Capitalize first letter
    clean = clean[0].toUpperCase() + clean.substring(1);
  }
  return clean;
}

void _prependToChangelogFile(String projectRoot, String newSection) {
  final changelogFile = File('$projectRoot/CHANGELOG.md');
  if (!changelogFile.existsSync()) {
    changelogFile.writeAsStringSync('# Changelog\n\n$newSection\n');
    return;
  }

  final content = changelogFile.readAsStringSync();
  final headerPattern = RegExp(r'^# Changelog\s*', multiLine: true);
  if (headerPattern.hasMatch(content)) {
    final updated = content.replaceFirst(headerPattern, '# Changelog\n\n$newSection\n\n');
    changelogFile.writeAsStringSync(updated);
  } else {
    changelogFile.writeAsStringSync('# Changelog\n\n$newSection\n\n$content');
  }
}
