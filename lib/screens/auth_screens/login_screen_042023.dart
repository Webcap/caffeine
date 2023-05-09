import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:caffiene/provider/internet_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/provider/sign_in_provider.dart';
import 'package:caffiene/screens/auth_screens/forgot_password.dart';
import 'package:caffiene/screens/home_screen/dash_screen.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/utils/globlal_methods.dart';
import 'package:caffiene/utils/next_screen.dart';
import 'package:caffiene/utils/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class LoginPage423 extends StatefulWidget {
  const LoginPage423({Key? key}) : super(key: key);

  @override
  State<LoginPage423> createState() => _LoginPage423State();
}

class _LoginPage423State extends State<LoginPage423> {
  final FocusNode passwordFocusNode = FocusNode();
  bool obscureText = true;
  String emailAddress = "";
  String password = "";
  final formKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  GlobalMethods globalMethods = GlobalMethods();
  bool isLoading = false;
  final RoundedLoadingButtonController googleController =
      RoundedLoadingButtonController();

  void submitForm() async {
    final isValid = formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid && mounted) {
      setState(() {
        isLoading = true;
      });
      formKey.currentState!.save();
      try {
        await auth
            .signInWithEmailAndPassword(
                email: emailAddress.toLowerCase().trim(),
                password: password.trim())
            .then((value) => Navigator.canPop(context)
                ? Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: ((context) {
                    final mixpanel =
                        Provider.of<SettingsProvider>(context).mixpanel;
                    mixpanel.track(
                      'Users Login',
                    );
                    return const caffieneHomePage();
                  })))
                : null);
      } on FirebaseAuthException catch (error) {
        if (error.code == 'wrong-password') {
          globalMethods.authErrorHandle(
              'The password entered is wrong, Or the account doesn\'t exist',
              context);
        } else if (error.code == 'invalid-email') {
          globalMethods.authErrorHandle(
              'The email address entered is invalid.', context);
        } else if (error.code == 'user-disabled') {
          globalMethods.authErrorHandle(
              'This user account is banned.', context);
        } else if (error.code == 'user-not-found') {
          globalMethods.authErrorHandle(
              'There is no user found for this email, maybe create an account?',
              context);
        }
        // print('error occured $error}');
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;

    return Scaffold(
      backgroundColor: const Color(0xFFdedede),
      appBar: AppBar(title: const Text('Login')),
      body: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                      tag: 'logo_shadow',
                      child: SizedBox(
                          height: 150,
                          width: 150,
                          child: Image.asset(appConfig.app_icon))),
                  SingleChildScrollView(
                    child: Center(
                      child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: TextFormField(
                                  key: const ValueKey('email'),
                                  validator: (value) {
                                    if (value!.isEmpty ||
                                        !value.contains('@')) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                  textInputAction: TextInputAction.next,
                                  onEditingComplete: () =>
                                      FocusScope.of(context)
                                          .requestFocus(passwordFocusNode),
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      border: const UnderlineInputBorder(),
                                      filled: true,
                                      prefixIcon: const Icon(Icons.email),
                                      labelText: 'Email Address',
                                      fillColor: Theme.of(context)
                                          .colorScheme
                                          .background),
                                  onSaved: (value) {
                                    emailAddress = value!;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: TextFormField(
                                  key: const ValueKey('Password'),
                                  validator: (value) {
                                    if (value!.isEmpty || value.length < 7) {
                                      return 'Please enter a valid Password';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.visiblePassword,
                                  focusNode: passwordFocusNode,
                                  decoration: InputDecoration(
                                      border: const UnderlineInputBorder(),
                                      filled: true,
                                      prefixIcon: const Icon(Icons.lock),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            obscureText = !obscureText;
                                          });
                                        },
                                        child: Icon(obscureText
                                            ? Icons.visibility
                                            : Icons.visibility_off),
                                      ),
                                      labelText: 'Password',
                                      fillColor: Theme.of(context)
                                          .colorScheme
                                          .background),
                                  onSaved: (value) {
                                    password = value!;
                                  },
                                  obscureText: obscureText,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  isLoading
                                      ? const CircularProgressIndicator()
                                      : ElevatedButton(
                                          style: ButtonStyle(
                                              minimumSize:
                                                  MaterialStateProperty.all(
                                                      const Size(150, 50)),
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                              )),
                                          onPressed: submitForm,
                                          child: const Text(
                                            'Login',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 17),
                                          )),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextButton(
                                  style: const ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          Colors.transparent)),
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: ((context) {
                                      return const ForgotPasswordScreen();
                                    })));
                                  },
                                  child: const Text(
                                    'Forgot password?',
                                  )),
                              const SizedBox(
                                height: 20,
                              ),
                              RoundedLoadingButton(
                                  controller: googleController,
                                  onPressed: () {
                                    handleGoogleSignin();
                                  },
                                  successColor: Colors.red,
                                  width:
                                      MediaQuery.of(context).size.width * 0.80,
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
                            ],
                          )),
                    ),
                  ),
                ],
              ),
            ),
          )),
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
      nextScreenReplace(context, caffieneHomePage());
    });
  }
}
