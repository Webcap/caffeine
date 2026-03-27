import 'package:caffiene/services/ad_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:startapp_sdk/startapp.dart';

class MockStartAppSdk extends Mock implements StartAppSdk {}

class MockStartAppInterstitialAd extends Mock
    implements StartAppInterstitialAd {}

class MockStartAppBannerAd extends Mock implements StartAppBannerAd {}

void main() {
  setUpAll(() {
    registerFallbackValue(StartAppBannerType.BANNER);
  });

  late AdService adService;
  late MockStartAppSdk mockSdk;

  setUp(() {
    adService = AdService.instance;
    mockSdk = MockStartAppSdk();

    // We cannot easily reset a singleton's state if it doesn't provide a way,
    // but we can at least test its public methods and state transitions if possible.
    // Note: AdService.instance is a singleton.
  });

  group('AdService Initialization', () {
    test('Initialization status should be tracked', () async {
      when(() => mockSdk.loadBannerAd(any()))
          .thenAnswer((_) async => MockStartAppBannerAd());
      when(() => mockSdk.loadInterstitialAd(
            onAdDisplayed: any(named: 'onAdDisplayed'),
            onAdNotDisplayed: any(named: 'onAdNotDisplayed'),
            onAdClicked: any(named: 'onAdClicked'),
            onAdHidden: any(named: 'onAdHidden'),
            onAdImpression: any(named: 'onAdImpression'),
          )).thenAnswer((_) async => MockStartAppInterstitialAd());

      await adService.initialize(sdk: mockSdk);
      expect(adService.sdk, isNotNull);
    });
  });

  group('AdService Getters', () {
    test('Default values', () {
      // Ensure getters work without crashing
      expect(adService.isBannerAdLoading, isA<bool>());
      expect(adService.isInterstitialAdLoading, isA<bool>());
    });
  });
}
