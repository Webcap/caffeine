import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter/src/widgets/placeholder.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/auth_screens/login_screen.dart';
import 'package:caffiene/screens/auth_screens/login_screen_042023.dart';
import 'package:caffiene/screens/auth_screens/register_screen.dart';
import 'package:caffiene/screens/home_screen/dash_screen.dart';
import 'package:caffiene/screens/auth_screens/login_page/login_page_TV.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/utils/next_screen.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    final mixpanel = Provider.of<SettingsProvider>(context).mixpanel;
    return Stack(
      children: [
        Container(
          height: deviceHeight,
          width: deviceWidth,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(grid_landing_photo), fit: BoxFit.cover)),
          child: Container(
            decoration: const BoxDecoration(
                //color: Colors.black.withOpacity(0.5),
                gradient: LinearGradient(
              colors: [Color(0xff000000), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            )),
          ),
        ),
        Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    height: 400,
                    width: 350,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: maincolor),
                    child: Center(
                      child: SizedBox(
                        width: 250.0,
                        child: DefaultTextStyle(
                          style: const TextStyle(
                            fontSize: 30.0,
                            fontFamily: 'PoppinsBold',
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white),
                                  height: 100,
                                  width: 100,
                                  child: Hero(
                                    tag: 'logo_shadow',
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset(Config.app_icon),
                                    ),
                                  ),
                                ),
                              ),
                              const Text(
                                'Thousands of:',
                                style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(
                                height: 75,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: AnimatedTextKit(
                                    repeatForever: true,
                                    animatedTexts: [
                                      animatedTextWIdget(
                                          textTitle: 'Top rated movies',
                                          animationDuration: 90,
                                          fontSize: 25),
                                      animatedTextWIdget(
                                          textTitle: 'Top rated tv shows',
                                          animationDuration: 90,
                                          fontSize: 25),
                                      animatedTextWIdget(
                                          textTitle: 'Trending movies',
                                          animationDuration: 90,
                                          fontSize: 25),
                                      animatedTextWIdget(
                                          textTitle: 'Trending tv shows',
                                          animationDuration: 90,
                                          fontSize: 25),
                                      animatedTextWIdget(
                                          textTitle: 'Popular movies',
                                          animationDuration: 90,
                                          fontSize: 25),
                                      animatedTextWIdget(
                                          textTitle: 'Popular tv shows',
                                          animationDuration: 90,
                                          fontSize: 25),
                                    ],
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 10.0),
                                child: Text(
                                  TAG_LINE1,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                            minimumSize:
                                MaterialStateProperty.all(const Size(150, 50)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all(
                                const Color(0xFFFea575e))),
                        onPressed: () async {
                          //updateFirstRunData();
                          nextScreen(context, LoginPage423());
                        },
                        child: const Text(
                          SIGN_IN,
                          style: kTextStyleColorBlack,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                            minimumSize:
                                MaterialStateProperty.all(const Size(150, 50)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white)),
                        onPressed: () async {
                          //updateFirstRunData();
                          nextScreen(context, SignupScreen());
                        },
                        child: const Text(
                          SIGN_UP,
                          style: kTextStyleColorBlack,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                          style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all(
                                  const Size(150, 50)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              backgroundColor: MaterialStateProperty.all(
                                  const Color(0xFFfad2aa))),
                          onPressed: () async {
                            // updateFirstRunData();
                            showDialog(
                                context: context,
                                builder: (BuildContext ctx) {
                                  return AlertDialog(
                                    title: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Login anonymously?'),
                                    ),
                                    content: const Text(
                                        'Do you want to Login anonymously? You\'ll lose bookmark syncing feature, login or signup to Caffiene instead'),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Go back')),
                                      TextButton(
                                          onPressed: () async {
                                            await auth
                                                .signInAnonymously()
                                                .then((value) {
                                              mixpanel.track(
                                                'Anonymous Login',
                                              );
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return const caffieneHomePage();
                                              }));
                                            });
                                          },
                                          child: const Text(
                                            'Proceed anonymously',
                                            style: TextStyle(color: Colors.red),
                                          ))
                                    ],
                                  );
                                });
                          },
                          child: const Text(
                            'Continue anonymously',
                            style: TextStyle(color: Colors.black),
                          )),
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  TypewriterAnimatedText animatedTextWIdget(
      {required String textTitle,
      required int animationDuration,
      required double fontSize}) {
    return TypewriterAnimatedText(textTitle,
        speed: Duration(milliseconds: animationDuration),
        textStyle: TextStyle(
          fontSize: fontSize,
        ),
        textAlign: TextAlign.center);
  }
}
