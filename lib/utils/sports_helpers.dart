import 'package:flutter/material.dart';
import 'package:reelriot/models/espn_scoreboard.dart';

class SportTheme {
  final String label;
  final String sportKey;
  final List<Color> gradientColors;
  final Color accentColor;
  final IconData icon;

  const SportTheme({
    required this.label,
    required this.sportKey,
    required this.gradientColors,
    required this.accentColor,
    required this.icon,
  });
}

/// Detects if an event is an MMA / UFC / Combat sport
bool isMmaEvent({
  String? sport,
  String? league,
  String? title,
  EspnScoreboardGame? game,
}) {
  final s = sport?.toUpperCase() ?? '';
  final l = league?.toUpperCase() ?? '';
  final t = title?.toUpperCase() ?? '';

  if (s == 'MMA' ||
      s == 'UFC' ||
      s == 'BOXING' ||
      s == 'FIGHT' ||
      l == 'UFC' ||
      l == 'MMA' ||
      t.contains('UFC') ||
      t.contains('CONTENDER SERIES') ||
      t.contains('DANA WHITE') ||
      t.contains('FIGHT NIGHT') ||
      t.contains('BELLATOR') ||
      t.contains('PFL') ||
      t.contains('BOXING')) {
    return true;
  }

  if (game != null && game.isCombatSport) {
    return true;
  }

  return false;
}

/// Resolves a tailored SportTheme for any sport/title/league
SportTheme resolveSportTheme({
  String? sport,
  String? title,
  String? league,
  EspnScoreboardGame? game,
}) {
  final s = (sport ?? '').trim().toUpperCase();
  final t = (title ?? '').trim().toUpperCase();
  final l = (league ?? '').trim().toUpperCase();

  // 1. MMA / UFC / Combat
  if (isMmaEvent(sport: sport, league: league, title: title, game: game)) {
    String label = 'UFC / MMA';
    if (t.contains('CONTENDER SERIES') || t.contains('DANA WHITE')) {
      label = 'DWCS · UFC';
    } else if (t.contains('BOXING')) {
      label = 'BOXING';
    } else if (l.isNotEmpty && l != 'ALL') {
      label = l;
    }

    return SportTheme(
      label: label,
      sportKey: 'MMA',
      gradientColors: const [
        Color(0xFF881337), // rose-900 / crimson
        Color(0xFF31102A),
        Color(0xFF0F172A), // slate-900
      ],
      accentColor: const Color(0xFFE11D48),
      icon: Icons.sports_mma_rounded,
    );
  }

  // 2. Basketball / NBA
  if (s == 'BASKETBALL' || s == 'NBA' || l == 'NBA' || t.contains('NBA') || t.contains('BASKETBALL') || t.contains('LAKERS') || t.contains('WARRIORS') || t.contains('CELTICS')) {
    return const SportTheme(
      label: 'NBA',
      sportKey: 'BASKETBALL',
      gradientColors: [
        Color(0xFFC2410C), // orange-700
        Color(0xFF7C2D12),
        Color(0xFF0F172A),
      ],
      accentColor: Color(0xFFF97316),
      icon: Icons.sports_basketball_rounded,
    );
  }

  // 3. Baseball / MLB
  if (s == 'BASEBALL' || s == 'MLB' || l == 'MLB' || t.contains('MLB') || t.contains('BASEBALL') || t.contains('YANKEES') || t.contains('RED SOX') || t.contains('DODGERS')) {
    return const SportTheme(
      label: 'MLB',
      sportKey: 'BASEBALL',
      gradientColors: [
        Color(0xFF1E3A8A), // blue-900
        Color(0xFF172554),
        Color(0xFF0F172A),
      ],
      accentColor: Color(0xFF3B82F6),
      icon: Icons.sports_baseball_rounded,
    );
  }

  // 4. Football / NFL
  if (s == 'FOOTBALL' || s == 'NFL' || l == 'NFL' || t.contains('NFL') || t.contains('CHIEFS') || t.contains('COWBOYS') || t.contains('PATRIOTS')) {
    return const SportTheme(
      label: 'NFL',
      sportKey: 'FOOTBALL',
      gradientColors: [
        Color(0xFF065F46), // emerald-800
        Color(0xFF064E3B),
        Color(0xFF0F172A),
      ],
      accentColor: Color(0xFF10B981),
      icon: Icons.sports_football_rounded,
    );
  }

  // 5. Soccer / Football (EPL, La Liga, Champions League)
  if (s == 'SOCCER' || l == 'EPL' || l == 'SOCCER' || t.contains('FC') || t.contains('UNITED') || t.contains('REAL MADRID') || t.contains('BARCELONA') || t.contains('PREMIER LEAGUE')) {
    return const SportTheme(
      label: 'SOCCER',
      sportKey: 'SOCCER',
      gradientColors: [
        Color(0xFF047857), // emerald-700
        Color(0xFF0F766E), // teal-700
        Color(0xFF0F172A),
      ],
      accentColor: Color(0xFF14B8A6),
      icon: Icons.sports_soccer_rounded,
    );
  }

  // 6. Hockey / NHL
  if (s == 'HOCKEY' || s == 'NHL' || l == 'NHL' || t.contains('NHL') || t.contains('HOCKEY')) {
    return const SportTheme(
      label: 'NHL',
      sportKey: 'HOCKEY',
      gradientColors: [
        Color(0xFF0369A1), // sky-700
        Color(0xFF075985),
        Color(0xFF0F172A),
      ],
      accentColor: Color(0xFF38BDF8),
      icon: Icons.sports_hockey_rounded,
    );
  }

  // 7. Motorsport / F1 / NASCAR
  if (s == 'RACING' || s == 'F1' || l == 'F1' || t.contains('FORMULA 1') || t.contains('GRAND PRIX') || t.contains('NASCAR')) {
    return const SportTheme(
      label: 'F1 / RACING',
      sportKey: 'RACING',
      gradientColors: [
        Color(0xFF991B1B), // red-800
        Color(0xFF450A0A),
        Color(0xFF0F172A),
      ],
      accentColor: Color(0xFFEF4444),
      icon: Icons.sports_motorsports_rounded,
    );
  }

  // Default / Live Sport Fallback
  final fallbackLabel = (s.isNotEmpty && s != 'ALL') ? s : 'LIVE SPORTS';
  return SportTheme(
    label: fallbackLabel,
    sportKey: 'SPORTS',
    gradientColors: const [
      Color(0xFF7C3AED), // purple-600
      Color(0xFFDC2626), // red-600
      Color(0xFF0F172A),
    ],
    accentColor: const Color(0xFFDC2626),
    icon: Icons.live_tv_rounded,
  );
}

