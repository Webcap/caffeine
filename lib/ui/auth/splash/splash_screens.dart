import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:login/provider/sign_in_provider.dart';
import 'package:login/screens/home_screen/dash_screen.dart';
import 'package:login/screens/home_screen/home_screen.dart';
import 'package:login/screens/auth_screens/login_screen.dart';
import 'package:login/ui/auth/splash/tv_splash.dart';
import 'package:login/ui/home/tv_mode_main.dart';
import 'package:login/ui/auth/login_page/login_page_TV.dart';
import 'package:login/utils/config.dart';
import 'package:login/utils/next_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool? isAndroidTV;
  // init state
  @override
  void initState() {
    super.initState();
    loadInfo();

    // create a timer for 2 secs
    // Timer(const Duration(seconds: 2), () {
    //   sp.isSignedIn == false
    //       ? nextScreen(context, LoginScreen())
    //       : nextScreen(context, caffieneHomePage());
    // });
  }

  void loadInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final sp = context.read<SignInProvider>();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      isAndroidTV =
          androidInfo.systemFeatures.contains('android.software.leanback');
      print(isAndroidTV);
      if (isAndroidTV == true) {
        // IF TV DO THIS
        // todo: change to login screen
        print("starting android tv layout");
        Timer(const Duration(seconds: 1), () {
          nextScreen(context, Splash());
          // sp.isSignedIn == false
          //     ? nextScreen(context, Splash()) // todo: change this to LoginPage()
          //     : nextScreen(context, tvModeMain());
        });
      } else {
        //create a timer for 2 secs
        print("not tv");
        Timer(const Duration(seconds: 2), () {
          sp.isSignedIn == false
              ? nextScreen(context, LoginScreen())
              : nextScreen(context, caffieneHomePage());
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFea575e),
      body: SafeArea(
          child: Center(
        child: Image(
          image: AssetImage(Config.app_icon),
          height: 150,
          width: 150,
        ),
      )),
    );
  }
}
