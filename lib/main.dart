import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:login/provider/internet_provider.dart';
import 'package:login/provider/mixpanel_provider.dart';
import 'package:login/provider/sign_in_provider.dart';
import 'package:login/screens/auth_screens/splash_screens.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:provider/provider.dart';

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
  late Mixpanel mixpanel;

  @override
  void initState() {
    super.initState();
    mixpanelProvider.initMixpanel();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: ((context) => SignInProvider())),
        ChangeNotifierProvider(create: ((context) => MixpanelProvider())),
        ChangeNotifierProvider(create: ((context) => InternetProvider())),
      ],
      child: Consumer3<SignInProvider, MixpanelProvider, InternetProvider>(
          builder: (context, SignInProvider, MixpanelProvider, internetProvider,
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
