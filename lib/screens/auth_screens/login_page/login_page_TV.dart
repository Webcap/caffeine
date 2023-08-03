import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:caffiene/key_code.dart';
import 'package:caffiene/provider/internet_provider.dart';
import 'package:caffiene/provider/sign_in_provider.dart';
import 'package:caffiene/screens/home_screen/tvHomeScreen.dart';
import 'package:caffiene/utils/next_screen.dart';
import 'package:caffiene/utils/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:transparent_image/transparent_image.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void focusNode;
  FocusNode main_focus_node = FocusNode();
  FocusNode username_focus_node = FocusNode();
  FocusNode password_focus_node = FocusNode();
  FocusNode googleButton_focus_node = FocusNode();

  final RoundedLoadingButtonController googleController =
      RoundedLoadingButtonController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool emailvalide = true;
  bool passwordvalide = true;
  bool loading = false;
  final String _message_error = "";
  bool _visibile_error = false;
  int pos_y = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(username_focus_node);
    });
  }

  _login(String email, String password) async {
    setState(() {
      loading = true;
      _visibile_error = false;
    });
    var response;
    var body = {'username': email, 'password': password};

    // response = await apiRest.loginUser(body);
    // print(response.body);
    // if (response != null) {
    //   if (response.statusCode == 200) {
    //     var jsonData = convert.jsonDecode(response.body);
    //     if (jsonData["code"] == 200) {
    //       int id_user = 0;
    //       String name_user = "x";
    //       String username_user = "x";
    //       String email_user = "";
    //       String subscribed_user = "FALSE";
    //       String salt_user = "0";
    //       String token_user = "0";
    //       String type_user = "x";
    //       String image_user = "x";
    //       bool enabled = false;

    //       for (Map i in jsonData["values"]) {
    //         if (i["name"] == "salt") {
    //           salt_user = i["value"];
    //         }
    //         if (i["name"] == "token") {
    //           token_user = i["value"];
    //         }
    //         if (i["name"] == "id") {
    //           id_user = i["value"];
    //         }
    //         if (i["name"] == "name") {
    //           name_user = i["value"];
    //         }
    //         if (i["name"] == "type") {
    //           type_user = i["value"];
    //         }
    //         if (i["name"] == "username") {
    //           username_user = i["value"];
    //         }
    //         if (i["name"] == "url") {
    //           image_user = i["value"];
    //         }
    //         if (i["name"] == "enabled") {
    //           enabled = i["value"];
    //         }

    //         if (i["name"] == "subscribed") {
    //           subscribed_user = i["value"];
    //         }
    //       }

    //       if (enabled == true) {
    //         SharedPreferences prefs = await SharedPreferences.getInstance();

    //         prefs.setInt("ID_USER", id_user);
    //         prefs.setString("SALT_USER", salt_user);
    //         prefs.setString("TOKEN_USER", token_user);
    //         prefs.setString("NAME_USER", name_user);
    //         prefs.setString("TYPE_USER", type_user);
    //         prefs.setString("USERNAME_USER", username_user);
    //         prefs.setString("IMAGE_USER", image_user);
    //         prefs.setString("EMAIL_USER", email_user);
    //         prefs.setString("NEW_SUBSCRIBE_ENABLED", subscribed_user);
    //         prefs.setBool("LOGGED_USER", true);

    //         Fluttertoast.showToast(
    //           msg: "You have logged in successfully !",
    //           gravity: ToastGravity.BOTTOM,
    //           backgroundColor: Colors.green,
    //           textColor: Colors.white,
    //         );
    //         _visibile_error = false;

    //         Navigator.pop(context);
    //       } else {
    //         _message_error = jsonData["message"];
    //         _visibile_error = true;
    //         Fluttertoast.showToast(
    //           msg: "Operation has been cancelled !",
    //           gravity: ToastGravity.BOTTOM,
    //           backgroundColor: Colors.red,
    //           textColor: Colors.white,
    //         );
    //       }
    //     } else {
    //       _message_error = jsonData["message"];
    //       _visibile_error = true;
    //       Fluttertoast.showToast(
    //         msg: "Operation has been cancelled !",
    //         gravity: ToastGravity.BOTTOM,
    //         backgroundColor: Colors.red,
    //         textColor: Colors.white,
    //       );
    //     }
    //   }
    // } else {
    //   _message_error = "Operation has been cancelled !";
    //   _visibile_error = true;
    //   Fluttertoast.showToast(
    //     msg: "Operation has been cancelled !",
    //     gravity: ToastGravity.BOTTOM,
    //     backgroundColor: Colors.red,
    //     textColor: Colors.white,
    //   );
    // }

    // setState(() {
    //   loading = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: main_focus_node,
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent &&
              event.data is RawKeyEventDataAndroid) {
            RawKeyDownEvent rawKeyDownEvent = event;
            RawKeyEventDataAndroid rawKeyEventDataAndroid =
                rawKeyDownEvent.data as RawKeyEventDataAndroid;
            print("Focus Node 0 ${rawKeyEventDataAndroid.keyCode}");
            switch (rawKeyEventDataAndroid.keyCode) {
              case KEY_CENTER:
                if (!loading) _goToValidate();
                break;
              case KEY_UP:
                if (pos_y == 0) {
                  print("play sound");
                } else {
                  pos_y--;
                }
                if (pos_y == 0) {
                  FocusScope.of(context).requestFocus(null);
                  FocusScope.of(context).requestFocus(username_focus_node);
                }
                break;
              case KEY_DOWN:
                if (pos_y == 2) {
                  print("play sound");
                } else {
                  pos_y++;
                }
                break;
              case KEY_LEFT:
                print("play sound");

                break;
              case KEY_RIGHT:
                print("play sound");
                break;
              default:
                break;
            }
            setState(() {});
          }
        },
        child: Stack(
          children: [
            FadeInImage(
                placeholder: MemoryImage(kTransparentImage),
                image: const AssetImage("assets/images/background.jpeg"),
                fit: BoxFit.cover),
            ClipRRect(
              // Clip it cleanly.
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                  alignment: Alignment.center,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: -5,
              top: -5,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.blueGrey,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black,
                        offset: Offset(0, 0),
                        blurRadius: 5),
                  ],
                ),
                width: MediaQuery.of(context).size.width / 2.5,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(50),
                  color: Colors.black54,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Image.asset("assets/logo.png", height: 40)),
                      const SizedBox(height: 40),
                      const Text(
                        "Sign in to your account !",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                          controller: usernameController,
                          focusNode: username_focus_node,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            focusColor: Colors.white,
                            labelText: 'E-mail',
                            labelStyle: TextStyle(
                                color:
                                    (emailvalide) ? Colors.white : Colors.red),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(
                                    color: (emailvalide)
                                        ? Colors.white
                                        : Colors.red,
                                    width: 1)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(
                                    color: (emailvalide)
                                        ? Colors.white54
                                        : Colors.red,
                                    width: 1)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(
                                    color: (emailvalide)
                                        ? Colors.white
                                        : Colors.red,
                                    width: 1)),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 15.0),
                            suffixIcon: Icon(
                              Icons.email,
                              size: 15,
                              color:
                                  (emailvalide) ? Colors.white70 : Colors.red,
                            ),
                          ),
                          style: TextStyle(
                            color: (emailvalide) ? Colors.white : Colors.red,
                          ),
                          maxLines: 1,
                          minLines: 1,
                          scrollPadding: EdgeInsets.zero,
                          cursorColor: Colors.white,
                          onFieldSubmitted: (v) {
                            if (checkEmail(usernameController.text)) {
                              emailvalide = true;
                            } else {
                              emailvalide = false;
                            }

                            setState(() {});
                            FocusScope.of(context)
                                .requestFocus(password_focus_node);
                          }),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: passwordController,
                        focusNode: password_focus_node,
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          focusColor: Colors.white,
                          labelText: 'Password',
                          labelStyle: TextStyle(
                              color:
                                  (passwordvalide) ? Colors.white : Colors.red),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(
                                  color: (passwordvalide)
                                      ? Colors.white
                                      : Colors.red,
                                  width: 1)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(
                                  color: (passwordvalide)
                                      ? Colors.white54
                                      : Colors.red,
                                  width: 1)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(
                                  color: (passwordvalide)
                                      ? Colors.white
                                      : Colors.red,
                                  width: 1)),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 15.0),
                          suffixIcon: Icon(
                            Icons.vpn_key_rounded,
                            size: 15,
                            color:
                                (passwordvalide) ? Colors.white70 : Colors.red,
                          ),
                        ),
                        style: TextStyle(
                          color: (passwordvalide) ? Colors.white70 : Colors.red,
                        ),
                        maxLines: 1,
                        minLines: 1,
                        scrollPadding: EdgeInsets.zero,
                        cursorColor: Colors.white,
                        onFieldSubmitted: (v) {
                          if (passwordController.text.length >= 6) {
                            passwordvalide = true;
                          } else {
                            passwordvalide = false;
                          }
                          setState(() {});
                          FocusScope.of(context).requestFocus(main_focus_node);
                          pos_y = 1;
                          setState(() {});
                        },
                      ),
                      if (_visibile_error)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 0.3),
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.redAccent,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5.0),
                                height: 28,
                                width: 28,
                                child: const Icon(
                                  Icons.warning,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(_message_error,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      )),
                                ),
                              ),
                            ],
                          ),
                        ),
                      GestureDetector(
                        onTap: () {
                          pos_y = 1;
                          setState(() {});
                          _goToValidate();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 15),
                          height: 45,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: (pos_y == 1)
                                    ? Colors.white
                                    : Colors.deepPurple,
                                width: 2),
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              (loading)
                                  ? Container(
                                      height: 40,
                                      width: 40,
                                      decoration: const BoxDecoration(
                                          color: Colors.white10,
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(4),
                                              topLeft: Radius.circular(4))),
                                      child: const Center(
                                        child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            )),
                                      ))
                                  : Container(
                                      height: 40,
                                      width: 40,
                                      decoration: const BoxDecoration(
                                          color: Colors.white10,
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(4),
                                              topLeft: Radius.circular(4))),
                                      child: const Icon(FontAwesomeIcons.envelope,
                                          color: Colors.white)),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    (loading)
                                        ? "Operation in progress ..."
                                        : "Sign in to your account !",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Container(
                          //   margin: EdgeInsets.only(top: 10),
                          //   padding: EdgeInsets.symmetric(vertical: 5),
                          //   child: Text(
                          //     "Other ways to sign in",
                          //     style: TextStyle(
                          //         fontSize: 12,
                          //         fontWeight: FontWeight.bold,
                          //         color: (pos_y == 2)
                          //             ? Colors.white
                          //             : Colors.white60),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
                right: 0,
                bottom: -5,
                top: 285,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 2.5,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(50),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            pos_y = 2;
                            setState(() {});
                            print("google");
                            handleGoogleSignin();
                            // _goToValidate();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 15),
                            height: 45,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      (pos_y == 2) ? Colors.white : Colors.red,
                                  width: 2),
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                (loading)
                                    ? Container(
                                        height: 40,
                                        width: 40,
                                        decoration: const BoxDecoration(
                                            color: Colors.white10,
                                            borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(4),
                                                topLeft: Radius.circular(4))),
                                        child: const Center(
                                          child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              )),
                                        ))
                                    : Container(
                                        height: 40,
                                        width: 40,
                                        decoration: const BoxDecoration(
                                            color: Colors.white10,
                                            borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(4),
                                                topLeft: Radius.circular(4))),
                                        child: const Icon(FontAwesomeIcons.google,
                                            color: Colors.white)),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      (loading)
                                          ? "Operation in progress ..."
                                          : "Sign in with Google",
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  void _goToValidate() {
    if (pos_y == 1) {
      if (checkEmail(usernameController.text)) {
        emailvalide = true;
      } else {
        emailvalide = false;
      }
      if (passwordController.text.length >= 6) {
        passwordvalide = true;
      } else {
        passwordvalide = false;
      }
      print("ok");
      setState(() {});

      if (passwordvalide && emailvalide) {
        _login(usernameController.text.toString(),
            passwordController.text.toString());
      }
    }
  }

  bool checkEmail(String email) {
    if (email.length < 6) return false;
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
    return emailValid;
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
      nextScreenReplace(context, const tvHomeScreen());
    });
  }
}
