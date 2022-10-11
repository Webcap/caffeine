import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:login/provider/internet_provider.dart';
import 'package:login/provider/mixpanel_provider.dart';
import 'package:login/provider/sign_in_provider.dart';
import 'package:login/screens/splash_screens.dart';
import 'package:provider/provider.dart';

void main() async {
  //initialize app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const myApp());
}

class myApp extends StatelessWidget {
  const myApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: ((context)=> SignInProvider())),
        ChangeNotifierProvider(create: ((context)=> MixpanelProvider())),
        ChangeNotifierProvider(create: ((context) => InternetProvider())),
      ],
      child: MaterialApp(
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
