import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:login/provider/settings_provider.dart';

import 'package:login/screens/auth_screens/user_state.dart';
import 'package:login/utils/config.dart';

import 'package:login/utils/theme_data.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';

SettingsProvider settingsProvider = SettingsProvider();
final Future<FirebaseApp> _initialization = Firebase.initializeApp();

// extension Precision on double {
//   double toPrecision(int fractionDigits) {
//     num mod = pow(10, fractionDigits.toDouble());
//     return ((this * mod).round().toDouble() / mod);
//   }
// }

void main() async {
  //initialize app
  WidgetsFlutterBinding.ensureInitialized();
  await settingsProvider.getCurrentThemeMode();
  await settingsProvider.getCurrentMaterial3Mode();
  await settingsProvider.getCurrentAdultMode();
  await settingsProvider.getCurrentDefaultScreen();
  await settingsProvider.getCurrentImageQuality();
  await settingsProvider.getCurrentWatchCountry();
  await settingsProvider.getCurrentViewType();
  await settingsProvider.initMixpanel();
  await _initialization;

  runApp(caffeine(
    settingsProvider: settingsProvider,
  ));
}

class caffeine extends StatefulWidget {
  const caffeine({required this.settingsProvider, Key? key}) : super(key: key);

  final SettingsProvider settingsProvider;

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
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

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
                })
              ],
              child: Consumer<SettingsProvider>(
                  builder: (context, settingsProvider, snapshot) {
                return DynamicColorBuilder(
                  builder: (lightDynamic, darkDynamic) {
                    return MaterialApp(
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
}
