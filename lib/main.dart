import 'dart:io';

import 'package:caffiene/models/download_manager.dart';
import 'package:caffiene/models/translation.dart';
import 'package:caffiene/provider/recently_watched_provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:caffiene/provider/settings_provider.dart';

import 'package:caffiene/screens/auth_screens/user_state.dart';
import 'package:caffiene/utils/config.dart';

import 'package:caffiene/utils/theme_data.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';

Future<void> _messageHandler(RemoteMessage message) async {}

SettingsProvider settingsProvider = SettingsProvider();
DownloadProvider downloadProvider = DownloadProvider();
RecentProvider recentProvider = RecentProvider();

final Future<FirebaseApp> _initialization = Firebase.initializeApp();

// extension Precision on double {
//   double toPrecision(int fractionDigits) {
//     num mod = pow(10, fractionDigits.toDouble());
//     return ((this * mod).round().toDouble() / mod);
//   }
// }

Future<void> appInitialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  await settingsProvider.getCurrentThemeMode();
  await settingsProvider.getCurrentMaterial3Mode();
  await settingsProvider.getCurrentAdultMode();
  await settingsProvider.getCurrentDefaultScreen();
  await settingsProvider.getCurrentImageQuality();
  await settingsProvider.getCurrentWatchCountry();
  await settingsProvider.getCurrentViewType();
  await settingsProvider.initMixpanel();
  await settingsProvider.getSeekDuration();
  await settingsProvider.getMaxBufferDuration();
  await settingsProvider.getVideoResolution();
  await settingsProvider.getSubtitleLanguage();
  await settingsProvider.getViewMode();
  await recentProvider.fetchMovies();
  await recentProvider.fetchEpisodes();
  await _initialization;
}

void main() async {
  await appInitialize();
  
  if (showAds) {
    MobileAds.instance.initialize();
  }
  runApp(EasyLocalization(
    supportedLocales: Translation.all,
    path: 'assets/translations',
    fallbackLocale: Translation.all[0],
    startLocale: const Locale('en'),
    child: caffeine(
      settingsProvider: settingsProvider,
      downloadProvider: downloadProvider,
      recentProvider: recentProvider,
    ),
  ));
}

class caffeine extends StatefulWidget {
  const caffeine({
    required this.settingsProvider, 
    required this.downloadProvider,  
    required this.recentProvider,  
    Key? key
  }) : super(key: key);

  final SettingsProvider settingsProvider;
  final DownloadProvider downloadProvider;
  final RecentProvider recentProvider;

  @override
  State<caffeine> createState() => _caffeineState();
}

class _caffeineState extends State<caffeine>
    with ChangeNotifier, WidgetsBindingObserver {
  void fileDelete() async {
    for (int i = 0; i < appNames.length; i++) {
      File file = File(
          "${(await getApplicationSupportDirectory()).path}${appNames[i]}");
      if (file.existsSync()) {
        file.delete();
      }
    }
  }

  bool? isFirstLaunch;
  bool? isAndroidTV;
  //static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  // void firstTimeCheck() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     if (prefs.getBool('isFirstRun') == null) {
  //       isFirstLaunch = true;
  //     } else {
  //       isFirstLaunch = false;
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {});
    FirebaseMessaging.onMessageOpenedApp.listen((message) {});
    fileDelete();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text('Error occurred'),
                ),
              ),
            );
          }
          return MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) {
                  return widget.settingsProvider;
                }),
                ChangeNotifierProvider(create: (_) {
                  return widget.downloadProvider;
                }),
                ChangeNotifierProvider(create: (_) {
                  return widget.recentProvider;
                })
              ],
              child: Consumer3<SettingsProvider, DownloadProvider, RecentProvider>(
                  builder: (context, settingsProvider, downloadProvider, recentProvider, snapshot) {
                return DynamicColorBuilder(
                  builder: (lightDynamic, darkDynamic) {
                    return MaterialApp(
                      localizationsDelegates: context.localizationDelegates,
                      supportedLocales: context.supportedLocales,
                      locale: context.locale,
                      debugShowCheckedModeBanner: false,
                      title: 'Caffiene',
                      theme: Styles.themeData(
                          isDarkTheme: settingsProvider.darktheme,
                          isM3Enabled: settingsProvider.isMaterial3Enabled,
                          lightDynamicColor: lightDynamic,
                          darkDynamicColor: darkDynamic,
                          context: context),
                      home: const UserState(),
                    );
                  },
                );
              }));
        });
  }

  // _getPackage() async {
  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //   String appName = packageInfo.appName;
  //   String packageName = packageInfo.packageName;
  //   String appVersion = packageInfo.version;
  //   String appBuildNumber = packageInfo.buildNumber;

  //   Constant.appName = appName;
  //   Constant.appPackageName = packageName;
  //   Constant.appVersion = appVersion;
  //   Constant.appBuildNumber = appBuildNumber;
  // }
}
