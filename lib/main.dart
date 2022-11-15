import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login/provider/adultmode_provider.dart';
import 'package:login/provider/default_home_provider.dart';
import 'package:login/provider/imagequality_provider.dart';
import 'package:login/provider/internet_provider.dart';
import 'package:login/provider/sign_in_provider.dart';
import 'package:login/provider/tv_mode_provider.dart';
import 'package:login/ui/auth/splash/splash_screens.dart';
import 'package:login/ui/home/tv_mode_main.dart';
import 'package:login/ui/auth/login_page/login_page_TV.dart';
import 'package:login/utils/next_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

SignInProvider signInProvider = SignInProvider();
tvModeProvider tvmodeProvider = tvModeProvider();
InternetProvider internetProvider = InternetProvider();
ImagequalityProvider imagequalityProvider = ImagequalityProvider();
DefaultHomeProvider defaultHomeProvider = DefaultHomeProvider();
AdultmodeProvider adultmodeProvider = AdultmodeProvider();

extension Precision on double {
  double toPrecision(int fractionDigits) {
    num mod = pow(10, fractionDigits.toDouble());
    return ((this * mod).round().toDouble() / mod);
  }
}

void main() async {
  //initialize app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await imagequalityProvider.getCurrentImageQuality();
  runApp(caffeine(
    image: imagequalityProvider,
  ));
}

class caffeine extends StatefulWidget {
  const caffeine({
    required this.image,
    Key? key,
  }) : super(key: key);
  final ImagequalityProvider image;

  @override
  State<caffeine> createState() => _caffeineState();
}

class _caffeineState extends State<caffeine>
    with ChangeNotifier, WidgetsBindingObserver {
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
    getCurrentDefaultScreen();
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

  void getTVModeStats() async {
    tvmodeProvider.tvModeValue =
        await tvmodeProvider.tvModePref.getTVModeStatus();
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
        ChangeNotifierProvider(create: ((context) => tvModeProvider())),
        ChangeNotifierProvider(create: ((context) => InternetProvider())),
        ChangeNotifierProvider(create: ((context) => AdultmodeProvider())),
        ChangeNotifierProvider(create: ((context) => DefaultHomeProvider())),
        ChangeNotifierProvider(create: ((context) => ImagequalityProvider())),
      ],
      child: Consumer6<SignInProvider, ImagequalityProvider, tvModeProvider,
              InternetProvider, DefaultHomeProvider, AdultmodeProvider>(
          builder: (context,
              SignInProvider,
              tvModeProvider,
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
              routes: {
                "/login": (context) => LoginPage(),
              },
            ));
      }),
      // child: MaterialApp(
      //   home: SplashScreen(),
      //   debugShowCheckedModeBanner: false,
      // ),
    );
  }
}
