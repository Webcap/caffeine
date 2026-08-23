import 'package:reelriot/video_providers/provider_names.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProviderNames', () {
    group('providers', () {
      test('should contain high-performing providers in empirical order', () {
        final expectedCodes = ['vixsrc', 'coorenlabs', 'vidzee', 'vidfun'];
        final actualCodes = ProviderNames.providers.map((p) => p.codeName).toList();
        expect(actualCodes, equals(expectedCodes));
      });

      test('should have 4 active providers', () {
        expect(ProviderNames.providers.length, equals(4));
      });

      test('should exclude failing headless browser providers from active list', () {
        final activeCodes = ProviderNames.providers.map((p) => p.codeName).toList();
        expect(activeCodes.contains('vidlink'), isFalse);
        expect(activeCodes.contains('vidsrcsu'), isFalse);
      });

      test('defaultPrecedenceString should format active providers correctly', () {
        final precedence = ProviderNames.defaultPrecedenceString;
        expect(
          precedence,
          equals('vixsrc-Vixsrc coorenlabs-CoorenLabs vidzee-VidZee vidfun-VidFun'),
        );
      });

      test('should not contain consumet-based providers', () {
        final consumetProviders = ['goku', 'sflix', 'himovies'];
        final providerCodes =
            ProviderNames.providers.map((p) => p.codeName).toList();

        for (final code in consumetProviders) {
          expect(providerCodes.contains(code), isFalse);
        }
      });

      test('should not contain anime/drama providers in active list', () {
        final legacyProviders = ['animekai', 'animepahe', 'hianime', 'dramacool', 'viewasian', 'zoro'];
        final providerCodes =
            ProviderNames.providers.map((p) => p.codeName).toList();

        for (final code in legacyProviders) {
          expect(providerCodes.contains(code), isFalse);
        }
      });
    });

    group('checkableCodeNames and disabledCodeNames', () {
      test('should include all active providers in checkableCodeNames', () {
        for (final provider in ProviderNames.providers) {
          expect(
            ProviderNames.checkableCodeNames.contains(provider.codeName),
            isTrue,
            reason: '${provider.codeName} should be in checkableCodeNames',
          );
        }
      });

      test('should include disabled headless browser providers in checkableCodeNames', () {
        expect(ProviderNames.checkableCodeNames.contains('vidlink'), isTrue);
        expect(ProviderNames.checkableCodeNames.contains('vidsrcsu'), isTrue);
      });

      test('disabledCodeNames should identify failing headless browser providers', () {
        expect(ProviderNames.disabledCodeNames.contains('vidlink'), isTrue);
        expect(ProviderNames.disabledCodeNames.contains('vidsrcsu'), isTrue);
        expect(ProviderNames.disabledCodeNames.contains('vixsrc'), isFalse);
        expect(ProviderNames.disabledCodeNames.contains('coorenlabs'), isFalse);
        expect(ProviderNames.disabledCodeNames.contains('vidfun'), isFalse);
      });

      test('should not include consumet providers', () {
        final consumetProviders = ['goku', 'sflix', 'himovies'];
        for (final code in consumetProviders) {
          expect(
            ProviderNames.checkableCodeNames.contains(code),
            isFalse,
            reason: '$code should not be in checkableCodeNames',
          );
        }
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
