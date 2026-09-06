import 'package:flutter_test/flutter_test.dart';
import 'package:reelriot/models/user_rating.dart';
import 'package:reelriot/provider/ratings_provider.dart';

void main() {
  group('UserRating Model', () {
    test('fromJson and toJson for movie rating', () {
      final json = {
        'media_type': 'movie',
        'media_id': 12345,
        'rating': 9,
        'updated_at': '2026-09-06T12:00:00.000Z',
      };

      final model = UserRating.fromJson(json);
      expect(model.mediaType, equals('movie'));
      expect(model.mediaId, equals(12345));
      expect(model.seasonNum, isNull);
      expect(model.episodeNum, isNull);
      expect(model.rating, equals(9));
      expect(model.compositeKey, equals('movie:12345'));

      final out = model.toJson();
      expect(out['media_type'], equals('movie'));
      expect(out['media_id'], equals(12345));
      expect(out['rating'], equals(9));
    });

    test('fromJson and toJson for TV episode rating', () {
      final json = {
        'media_type': 'tv',
        'media_id': 67890,
        'season_num': 2,
        'episode_num': 4,
        'rating': 8,
      };

      final model = UserRating.fromJson(json);
      expect(model.mediaType, equals('tv'));
      expect(model.mediaId, equals(67890));
      expect(model.seasonNum, equals(2));
      expect(model.episodeNum, equals(4));
      expect(model.rating, equals(8));
      expect(model.compositeKey, equals('tv:67890:2:4'));

      final out = model.toJson();
      expect(out['season_num'], equals(2));
      expect(out['episode_num'], equals(4));
    });

    test('makeKey generates consistent keys', () {
      expect(UserRating.makeKey('movie', 101), equals('movie:101'));
      expect(
        UserRating.makeKey('tv', 202, seasonNum: 1, episodeNum: 3),
        equals('tv:202:1:3'),
      );
      expect(UserRating.makeKey('tv', 202), equals('tv:202'));
    });
  });

  group('RatingsProvider in-memory behavior', () {
    test('clearLocalRatings resets state', () {
      final provider = RatingsProvider();
      provider.clearLocalRatings();
      expect(provider.ratings, isEmpty);
      expect(provider.hasRating('movie', 123), isFalse);
      expect(provider.getRating('movie', 123), isNull);
    });
  });
}
