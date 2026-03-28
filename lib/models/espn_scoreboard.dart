// Minimal model for ESPN scoreboard API (e.g. NBA).
// https://site.api.espn.com/apis/site/v2/sports/basketball/nba/scoreboard

class EspnScoreboardResponse {
  final List<EspnScoreboardGame> games;

  EspnScoreboardResponse({required this.games});

  factory EspnScoreboardResponse.fromJson(Map<String, dynamic> json) {
    final events = json['events'] as List<dynamic>? ?? [];
    List<EspnScoreboardGame> list = [];
    for (final e in events) {
      if (e is Map<String, dynamic>) {
        final comps = e['competitions'] as List? ?? [];
        if (comps.isNotEmpty) {
          list.add(EspnScoreboardGame.fromJson(e,
              competitionIndex: comps.length - 1));
        }
      }
    }
    return EspnScoreboardResponse(games: list);
  }
}

class EspnScoreboardGame {
  final String id;
  final String name;
  final String shortName;
  final List<EspnCompetitor> competitors;
  final EspnStatus? status;
  final String? competitionType;
  final bool isMainEvent;

  final DateTime? startTimeUtc;
  final List<dynamic>? sources;
  final bool isManualEnded;

  EspnScoreboardGame({
    required this.id,
    required this.name,
    required this.shortName,
    required this.competitors,
    this.status,
    this.competitionType,
    required this.isMainEvent,
    this.startTimeUtc,
    this.sources,
    this.isManualEnded = false,
  });

  factory EspnScoreboardGame.fromJson(Map<String, dynamic> json,
      {int competitionIndex = 0, bool isManualEnded = false}) {
    final comps = json['competitions'] as List<dynamic>?;
    List<EspnCompetitor> list = [];
    String? cType;
    final isMainEvent = comps != null && competitionIndex == comps.length - 1;

    if (comps != null && comps.length > competitionIndex) {
      final c = comps[competitionIndex] as Map<String, dynamic>?;
      cType = c?['type']?['abbreviation']?.toString();
      final raw = c?['competitors'] as List<dynamic>?;
      if (raw != null) {
        list = raw
            .map((e) =>
                e is Map<String, dynamic> ? EspnCompetitor.fromJson(e) : null)
            .whereType<EspnCompetitor>()
            .toList();
      }
    }

    DateTime? startTime;
    final dateStr = json['date']?.toString();
    if (dateStr != null && dateStr.isNotEmpty) {
      startTime = DateTime.tryParse(dateStr);
    }

    return EspnScoreboardGame(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      shortName: json['shortName']?.toString() ?? '',
      competitors: list,
      status: EspnStatus.fromJson(json['status'] as Map<String, dynamic>? ?? {}),
      competitionType: cType,
      isMainEvent: isMainEvent,
      startTimeUtc: startTime,
      sources: json['sources'] as List<dynamic>?,
      isManualEnded: isManualEnded,
    );
  }

  EspnScoreboardGame copyWith({
    bool? isManualEnded,
    List<dynamic>? sources,
  }) {
    return EspnScoreboardGame(
      id: id,
      name: name,
      shortName: shortName,
      competitors: competitors,
      status: status,
      competitionType: competitionType,
      isMainEvent: isMainEvent,
      startTimeUtc: startTimeUtc,
      sources: sources ?? this.sources,
      isManualEnded: isManualEnded ?? this.isManualEnded,
    );
  }

  /// Away team and home team - ESPN uses homeAway. Fallback to order if missing.
  EspnCompetitor? get away =>
      _firstWhere((c) => c.homeAway == 'away') ??
      (competitors.isNotEmpty ? competitors[0] : null);

  EspnCompetitor? get home =>
      _firstWhere((c) => c.homeAway == 'home') ??
      (competitors.length >= 2
          ? competitors[1]
          : (competitors.isNotEmpty ? competitors[0] : null));

  EspnCompetitor? _firstWhere(bool Function(EspnCompetitor) test) {
    for (final c in competitors) {
      if (test(c)) return c;
    }
    return null;
  }

  /// Thumbnail from first team logo
  String? get thumbnailUrl => away?.logoUrl ?? home?.logoUrl;

  /// Score line e.g. "101 - 115"
  String? get scoreLine {
    // UFC/MMA usually show as 0 - 0 until final, which is cluttered
    final isCombat = shortName.toUpperCase().contains('UFC') || 
                    name.toUpperCase().contains('UFC') ||
                    (competitors.isNotEmpty && competitors.any((c) => c.displayName.contains(' vs ')));
                    
    if (isCombat) return null;

    final a = away?.score;
    final h = home?.score;
    if (a == null && h == null) return null;
    return '${a ?? '-'} - ${h ?? '-'}';
  }

