import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:login/provider/internet_provider.dart';
import 'package:login/provider/sign_in_provider.dart';
import 'package:login/utils/config.dart';
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
      backgroundColor: Colors.white,
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
                    const Text("Welcome to Whatever",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w500)),
                    Text(
                      "Flutter auth with Provider",
                      style: TextStyle(fontSize: 15, color: Colors.grey[600]),
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
                      color: Colors.red,
                      child: Wrap(
                        children: const [
                          Icon(
                            FontAwesomeIcons.google,
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(width: 15),
                          Text("Sign in with Google",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500))
                        ],
                      )),

                  const SizedBox(
                    height: 10,
                  ),
                  // facebook button

                  RoundedLoadingButton(
                      controller: facebookController,
                      onPressed: () {},
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
    if(ip.hasInternet == false){
      
    }
  }
}
