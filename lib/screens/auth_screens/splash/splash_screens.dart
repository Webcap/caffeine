import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/provider/sign_in_provider.dart';
import 'package:caffiene/screens/home_screen/dash_screen.dart';
import 'package:caffiene/screens/home_screen/home_screen.dart';
import 'package:caffiene/screens/auth_screens/login_screen.dart';
import 'package:caffiene/screens/auth_screens/splash/tv_splash.dart';
import 'package:caffiene/screens/auth_screens/login_page/login_page_TV.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/utils/next_screen.dart';
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
          //     ? nextScreen(context, LoginPage()) // todo: change this to LoginPage()
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
          image: AssetImage(appConfig.app_icon),
          height: 150,
          width: 150,
        ),
      )),
    );
  }
}