  /// Time/status for display
  String? get timeOrStatus {
    if (isManualEnded) return 'FINAL';
    return status?.shortDetail ?? status?.detail;
  }

  /// True if the game is currently in progress (ESPN status.type.state == 'in').
  bool get isLive => status?.state == 'in';

  /// Start time in local time for display (e.g. "7:30 PM"). Null if no start time.
  String? get startTimeLocal {
    if (startTimeUtc == null) return null;
    final local = startTimeUtc!.toLocal();
    final h = local.hour;
    final m = local.minute;
    final am = h < 12;
    final hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$hour12:${m.toString().padLeft(2, '0')} ${am ? 'AM' : 'PM'}';
  }

  /// Special check for "over but still shows live"
  bool get isActuallyLive {
    if (isManualEnded) return false;
    if (!isLive) return false;
    if (status?.completed == true) return false;

    // Check if statusText says "Final"
    if (status?.shortDetail.toUpperCase().contains('FINAL') == true ||
        status?.detail.toUpperCase().contains('FINAL') == true) {
      return false;
    }

    return true;
  }

  bool get isEffectivelyCompleted {
    if (isManualEnded) return true;
    if (status?.completed == true) return true;
    if (isLive && !isActuallyLive) return true;
    if (status?.state == 'post') return true;
    return false;
  }
}

class EspnCompetitor {
  final String homeAway;
  final String? id;
  final String displayName;
  final String score;
  final String? logoUrl;

  EspnCompetitor({
    required this.homeAway,
    this.id,
    required this.displayName,
    required this.score,
    this.logoUrl,
  });

  factory EspnCompetitor.fromJson(Map<String, dynamic> json) {
    final team = json['team'] as Map<String, dynamic>?;
    final athlete = json['athlete'] as Map<String, dynamic>?;

    final displayName = team?['displayName']?.toString() ??
        athlete?['displayName']?.toString() ??
        json['team']?.toString() ??
        json['athlete']?.toString() ??
        '';

    // Prioritize headshot for athletes, then flag, then team logo
    String? logoUrl;
    if (athlete != null) {
      final aId = athlete['id']?.toString();
      logoUrl = athlete['headshot']?.toString() ??
          athlete['flag']?['href']?.toString() ??
          athlete['flag']?.toString();
          
      if (logoUrl == null && aId != null && aId.isNotEmpty) {
        logoUrl = 'https://a.espncdn.com/i/headshots/mma/players/full/$aId.png';
      }
    } 
    
    // Fallback to team logos if no athlete-specific logo found
    logoUrl ??= team?['logo']?.toString() ??
               team?['logos']?[0]?['href']?.toString();

    return EspnCompetitor(
      homeAway: json['homeAway']?.toString() ?? '',
      id: json['id']?.toString() ?? athlete?['id']?.toString() ?? team?['id']?.toString(),
      displayName: displayName,
      score: json['score']?.toString() ?? '0',
      logoUrl: logoUrl,
    );
  }
}

/// Wrapper for list display: game + sport/league labels
class EspnListEvent {
  final EspnScoreboardGame game;
  final String sport;
  final String league;

  EspnListEvent(
      {required this.game, required this.sport, required this.league});

  EspnListEvent copyWith({
    EspnScoreboardGame? game,
    String? sport,
    String? league,
  }) {
    return EspnListEvent(
      game: game ?? this.game,
      sport: sport ?? this.sport,
      league: league ?? this.league,
    );
  }
}

class EspnStatus {
  final String description;
  final String detail;
  final String shortDetail;
  final bool completed;
  final String? displayClock;
  final int? period;

  /// ESPN state: "pre" (preview), "in" (in progress), "post" (final).
  final String state;

  EspnStatus({
    required this.description,
    required this.detail,
    required this.shortDetail,
    required this.completed,
    this.displayClock,
    this.period,
    this.state = '',
  });

  factory EspnStatus.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as Map<String, dynamic>?;
    return EspnStatus(
      description: type?['description']?.toString() ?? '',
      detail: json['detail']?.toString() ?? '',
      shortDetail: json['shortDetail']?.toString() ?? '',
      completed: type?['completed'] == true,
      displayClock: json['displayClock']?.toString(),
      period: json['period'] is int ? json['period'] : (int.tryParse(json['period']?.toString() ?? '')),
      state: type?['state']?.toString() ?? '',
    );
  }
}