/// Normalizes any sport string/league/title to canonical key matching Admin config
/// (e.g. 'NBA', 'WNBA', 'MLB', 'NFL', 'NHL', 'Soccer', 'UFC')
String normalizeSportKey(String? sport, {String? league, String? title, EspnScoreboardGame? game}) {
  if (sport == null || sport.trim().isEmpty) return "All";
  final s = sport.trim().toUpperCase();
  final l = (league ?? '').trim().toUpperCase();
  final t = (title ?? '').trim().toUpperCase();

  // WNBA before NBA
  if (s == 'WNBA' || s.contains('WNBA') || l == 'WNBA' || t.contains('WNBA')) {
    return 'WNBA';
  }
  if (s == 'NBA' || s.startsWith('NBA') || s == 'BASKETBALL' || s.contains('BASKETBALL') || l == 'NBA' || t.contains('NBA')) {
    return 'NBA';
  }
  if (s == 'NFL' || s.startsWith('NFL') || s == 'FOOTBALL' || s.contains('FOOTBALL') || l == 'NFL' || t.contains('NFL')) {
    return 'NFL';
  }
  if (s == 'MLB' || s.startsWith('MLB') || s == 'BASEBALL' || s.contains('BASEBALL') || l == 'MLB' || t.contains('MLB')) {
    return 'MLB';
  }
  if (s == 'NHL' || s.startsWith('NHL') || s == 'HOCKEY' || s.contains('HOCKEY') || l == 'NHL' || t.contains('NHL')) {
    return 'NHL';
  }
  if (isMmaEvent(sport: sport, league: league, title: title, game: game)) {
    return 'UFC';
  }
  if (s == 'SOCCER' || s.contains('SOCCER') || l == 'EPL' || s.contains('.') || l.contains('SOCCER') || l.contains('EPL')) {
    return 'Soccer';
  }
  return sport.trim();
}

/// Checks if a sport/league/title matches any key in hiddenSportsRows
bool isSportHidden(
  String? sport,
  List<String> hiddenRows, {
  String? league,
  String? title,
  EspnScoreboardGame? game,
}) {
  if (hiddenRows.isEmpty) return false;
  final key = normalizeSportKey(sport, league: league, title: title, game: game);
  final keyLower = key.toLowerCase();

  for (final hidden in hiddenRows) {
    final hLower = hidden.trim().toLowerCase();
    if (hLower == keyLower) return true;
    if (sport != null && hLower == sport.trim().toLowerCase()) return true;
    if (league != null && hLower == league.trim().toLowerCase()) return true;
  }
  return false;
}

