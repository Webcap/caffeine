import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:login/provider/internet_provider.dart';
import 'package:login/provider/sign_in_provider.dart';
import 'package:login/screens/home_screen/dash_screen.dart';
import 'package:login/screens/home_screen/home_screen.dart';
import 'package:login/utils/config.dart';
import 'package:login/utils/next_screen.dart';
import 'package:login/utils/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
  final RoundedLoadingButtonController googleController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController facebookController =
      RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFea575e),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 40, right: 40, top: 90, bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image(
                      image: AssetImage(Config.app_icon),
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text("Welcome to caffeiene",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w500)),
                    Text(
                      "Secret TV club for the elites",
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    )
                  ],
                ),
              ),

              // roundedButton
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoundedLoadingButton(
                      controller: googleController,
                      onPressed: () {
                        handleGoogleSignin();
                      },
                      successColor: Colors.red,
                      width: MediaQuery.of(context).size.width * 0.80,
                      elevation: 0,
                      borderRadius: 25,
                      color: Colors.white,
                      child: Wrap(
                        children: const [
                          Icon(
                            FontAwesomeIcons.google,
                            size: 20,
                            color: Colors.red,
                          ),
                          SizedBox(width: 15),
                          Text("Sign in with Google",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500))
                        ],
                      )),

                  const SizedBox(
                    height: 10,
                  ),
                  // facebook button

                  RoundedLoadingButton(
                      controller: facebookController,
                      onPressed: () {
                        nextScreenReplace(context, dash_screen());
                      },
                      successColor: Colors.blue,
                      width: MediaQuery.of(context).size.width * 0.80,
                      elevation: 0,
                      borderRadius: 25,
                      color: Colors.blue,
                      child: Wrap(
                        children: const [
                          Icon(
                            FontAwesomeIcons.facebook,
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(width: 15),
                          Text("Sign in with Facebook",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500))
                        ],
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // handling google sign in
  Future handleGoogleSignin() async {
    final sp = context.read<SignInProvider>();
    // internet provider
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();
    if (ip.hasInternet == false) {
      openSnackbar(context, "Check your internet connection", Colors.red);
      googleController.reset();
    } else {
      await sp.signInWithGoogle().then((value) {
        if (sp.hasError == true) {
          openSnackbar(context, sp.errorCode.toString(), Colors.red);
          googleController.reset();
        } else {
          // checking DB to see if User exists
          sp.checkuserExists().then((value) async {
            if (value == true) {
              //exists
              await sp.getUserDataFromFirestore(sp.uid).then((value) => sp
                  .saveDatatoSharedPreferences()
                  .then((value) => sp.setSignIn().then((value) {
                        googleController.success();
                        handleAfterSignIn();
                      })));
            } else {
              //does not exists
              sp.saveDatatoFirestore().then((value) => sp
                  .saveDatatoSharedPreferences()
                  .then((value) => sp.setSignIn().then((value) {
                        googleController.success();
                        handleAfterSignIn();
                      })));
            }
          });
        }
      });
    }
  }

  // handle after signin
  handleAfterSignIn() {
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      nextScreenReplace(context, HomeScreen());
    });
  }
}
