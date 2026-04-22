import 'dart:io';
import 'package:reelriot/models/update.dart';
import 'package:reelriot/screens/common/update_screen.dart';
import 'package:flutter/material.dart';
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
      latestVersion: '2.0.3',
      forcedUpdate: false,
      updateDownloadUrl: 'https://example.com/update.apk',
      updateChangelog: 'New features!',
    );

    when(() => mockApiService.fetchUpdateInfo(any()))
        .thenAnswer((_) async => updateInfo);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
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
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('2.0.3'), findsOneWidget);
    expect(find.text('See Changelogs'), findsOneWidget);
    
    await tester.tap(find.text('See Changelogs'));
    await tester.pumpAndSettle();
    expect(find.text('New features!'), findsOneWidget);
    
    expect(find.text('OK'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('New features!'), findsNothing);
  });
}
