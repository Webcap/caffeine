// ignore_for_file: unused_field

import 'package:caffiene/functions/functions.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/provider/sign_in_provider.dart';
import 'package:caffiene/screens/auth_screens/login_screen.dart';
import 'package:caffiene/utils/app_colors.dart';
import 'package:caffiene/utils/app_images.dart';
import 'package:caffiene/utils/next_screen.dart';
import 'package:caffiene/utils/routes/app_pages.dart';
import 'package:caffiene/utils/snackbar.dart';
import 'package:caffiene/utils/textStyle.dart';
import 'package:caffiene/widgets/size_configuration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class welcomeScreen extends StatefulWidget {
  const welcomeScreen({Key? key}) : super(key: key);

  @override
  _welcomeScreenState createState() => _welcomeScreenState();
}

class _welcomeScreenState extends State<welcomeScreen> {
  bool anonButtonVisible = true;
  bool googleButtonVisable = true;
  late DocumentSnapshot subscription;
  late DocumentSnapshot Watch_history_subscription;

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final mixpanel = Provider.of<SettingsProvider>(context).mixpanel;
    SizeConfig().init(context);
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: Get.height / 5,
            ),
            Container(
              alignment: Alignment.center,
              height: Get.height / 4.5,
              decoration: const BoxDecoration(),
              child: SvgPicture.asset(MovixIcon.appLogo),
            ),
            SizedBox(
              height: Get.height / 35,
            ),
            Text(
              "Let's Get Started",
              textAlign: TextAlign.center,
              style: letsInStyle,
            ),
            SizedBox(
              height: Get.height / 35,
            ),

            /// Google LogIn ///
            googleButtonVisable
                ? InkWell(
                    onTap: () async {
                      setState(() {
                        googleButtonVisable = false;
                      });
                      handleGoogleSignin();
                    },
                    child: Container(
                      height: Get.height / 14.5,
                      width: Get.width / 1.1,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: themeMode == "dark" || themeMode == "amoled"
                              ? Colors.transparent
                              : const Color(0xffeeeeee),
                          width: 1,
                        ),
                        color: themeMode == "dark" || themeMode == "amoled"
                            ? ColorValues.darkmodesecond
                            : ColorValues.whiteColor,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor:
                                    themeMode == "dark" || themeMode == "amoled"
                                        ? ColorValues.darkmodesecond
                                        : ColorValues.whiteColor,
                                child: SvgPicture.asset(MovixIcon.google),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Continue with Google",
                                style: loginMathodStyle,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : const CircularProgressIndicator(),

            SizedBox(
              height: Get.height / 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 135,
                  height: 1,
                  color: themeMode == "dark" || themeMode == "amoled"
                      ? ColorValues.darkmodethird
                      : ColorValues.lightGrayColor,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "or",
                  style: orStyle,
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  width: 135,
                  height: 1,
                  color: themeMode == "dark" || themeMode == "amoled"
                      ? ColorValues.darkmodethird
                      : ColorValues.lightGrayColor,
                ),
              ],
            ),
            SizedBox(
              height: Get.height / 30,
            ),

            /// Email LogIn ///
            InkWell(
              onTap: () async {
                nextScreen(context, LoginScreen());
              },
              child: Container(
                height: 47,
                width: Get.width / 1.1,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: const [
                    BoxShadow(
                      color: ColorValues.shadowRedColor,
                      blurRadius: 24,
                      offset: Offset(4, 8),
                    ),
                  ],
                  color: ColorValues.shadow2RedColor,
                ),
                child: Text(
                  'Continue with Email',
                  textAlign: TextAlign.center,
                  style: signInWithPasswordStyle,
                ),
              ),
            ),
            SizedBox(
              height: Get.height / 30,
            ),

            /// Annon LogIn ///
            anonButtonVisible
                ? InkWell(
                    onTap: () async {
                      setState(() {
                        anonButtonVisible = false;
                      });
                      await checkConnection().then((value) async {
                        if (value && mounted) {
                          await auth.signInAnonymously().then((value) {
                            mixpanel.track(
                              'Anonymous Login',
                            );
                            setState(() {
                              anonButtonVisible = true;
                            });
                            Get.offAllNamed(Routes.dash);
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                tr("check_connection"),
                                maxLines: 3,
                                style: kTextSmallBodyStyle,
                              ),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      });
                    },
                    child: Container(
                      height: 47,
                      width: Get.width / 1.1,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: const [
                          BoxShadow(
                            color: ColorValues.shadowRedColor,
                            blurRadius: 24,
                            offset: Offset(4, 8),
                          ),
                        ],
                        color: const Color.fromARGB(255, 18, 84, 226),
                      ),
                      child: Text(
                        tr("continue_anonymously"),
                        textAlign: TextAlign.center,
                        style: signInWithPasswordStyle,
                      ),
                    ),
                  )
                : const CircularProgressIndicator()
          ],
        ),
      ),
    );
  }

  Future handleGoogleSignin() async {
    final sp = context.read<SignInProvider>();
    await sp.signInWithGoogle().then((value) {
      if (sp.hasError == true) {
        openSnackbar(context, sp.errorCode.toString(), Colors.red);
        setState(() {
          googleButtonVisable = true;
        });
      } else {
        // checking DB to see if User exists
        sp.checkuserExists().then((value) async {
          if (value == true) {
            //exists
            await sp.getUserDataFromFirestore(sp.uid).then((value) => sp
                .saveDatatoSharedPreferences()
                .then((value) => sp.setSignIn().then((value) {
                      openSnackbar(
                          context, "Alright, You're Good Buddy.", Colors.green);
                      handleAfterSignIn();
                    })));
          } else {
            //does not exists
            sp.saveDatatoFirestore().then((value) => sp
                .saveDatatoSharedPreferences()
                .then((value) => sp.setSignIn().then((value) {
                      openSnackbar(
                          context, "Alright, You're Good Buddy.", Colors.green);
                      handleAfterSignIn();
                    })));
          }
        });
      }
    });
  }

  // handle after signin
  handleAfterSignIn() {
    final sp = context.read<SignInProvider>();
    sp.getDataFromSharedPreferences();

    Future.delayed(const Duration(milliseconds: 1000)).then((value) async {
      if (sp.firstRun == false && sp.provider == "google") {
        FirebaseFirestore.instance.collection('bookmarks').doc(sp.uid).set({});
        subscription = await FirebaseFirestore.instance
            .collection('bookmarks')
            .doc(sp.uid)
            .get();
        final docData = subscription.data() as Map<String, dynamic>;

        if (docData.containsKey('movies') == false) {
          await FirebaseFirestore.instance
              .collection('bookmarks')
              .doc(sp.uid)
              .update({'movies': []});
        }
        if (docData.containsKey('tvShows') == false) {
          await FirebaseFirestore.instance
              .collection('bookmarks')
              .doc(sp.uid)
              .update(
            {'tvShows': []},
          );
        }
        await FirebaseFirestore.instance
            .collection('watch_history')
            .doc(sp.uid)
            .set({});

        Watch_history_subscription = await FirebaseFirestore.instance
            .collection('watch_history')
            .doc(sp.uid)
            .get();

        if (docData.containsKey('movies') == false) {
          await FirebaseFirestore.instance
              .collection('watch_history')
              .doc(sp.uid)
              .update(
            {'movies': []},
          );
        }

        if (docData.containsKey('tvShows') == false) {
          await FirebaseFirestore.instance
              .collection('watch_history')
              .doc(sp.uid)
              .update(
            {'tvShows': []},
          );
        }

        await sp.createRandomUsername().then((value) {
          print("creating Username");
          print(value);
          sp.insertUsername(value, sp.uid.toString());
          FirebaseFirestore.instance.collection('users').doc(sp.uid).update({
            'username': value,
          });
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(sp.uid)
            .update({'firstRun': true});

        Get.offAllNamed(Routes.dash);
      } else {
        Get.offAllNamed(Routes.dash);
      }
    });
  }
}
