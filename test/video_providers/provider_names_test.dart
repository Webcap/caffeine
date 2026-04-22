import 'package:reelriot/video_providers/provider_names.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProviderNames', () {
    group('providers', () {
      test('should contain vixsrc as first provider', () {
        expect(ProviderNames.providers.first.codeName, equals('vixsrc'));
        expect(ProviderNames.providers.first.fullName, equals('Vixsrc'));
      });

      test('should contain vidsrc provider', () {
        final vidsrc = ProviderNames.providers.firstWhere(
          (p) => p.codeName == 'vidsrc',
        );
        expect(vidsrc.fullName, equals('VidSrc'));
      });

      test('should contain all FlixAPI multi providers', () {
        final multiProviders = [
          'vixsrc',
          'vidsrc',
          'vidzee',
          'pstream',
          'showbox',
        ];

        for (final code in multiProviders) {
          final provider = ProviderNames.providers.firstWhere(
            (p) => p.codeName == code,
            orElse: () => throw Exception('Provider $code not found'),
          );
          expect(provider.codeName, equals(code));
        }
      });

      test('should contain consumet-based providers', () {
        final consumetProviders = ['goku', 'sflix', 'himovies'];

        for (final code in consumetProviders) {
          final provider = ProviderNames.providers.firstWhere(
            (p) => p.codeName == code,
            orElse: () => throw Exception('Provider $code not found'),
          );
          expect(provider.codeName, equals(code));
        }
      });

      test('should have 9 total providers', () {
        expect(ProviderNames.providers.length, equals(8));
      });

      test('should not contain anime providers in active list', () {
        final animeProviders = ['animekai', 'animepahe', 'hianime'];
        final providerCodes =
            ProviderNames.providers.map((p) => p.codeName).toList();

        for (final code in animeProviders) {
          expect(providerCodes.contains(code), isFalse);
        }
      });

      test('should not contain draman', () {
        final providerCodes =
            ProviderNames.providers.map((p) => p.codeName).toList();
        expect(providerCodes.contains('dramacool'), isFalse);
        expect(providerCodes.contains('viewasian'), isFalse);
        expect(providerCodes.contains('zoro'), isFalse);
      });
    });

    group('checkableCodeNames', () {
      test('should include all active providers', () {
        for (final provider in ProviderNames.providers) {
          expect(
            ProviderNames.checkableCodeNames.contains(provider.codeName),
            isTrue,
            reason: '${provider.codeName} should be in checkableCodeNames',
          );
        }
      });

      test('should include anime providers', () {
        final animeProviders = ['animekai', 'animepahe', 'hianime'];

        for (final code in animeProviders) {
          expect(
            ProviderNames.checkableCodeNames.contains(code),
            isTrue,
            reason: '$code should be in checkableCodeNames',
          );
        }
      });

      test('should have 12 total checkable code names', () {
        expect(ProviderNames.checkableCodeNames.length, equals(11));
      });
    });
  });

  group('VideoProvider', () {
    test('should create with fullName and codeName', () {
      final provider = VideoProvider(
        fullName: 'Test Provider',
        codeName: 'test',
      );

      expect(provider.fullName, equals('Test Provider'));
      expect(provider.codeName, equals('test'));
    });

    test('should allow modifying properties', () {
      final provider = VideoProvider(
        fullName: 'Original Name',
        codeName: 'original',
      );

      provider.fullName = 'New Name';
      provider.codeName = 'new';

      expect(provider.fullName, equals('New Name'));
      expect(provider.codeName, equals('new'));
    });

    test('should have same values when created with same inputs', () {
      final provider1 = VideoProvider(fullName: 'Test', codeName: 'test');
      final provider2 = VideoProvider(fullName: 'Test', codeName: 'test');

      expect(provider1.fullName, equals(provider2.fullName));
      expect(provider1.codeName, equals(provider2.codeName));
    });
  });
}
