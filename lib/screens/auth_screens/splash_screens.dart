import 'dart:async';

import 'package:flutter/material.dart';
import 'package:login/provider/sign_in_provider.dart';
import 'package:login/screens/home_screen/home_screen.dart';
import 'package:login/screens/auth_screens/login_screen.dart';
import 'package:login/utils/config.dart';
import 'package:login/utils/next_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // init state
  @override
  void initState() {
    final sp = context.read<SignInProvider>();
    super.initState();
    // create a timer for 2 secs
    Timer(const Duration(seconds: 2), () {
      sp.isSignedIn == false
          ? nextScreen(context, LoginScreen())
          : nextScreen(context, HomeScreen());
    });
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
