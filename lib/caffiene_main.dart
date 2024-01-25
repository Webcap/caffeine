import 'package:caffiene/functions/functions.dart';
import 'package:caffiene/main.dart';
import 'package:caffiene/models/app_colors.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/provider/recently_watched_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/auth_screens/user_state.dart';
import 'package:caffiene/utils/routes/app_pages.dart';
import 'package:caffiene/utils/theme_data.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

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

final supabase = Supabase.instance.client;

class _caffeineState extends State<caffeine>
    with ChangeNotifier, WidgetsBindingObserver {
  bool? isFirstLaunch;
  bool? isAndroidTV;

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  Future<void> _initConfig() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(minutes: 1)));

    _fetchConfig();
  }

  Future _fetchConfig() async {
    await _remoteConfig.fetchAndActivate();
    if (mounted) {
      appDependencyProvider.consumetUrl =
          _remoteConfig.getString('consumet_url');
      appDependencyProvider.opensubtitlesKey =
          _remoteConfig.getString('opensubtitles_key');
      appDependencyProvider.streamingServerFlixHQ =
          _remoteConfig.getString('streaming_server_flixhq');
      appDependencyProvider.streamingServerDCVA =
          _remoteConfig.getString('streaming_server_dcva');
      appDependencyProvider.enableADS = _remoteConfig.getBool('ads_enabled');
      appDependencyProvider.fetchRoute = _remoteConfig.getString('route');
      appDependencyProvider.useExternalSubtitles =
          _remoteConfig.getBool('use_external_subtitles');
      appDependencyProvider.enableOTTADS =
          _remoteConfig.getBool('ott_ads_enabled');
      appDependencyProvider.enableTrendingHoliday =
          _remoteConfig.getBool('trending_holiday_scroller');
      appDependencyProvider.displayWatchNowButton =
          _remoteConfig.getBool('enable_stream');
      appDependencyProvider.displayOTTDrawer =
          _remoteConfig.getBool('enable_ott');
      appDependencyProvider.caffeineAPIURL =
          _remoteConfig.getString('caffeine_api_url');
      appDependencyProvider.streamingServerZoro =
          _remoteConfig.getString('streaming_server_zoro');
    }
    await requestNotificationPermissions();
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
                    return GetMaterialApp(
                      localizationsDelegates: context.localizationDelegates,
                      supportedLocales: context.supportedLocales,
                      locale: context.locale,
                      debugShowCheckedModeBanner: false,
                      getPages: AppPages.pages,
                      title: tr("caffiene"),
                      theme: Styles.themeData(
                          appThemeMode: settingsProvider.appTheme,
                          isM3Enabled: settingsProvider.isMaterial3Enabled,
                          lightDynamicColor: lightDynamic,
                          darkDynamicColor: darkDynamic,
                          context: context,
                          appColor: AppColor(
                              cs: AppColorsList()
                                  .appColors(settingsProvider.appTheme ==
                                              'dark' ||
                                          settingsProvider.appTheme == 'amoled'
                                      ? true
                                      : false)
                                  .firstWhere((element) =>
                                      element.index ==
                                      settingsProvider.appColorIndex)
                                  .cs,
                              index: settingsProvider.appColorIndex)),
                      home: const UserState(),
                    );
                  },
                );
              }));
        });
  }
}
