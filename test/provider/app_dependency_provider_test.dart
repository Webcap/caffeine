import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    dotenv.loadFromString(envString: 'CAFFEINE_API_URL=https://caffeine-api.test');
  });

  group('AppDependencyProvider Health & Circuit Breaker Tests', () {
    late AppDependencyProvider provider;

    setUp(() {
      provider = AppDependencyProvider();
    });

    test('isProviderHealthy defaults to true when unverified', () {
      expect(provider.isProviderHealthy('vixsrc'), isTrue);
      expect(provider.isProviderHealthy('vidfun'), isTrue);
    });

    test('setting providerHealth updates health states and notifies listeners', () {
      bool notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.providerHealth = {
        'vixsrc': true,
        'vidlink': false,
        'vidfun': true,
      };

      expect(notified, isTrue);
      expect(provider.isProviderHealthy('vixsrc'), isTrue);
      expect(provider.isProviderHealthy('vidlink'), isFalse);
      expect(provider.isProviderHealthy('vidfun'), isTrue);
      expect(provider.isProviderHealthy('unknown_provider'), isTrue);
    });
  });
}
