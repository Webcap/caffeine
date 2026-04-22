import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/recently_watched_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/services/ad_service.dart';
import 'package:reelriot/services/file_opener_service.dart';
import 'package:reelriot/services/update_api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_download_manager/flutter_download_manager.dart';

class MockSettingsProvider extends Mock implements SettingsProvider {}

class MockAppDependencyProvider extends Mock implements AppDependencyProvider {}

class MockRecentProvider extends Mock implements RecentProvider {}

class MockAdService extends Mock implements AdService {}

class MockUpdateApiService extends Mock implements UpdateApiService {}

class MockFileOpener extends Mock implements FileOpener {}

class MockDownloadManager extends Mock implements DownloadManager {}

class MockDownloadTask extends Mock implements DownloadTask {}

Widget createTestableWidget({
  required Widget child,
  SettingsProvider? settingsProvider,
  AppDependencyProvider? appDependencyProvider,
  RecentProvider? recentProvider,
  AdService? adService,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsProvider>.value(
        value: settingsProvider ?? MockSettingsProvider(),
      ),
      ChangeNotifierProvider<AppDependencyProvider>.value(
        value: appDependencyProvider ?? MockAppDependencyProvider(),
      ),
      ChangeNotifierProvider<RecentProvider>.value(
        value: recentProvider ?? MockRecentProvider(),
      ),
      ChangeNotifierProvider<AdService>.value(
        value: adService ?? MockAdService(),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}
