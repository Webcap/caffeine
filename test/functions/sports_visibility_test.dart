import 'package:flutter_test/flutter_test.dart';
import 'package:reelriot/utils/sports_helpers.dart';
import 'package:reelriot/models/espn_scoreboard.dart';

void main() {
  group('Sports Visibility & Normalization Tests', () {
    test('normalizeSportKey should identify canonical keys correctly', () {
      expect(normalizeSportKey('BASKETBALL', league: 'NBA'), 'NBA');
      expect(normalizeSportKey('NBA'), 'NBA');
      expect(normalizeSportKey('WNBA'), 'WNBA');
      expect(normalizeSportKey('BASKETBALL', league: 'WNBA'), 'WNBA');
      expect(normalizeSportKey('FOOTBALL', league: 'NFL'), 'NFL');
      expect(normalizeSportKey('NFL'), 'NFL');
      expect(normalizeSportKey('BASEBALL', league: 'MLB'), 'MLB');
      expect(normalizeSportKey('MLB'), 'MLB');
      expect(normalizeSportKey('HOCKEY', league: 'NHL'), 'NHL');
      expect(normalizeSportKey('NHL'), 'NHL');
      expect(normalizeSportKey('SOCCER', league: 'EPL'), 'Soccer');
      expect(normalizeSportKey('MMA'), 'UFC');
      expect(normalizeSportKey('UFC'), 'UFC');
      expect(normalizeSportKey('BOXING'), 'UFC');
      expect(normalizeSportKey('F1'), 'F1');
    });

    test('isSportHidden should detect hidden sport rows', () {
      final hiddenRows = ['NBA', 'Soccer', 'UFC'];

      // NBA should be hidden
      expect(isSportHidden('BASKETBALL', hiddenRows, league: 'NBA'), isTrue);
      expect(isSportHidden('NBA', hiddenRows), isTrue);

      // WNBA should NOT be hidden when only NBA is in hiddenRows
      expect(isSportHidden('BASKETBALL', hiddenRows, league: 'WNBA'), isFalse);
      expect(isSportHidden('WNBA', hiddenRows), isFalse);

      // Soccer should be hidden
      expect(isSportHidden('SOCCER', hiddenRows, league: 'EPL'), isTrue);
      expect(isSportHidden('SOCCER', hiddenRows), isTrue);

      // UFC/MMA should be hidden
      expect(isSportHidden('MMA', hiddenRows), isTrue);
      expect(isSportHidden('UFC', hiddenRows), isTrue);
      expect(isSportHidden('BOXING', hiddenRows), isTrue);

      // MLB and NFL should NOT be hidden
      expect(isSportHidden('BASEBALL', hiddenRows, league: 'MLB'), isFalse);
      expect(isSportHidden('FOOTBALL', hiddenRows, league: 'NFL'), isFalse);
      expect(isSportHidden('NHL', hiddenRows), isFalse);
    });

    test('isSportHidden handles combat sport game detection', () {
      final hiddenRows = ['UFC'];
      final combatGame = EspnScoreboardGame(
        id: '100',
        name: 'UFC 300: Main Card',
        shortName: 'UFC 300',
        competitors: [],
        isMainEvent: true,
      );

      expect(isSportHidden('FIGHT', hiddenRows, game: combatGame), isTrue);
    });
  });
}
