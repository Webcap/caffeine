import 'dart:async';

import 'package:caffiene/utils/app_images.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/utils/helpers/injection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    splashLogin();
    super.initState();
  }

  splashLogin() async {
    print("calling splashLogin");
    var connectivityResult = await (Connectivity().checkConnectivity());
    // SharedPreferences pref = await SharedPreferences.getInstance();
    Timer(const Duration(seconds: 3), () {
      if (connectivityResult == ConnectivityResult.none &&
          auth.currentUser != null) {
        print("user Sgned in");
        // Get.offAll(() => const DownloadOffline());
      } else {
        DependencyInjection.init();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(),
          SvgPicture.asset(
            MovixIcon.appLogo,
            height: Get.height / 4,
          ),
          const SpinKitCircle(
            color: Colors.red,
            size: 60,
          ),
        ],
      ),
    ));
  }
}
