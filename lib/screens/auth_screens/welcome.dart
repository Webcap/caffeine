import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/utils/globals.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/provider/sign_in_provider.dart';
import 'package:reelriot/screens/auth_screens/login_screen.dart';
import 'package:reelriot/utils/app_images.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/utils/helpers/next_screen.dart';
import 'package:reelriot/utils/routes/app_pages.dart';
import 'package:reelriot/utils/helpers/snackbar.dart';
import 'package:reelriot/utils/theme/textStyle.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  static const Color _bgColor = Color(0xFF030712);
  static const Color _surfaceColor = Color(0xFF0B0F14);
  static const Color _surfaceBorder = Color(0x14FFFFFF);
  static const Color _primaryColor = Color(0xFFDC2626);
  static const Color _secondaryColor = Color(0xFF7C3AED);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xB8FFFFFF);

  bool anonButtonVisible = true;
  bool googleButtonVisable = true;

  Widget _buildSurfaceButton({
    required Widget child,
    required VoidCallback? onTap,
    Color? backgroundColor,
    Color? borderColor,
    List<BoxShadow>? boxShadow,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 56,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: backgroundColor ?? Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: borderColor ?? _surfaceBorder),
          boxShadow: boxShadow,
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;
    final appDependencyProvider = context.watch<AppDependencyProvider>();
    Provider.of<SettingsProvider>(context).appTheme;
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _bgColor,
                    _surfaceColor.withValues(alpha: 0.95),
                    _bgColor,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -80,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _secondaryColor.withValues(alpha: 0.34),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _primaryColor.withValues(alpha: 0.26),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: Get.height - 60),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white.withValues(alpha: 0.05),
                            border: Border.all(color: _surfaceBorder),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 32,
                                color: Color(0x52220000),
                                offset: Offset(0, 16),
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(MovixIcon.appLogo),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Center(
                        child: Text(
                          "Let's Get Started",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _textPrimary,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            height: 1.05,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Stream, discover, bookmark, and sync your movie universe with a premium cinematic experience.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _textSecondary,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: _surfaceBorder),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 28,
                              color: Color(0x52000000),
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            if (appDependencyProvider.enableGoogleSignIn) ...[
                              googleButtonVisable
                                  ? _buildSurfaceButton(
                                      onTap: () async {
                                        setState(() {
                                          googleButtonVisable = false;
                                        });
                                        handleGoogleSignin();
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            MovixIcon.google,
                                            width: 18,
                                            height: 18,
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Continue with Google',
                                            style: TextStyle(
                                              color: _textPrimary,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 14),
                                      child: CircularProgressIndicator(),
                                    ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color:
                                          Colors.white.withValues(alpha: 0.12),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text(
                                      'or',
                                      style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.64),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color:
                                          Colors.white.withValues(alpha: 0.12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                            ],
                            _buildSurfaceButton(
                              onTap: () {
                                nextScreen(context, const LoginScreen());
                              },
                              backgroundColor: _primaryColor,
                              borderColor: _primaryColor,
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x52DC2626),
                                  blurRadius: 24,
                                  offset: Offset(0, 10),
                                ),
                              ],
                              child: const Text(
                                'Continue with Email',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            if (appDependencyProvider.enableAnonymousSignIn)
                              anonButtonVisible
                                  ? _buildSurfaceButton(
                                      onTap: () async {
                                        setState(() {
                                          anonButtonVisible = false;
                                        });
                                        final value = await checkConnection();
                                        if (!mounted) return;
                                        if (value) {
                                          await auth.signInAnonymously();
                                          if (!mounted) return;
                                          setState(() {
                                            anonButtonVisible = true;
                                          });
                                          Get.offAllNamed(Routes.dash);
                                        } else {
                                          if (!context.mounted) return;
                                          setState(() {
                                            anonButtonVisible = true;
                                          });
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                tr("check_connection"),
                                                maxLines: 3,
                                                style: kTextSmallBodyStyle,
                                              ),
                                              duration:
                                                  const Duration(seconds: 3),
                                            ),
                                          );
                                        }
                                      },
                                      backgroundColor:
                                          Colors.white.withValues(alpha: 0.03),
                                      child: Text(
                                        tr("continue_anonymously"),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: _textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  : const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 14),
                                      child: CircularProgressIndicator(),
                                    ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Get.toNamed(Routes.signup);
                          },
                          child: const Text(
                            'Create a new account',
                            style: TextStyle(
                              color: _primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future handleGoogleSignin() async {
    final sp = context.read<SignInProvider>();
    await sp.signInWithGoogle();
    if (!mounted) return;
    if (sp.hasError) {
      openSnackbar(context, sp.errorCode ?? 'Error', Colors.red);
      setState(() {
        googleButtonVisable = true;
      });
    } else {
      final exists = await sp.checkuserExists();
      if (!mounted) return;
      if (!exists) {
        // New user — create their profile row.
        await sp.saveDatatoFirestore();
      }
      // In both cases, fetch fresh profile data (username, firstRun, etc.)
      await sp.getUserDataFromFirestore(sp.uid);
      if (!mounted) return;
      openSnackbar(
        context,
        "Alright, You're Good Buddy.",
        Colors.green,
      );
      handleAfterSignIn();
    }
  }

  void handleAfterSignIn() {
    final sp = context.read<SignInProvider>();

    Future.delayed(const Duration(milliseconds: 1000)).then((value) async {
      if (sp.firstRun == false && sp.provider == "google") {
        final supabase = Supabase.instance.client;
        final uid = sp.uid;
        if (uid != null) {
          await supabase.from('bookmarks').upsert({
            'user_id': uid,
            'movies': [],
            'tv_shows': [],
          });

          final username = await sp.createRandomUsername();
          await sp.insertUsername(username, uid);
          await supabase.from('profiles').update({
            'username': username,
            'first_run': true,
          }).eq('id', uid);

          sharedPrefsSingleton.setString('username', username);
        }
      }
      if (!mounted) return;
      Get.offAllNamed(Routes.dash);
    });
  }
}
