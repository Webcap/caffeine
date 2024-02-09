import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:caffiene/utils/app_images.dart';
import 'package:caffiene/utils/routes/app_pages.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/utils/config.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
// import 'package:permission_handler/permission_handler.dart';


class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  bool anonButtonVisible = true;

  @override
  void initState() {
    // [
    //   Permission.notification,
    //   Permission.storage
    // ].request();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    // void updateFirstRunData() async {
    //   final sharedPrefsSingleton = await SharedPreferences.getInstance();
    //   await sharedPrefsSingleton.setBool('isFirstRun', false);
    // }


    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: Get.height,
            width: Get.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    'assets/images/grid_final.jpg',
                  ),
                  fit: BoxFit.cover),
            ),
            child: Container(
              decoration: const BoxDecoration(
                // color: Colors.black.withOpacity(0.5),
                gradient: LinearGradient(
                  colors: [Color(0xff000000), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
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
                        color: maincolor3,
                      ),
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
                                    color: Colors.transparent,
                                  ),
                                  height: 150,
                                  width: 150,
                                  child: Hero(
                                    tag: 'logo_shadow',
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SvgPicture.asset(
                                        MovixIcon.appLogo,
                                        height: Get.height / 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Text(tr("thousands_of"),
                                  style: const TextStyle(color: Colors.black)),
                              SizedBox(
                                height: 75,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: AnimatedTextKit(
                                    repeatForever: true,
                                    animatedTexts: [
                                      animatedTextWIdget(
                                          textTitle: tr("top_rated_movies"),
                                          animationDuration: 90,
                                          fontSize: 25),
                                      animatedTextWIdget(
                                          textTitle: tr("top_rated_tv_shows"),
                                          animationDuration: 90,
                                          fontSize: 25),
                                      animatedTextWIdget(
                                          textTitle: tr("trending_movies"),
                                          animationDuration: 90,
                                          fontSize: 25),
                                      animatedTextWIdget(
                                          textTitle: tr("trending_tv_shows"),
                                          animationDuration: 90,
                                          fontSize: 25),
                                      animatedTextWIdget(
                                          textTitle: tr("popular_movies"),
                                          animationDuration: 90,
                                          fontSize: 25),
                                      animatedTextWIdget(
                                          textTitle: tr("popular_tv_shows"),
                                          animationDuration: 90,
                                          fontSize: 25),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  tr("unlimited_on_caffiene"),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      //  crossAxisAlignment: WrapCrossAlignment.start,
                      // spacing: 10,
                      children: [
                        // ElevatedButton(
                        //     style: ButtonStyle(
                        //         minimumSize: MaterialStateProperty.all(
                        //             const Size(150, 50)),
                        //         shape: MaterialStateProperty.all<
                        //             RoundedRectangleBorder>(
                        //           RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(20.0),
                        //           ),
                        //         ),
                        //         backgroundColor:
                        //             MaterialStateProperty.all(maincolor)),
                        //     onPressed: () async {
                        //       // updateFirstRunData();
                        //       nextScreen(context, const LoginScreen());
                        //     },
                        //     child: Text(
                        //       tr("log_in"),
                        //       style: const TextStyle(color: Colors.white),
                        //     )),
                        const SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                            style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(
                                    const Size(175, 50)),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                backgroundColor:
                                    MaterialStateProperty.all(maincolor)),
                            onPressed: () async {
                              // updateFirstRunData();
                              Get.offAllNamed(Routes.login);
                            },
                            child: Text(
                              tr("get_started"),
                              style: const TextStyle(color: Colors.white),
                            )),
                        // ElevatedButton(
                        //     style: ButtonStyle(
                        //         minimumSize: MaterialStateProperty.all(
                        //             const Size(150, 50)),
                        //         shape: MaterialStateProperty.all<
                        //             RoundedRectangleBorder>(
                        //           RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(20.0),
                        //           ),
                        //         ),
                        //         backgroundColor:
                        //             MaterialStateProperty.all(Colors.white)),
                        //     onPressed: () async {
                        //       // updateFirstRunData();
                        //       nextScreen(context, const SignupScreen());
                        //     },
                        //     child: Text(
                        //       tr("sign_up"),
                        //       style: const TextStyle(color: Colors.black),
                        //     )),
                        // const SizedBox(
                        //   height: 40,
                        // ),

                        // anonButtonVisible
                        //     ? ElevatedButton(
                        //         style: ButtonStyle(
                        //             minimumSize: MaterialStateProperty.all(
                        //                 const Size(150, 50)),
                        //             shape: MaterialStateProperty.all<
                        //                 RoundedRectangleBorder>(
                        //               RoundedRectangleBorder(
                        //                 borderRadius:
                        //                     BorderRadius.circular(20.0),
                        //               ),
                        //             ),
                        //             backgroundColor: MaterialStateProperty.all(
                        //                 const Color(0xFFfad2aa))),
                        //         onPressed: () async {
                        //           setState(() {
                        //             anonButtonVisible = false;
                        //           });
                        //           await checkConnection().then((value) async {
                        //             if (value && mounted) {
                        //               await auth
                        //                   .signInAnonymously()
                        //                   .then((value) {
                        //                 mixpanel.track(
                        //                   'Anonymous Login',
                        //                 );
                        //                 setState(() {
                        //                   anonButtonVisible = true;
                        //                 });
                        //                 nextScreen(
                        //                     context, const caffieneHomePage());
                        //               });
                        //             } else {
                        //               ScaffoldMessenger.of(context)
                        //                   .showSnackBar(
                        //                 SnackBar(
                        //                   content: Text(
                        //                     tr("check_connection"),
                        //                     maxLines: 3,
                        //                     style: kTextSmallBodyStyle,
                        //                   ),
                        //                   duration: const Duration(seconds: 3),
                        //                 ),
                        //               );
                        //             }
                        //           });
                        //         },
                        //         child: Text(
                        //           tr("continue_anonymously"),
                        //           style: const TextStyle(color: Colors.black),
                        //         ))
                        //     : const CircularProgressIndicator()
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
