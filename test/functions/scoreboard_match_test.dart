import 'package:flutter_test/flutter_test.dart';
import 'package:caffiene/screens/tv_screens/live_tv_screen.dart';
import 'package:caffiene/screens/tv_screens/live_event_screen.dart';
import 'package:caffiene/models/espn_scoreboard.dart';

void main() {
  group('formatLiveEventTitle Tests', () {
    test('Should replace "at" with "vs"', () {
      expect(formatLiveEventTitle('Lakers at Heat'), 'Lakers vs Heat');
      expect(formatLiveEventTitle('76ers @ Kings'), '76ers vs Kings');
    });

    test('Should not create "vs at" duplicates', () {
      expect(formatLiveEventTitle('Lakers vs at Heat'), 'Lakers vs Heat');
    });

    test('Should handle "Live Now!" prefix', () {
      expect(formatLiveEventTitle('Live Now!Lakers at Heat'), 'Live Now! Lakers vs Heat');
    });
  });

  group('_findMatchingGame Tests', () {
    final games = [
      EspnScoreboardGame(
        id: '1',
        name: 'Los Angeles Lakers at Miami Heat',
        shortName: 'LAL @ MIA',
        competitors: [],
        isMainEvent: true,
      ),
      EspnScoreboardGame(
        id: '2',
        name: 'Philadelphia 76ers at Sacramento Kings',
        shortName: 'PHI @ SAC',
        competitors: [],
        isMainEvent: true,
      ),
    ];

    test('Should match exactly when keywords are present', () {
      final match = LiveEventScreen.findMatchingGame(
          'Philadelphia 76ers vs at Sacramento Kings', games);
      expect(match?.id, '2');
    });

    test('Should NOT match unrelated games due to "at"', () {
      // Before fix, this might have matched Lakers @ Heat because of "at" matching "Heat"
      // and matching "at" as a keyword.
      final match = LiveEventScreen.findMatchingGame(
          'Random Team vs at Sacramento Kings', games);
      // "Random Team" (left) should not match any game.
      expect(match, isNull);
    });

    test('Should match reversed names if keywords overlap', () {
      // Title: Kings vs 76ers
      // Game: Philadelphia 76ers at Sacramento Kings
      final match = LiveEventScreen.findMatchingGame('Kings vs 76ers', games);
      expect(match?.id, '2');
    });
  });
}
