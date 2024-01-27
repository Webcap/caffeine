import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/provider/sign_in_provider.dart';
import 'package:caffiene/utils/app_colors.dart';
import 'package:caffiene/utils/app_images.dart';
import 'package:caffiene/utils/routes/app_pages.dart';
import 'package:caffiene/utils/snackbar.dart';
import 'package:caffiene/utils/textStyle.dart';
import 'package:caffiene/widgets/size_configuration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mixpanel_flutter/web/mixpanel_js_bindings.dart';
import 'package:provider/provider.dart';

class LoginScreen1 extends StatefulWidget {
  const LoginScreen1({Key? key}) : super(key: key);

  @override
  _LoginScreen1State createState() => _LoginScreen1State();
}

class _LoginScreen1State extends State<LoginScreen1> {
  bool anonButtonVisible = true;

  @override
  Widget build(BuildContext context) {
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
            InkWell(
              onTap: () async {
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
            ),
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
                print("Email");
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
                      print("Email");
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
                : Container()
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
      } else {
        // checking DB to see if User exists
        sp.checkuserExists().then((value) async {
          if (value == true) {
            //exists
            await sp.getUserDataFromFirestore(sp.uid).then((value) => sp
                .saveDatatoSharedPreferences()
                .then((value) => sp.setSignIn().then((value) {
                      handleAfterSignIn();
                    })));
          } else {
            //does not exists
            sp.saveDatatoFirestore().then((value) => sp
                .saveDatatoSharedPreferences()
                .then((value) => sp.setSignIn().then((value) {
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

    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      // if (sp.firstRun == false && sp.provider == "google") {
      //   print("do first login Stuff");
      // }
      print(sp.firstRun);
    });
  }
}
