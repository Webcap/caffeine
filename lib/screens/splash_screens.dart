import 'dart:async';

import 'package:flutter/material.dart';
import 'package:login/provider/sign_in_provider.dart';
import 'package:login/screens/home_screen.dart';
import 'package:login/screens/login_screen.dart';
import 'package:login/utils/config.dart';
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
          ? Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginScreen()))
          : Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Image(
          image: AssetImage(Config.app_icon),
          height: 80,
          width: 80,
        ),
      )),
    );
  }
}
