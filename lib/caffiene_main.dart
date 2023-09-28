import 'dart:io';

import 'package:caffiene/main.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/provider/recently_watched_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/auth_screens/user_state.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/utils/theme_data.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class caffeine extends StatefulWidget {
  const caffeine(
      {required this.settingsProvider,
      required this.recentProvider,
      required this.appDependencyProvider,
      required this.init,
      Key? key})
      : super(key: key);

  final SettingsProvider settingsProvider;
  final RecentProvider recentProvider;
  final AppDependencyProvider appDependencyProvider;
  final Future<FirebaseApp> init;

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

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  Future<void> _initConfig() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(minutes: 1)));

    _fetchConfig();
  }

  void _fetchConfig() async {
    await _remoteConfig.fetchAndActivate();
    appDependencyProvider.consumetUrl = _remoteConfig.getString('consumet_url');
    appDependencyProvider.caffieneLogo =
        _remoteConfig.getString('caffiene_logo');
  }

  @override
  void initState() {
    super.initState();
    _initConfig();
    fileDelete();
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {});
    FirebaseMessaging.onMessageOpenedApp.listen((message) {});
  }

  @override
  void dispose() {
    settingsProvider.dispose();
    recentProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.init,
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
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text(tr("error_occured")),
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
                  return widget.recentProvider;
                }),
                ChangeNotifierProvider(create: (_) {
                  return widget.appDependencyProvider;
                }),
              ],
              child: Consumer3<SettingsProvider, AppDependencyProvider,
                      RecentProvider>(
                  builder: (context, settingsProvider, appDependencyProvider,
                      recentProvider, snapshot) {
                return DynamicColorBuilder(
                  builder: (lightDynamic, darkDynamic) {
                    return MaterialApp(
                      localizationsDelegates: context.localizationDelegates,
                      supportedLocales: context.supportedLocales,
                      locale: context.locale,
                      debugShowCheckedModeBanner: false,
                      title: tr("caffiene"),
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
}
