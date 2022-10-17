import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:login/provider/default_home_provider.dart';
import 'package:login/provider/imagequality_provider.dart';
import 'package:login/provider/internet_provider.dart';
import 'package:login/provider/mixpanel_provider.dart';
import 'package:login/provider/sign_in_provider.dart';
import 'package:login/screens/auth_screens/splash_screens.dart';
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
  SignInProvider signInProvider = SignInProvider();
  InternetProvider internetProvider = InternetProvider();
  MixpanelProvider mixpanelProvider = MixpanelProvider();
  ImagequalityProvider imagequalityProvider = ImagequalityProvider();
  DefaultHomeProvider defaultHomeProvider = DefaultHomeProvider();
  late Mixpanel mixpanel;

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
  }
  void getCurrentDefaultScreen() async {
    defaultHomeProvider.defaultValue =
        await defaultHomeProvider.defaultHomePreferences.getDefaultHome();
  }

  void getCurrentImageQuality() async {
    imagequalityProvider.imageQuality =
        await imagequalityProvider.imagePreferences.getImageQuality();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: ((context) => SignInProvider())),
        ChangeNotifierProvider(create: ((context) => MixpanelProvider())),
        ChangeNotifierProvider(create: ((context) => InternetProvider())),
        ChangeNotifierProvider(create: ((context) => DefaultHomeProvider())),
        ChangeNotifierProvider(create: ((context) => ImagequalityProvider())),
      ],
      child: Consumer5<SignInProvider, ImagequalityProvider, MixpanelProvider, InternetProvider,
              DefaultHomeProvider>(
          builder: (context, 
            SignInProvider, 
            mixpanelProvider, 
            internetProvider,
            defaultHomeProvider,
            ImagequalityProvider, 
            snapshot) {
        return MaterialApp(
          home: SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      }),
      // child: MaterialApp(
      //   home: SplashScreen(),
      //   debugShowCheckedModeBanner: false,
      // ),
    );
  }
}
