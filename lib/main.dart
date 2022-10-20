import 'dart:io';

import 'package:another_tv_remote/another_tv_remote.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login/models/device_info_model.dart';
import 'package:login/provider/adultmode_provider.dart';
import 'package:login/provider/default_home_provider.dart';
import 'package:login/provider/imagequality_provider.dart';
import 'package:login/provider/internet_provider.dart';
import 'package:login/provider/mixpanel_provider.dart';
import 'package:login/provider/sign_in_provider.dart';
import 'package:login/screens/auth_screens/splash_screens.dart';
import 'package:login/tv_mode/tv_mode_home.dart';
import 'package:login/utils/next_screen.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  //initialize app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const caffeine());
}

class caffeine extends StatefulWidget {
  const caffeine({super.key});

  @override
  State<caffeine> createState() => _caffeineState();
}

class _caffeineState extends State<caffeine>
    with ChangeNotifier, WidgetsBindingObserver {
  bool? isFirstLaunch;
  bool? isAndroidTV;
  SignInProvider signInProvider = SignInProvider();
  InternetProvider internetProvider = InternetProvider();
  MixpanelProvider mixpanelProvider = MixpanelProvider();
  ImagequalityProvider imagequalityProvider = ImagequalityProvider();
  DefaultHomeProvider defaultHomeProvider = DefaultHomeProvider();
  AdultmodeProvider adultmodeProvider = AdultmodeProvider();
  late Mixpanel mixpanel;
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
    mixpanelProvider.initMixpanel();
    getCurrentDefaultScreen();
    loadInfo();
    // initPlatformState();

    // AnotherTvRemote.getTvRemoteEvents().listen((event) {
    //   print("Received event: $event");
    //   if (event.action == KeyAction.down) {
    //     if (event.type == KeyType.dPadDown) {
    //       // _listController.animateTo(_listController.position.pixels + 100,
    //       //     duration: const Duration(microseconds: 100),
    //       //     curve: Curves.easeIn);
    //     } else if (event.type == KeyType.dPadUp) {
    //       // _listController.animateTo(_listController.position.pixels - 100,
    //       //     duration: const Duration(microseconds: 100),
    //       //     curve: Curves.easeIn);
    //     } else if (event.type == KeyType.ok) {

    //     }
    //   }
    // });
  }

  void loadInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final prefs = await SharedPreferences.getInstance();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      isAndroidTV =
          androidInfo.systemFeatures.contains('android.software.leanback');
      print(isAndroidTV);
    }
  }

  void getCurrentDefaultScreen() async {
    defaultHomeProvider.defaultValue =
        await defaultHomeProvider.defaultHomePreferences.getDefaultHome();
  }

  void getCurrentImageQuality() async {
    imagequalityProvider.imageQuality =
        await imagequalityProvider.imagePreferences.getImageQuality();
  }

  void getCurrentAdultMode() async {
    adultmodeProvider.isAdult =
        await adultmodeProvider.adultModePreferences.getAdultMode();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: ((context) => SignInProvider())),
        ChangeNotifierProvider(create: ((context) => MixpanelProvider())),
        ChangeNotifierProvider(create: ((context) => InternetProvider())),
        ChangeNotifierProvider(create: ((context) => AdultmodeProvider())),
        ChangeNotifierProvider(create: ((context) => DefaultHomeProvider())),
        ChangeNotifierProvider(create: ((context) => ImagequalityProvider())),
      ],
      child: Consumer6<SignInProvider, ImagequalityProvider, MixpanelProvider,
              InternetProvider, DefaultHomeProvider, AdultmodeProvider>(
          builder: (context,
              SignInProvider,
              mixpanelProvider,
              internetProvider,
              defaultHomeProvider,
              ImagequalityProvider,
              AdultmodeProvider,
              snapshot) {
        return Shortcuts(
            shortcuts: <LogicalKeySet, Intent>{
              LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
              LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
            },
            child: MaterialApp(
              home: SplashScreen(),
              debugShowCheckedModeBanner: false,
            ));
      }),
      // child: MaterialApp(
      //   home: SplashScreen(),
      //   debugShowCheckedModeBanner: false,
      // ),
    );
  }
}
