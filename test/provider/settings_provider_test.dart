import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/utils/globals.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SettingsProvider Tests', () {
    late SettingsProvider settingsProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPrefsSingleton = await SharedPreferences.getInstance();
      settingsProvider = SettingsProvider();
    });

    test('Initial theme mode should be dark', () {
      expect(settingsProvider.appTheme, equals('dark'));
    });


    test('Update theme mode notifies listeners', () async {
      bool notified = false;
      settingsProvider.addListener(() {
        notified = true;
      });

      settingsProvider.appTheme = 'light';
      expect(settingsProvider.appTheme, equals('light'));
      expect(notified, isTrue);
    });

  });
}
