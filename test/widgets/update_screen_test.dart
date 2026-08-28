import 'dart:io';
import 'package:reelriot/models/update.dart';
import 'package:reelriot/screens/common/update_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../test_helper.dart';

// Simple AssetLoader for tests to avoid disk I/O
class JsonAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "check_for_update": "Check for Update",
      "update_available": "Update Available",
      "new_version": "New Version: {v}",
      "see_changelogs": "See Changelogs",
      "changelogs": "Changelogs",
      "ok": "OK",
      "install": "Install",
      "delete": "Delete",
      "download": "Download",
    };
  }
}

void main() {
  late MockUpdateApiService mockApiService;
  late MockFileOpener mockFileOpener;
  late MockAppDependencyProvider mockAppDependencyProvider;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    registerFallbackValue(const Locale('en'));
    registerFallbackValue(MockAppDependencyProvider());

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => '.',
    );
  });

  setUp(() {
    mockApiService = MockUpdateApiService();
    mockFileOpener = MockFileOpener();
    mockAppDependencyProvider = MockAppDependencyProvider();

    when(() => mockAppDependencyProvider.latestVersion).thenReturn('2.0.0');
  });

  testWidgets('UpdateScreen renders update info and handles Changelog dialog',
      (WidgetTester tester) async {
    final updateInfo = AppUpdateInfo(
      latestVersion: '3000.0.0',
      forcedUpdate: false,
      updateDownloadUrl: 'https://example.com/update.apk',
      updateChangelog: 'New features!',
    );

    when(() => mockApiService.fetchUpdateInfo(any()))
        .thenAnswer((_) async => updateInfo);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        startLocale: const Locale('en'),
        fallbackLocale: const Locale('en'),
        path: 'assets/translations',
        assetLoader: JsonAssetLoader(),
        child: Builder(
          builder: (context) => createTestableWidget(
            child: UpdateScreen(
              isForced: false,
              updateApiService: mockApiService,
              fileOpener: mockFileOpener,
            ),
            appDependencyProvider: mockAppDependencyProvider,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.textContaining('3000.0.0'), findsWidgets);
    expect(find.byType(OutlinedButton), findsOneWidget);
    
    await tester.tap(find.byType(OutlinedButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('New features!'), findsOneWidget);
    
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('New features!'), findsNothing);
  });
}
