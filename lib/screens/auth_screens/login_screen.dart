import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/provider/recently_watched_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/auth_screens/forgot_password.dart';
import 'package:reelriot/utils/app_images.dart';
import 'package:reelriot/utils/globlal_methods.dart';
import 'package:reelriot/utils/routes/app_pages.dart';
import 'package:reelriot/utils/theme/textStyle.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/screens/home_screen/dash_screen.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color _bgColor = Color(0xFF030712);
  static const Color _surfaceColor = Color(0xFF0B0F14);
  static const Color _surfaceBorder = Color(0x14FFFFFF);
  static const Color _primaryColor = Color(0xFFDC2626);
  static const Color _secondaryColor = Color(0xFF7C3AED);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xB8FFFFFF);

  final FocusNode passwordFocusNode = FocusNode();
  bool obscureText = true;
  String emailAddress = '';
  String password = '';
  final formKey = GlobalKey<FormState>();
  final _auth = Supabase.instance.client.auth;
  GlobalMethods globalMethods = GlobalMethods();
  bool isLoading = false;

  @override
  void dispose() {
    passwordFocusNode.dispose();
    super.dispose();
  }

  void submitForm() async {
    final isValid = formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    final value = await checkConnection();
    if (!mounted) return;

    if (!value) {
      GlobalMethods.showCustomScaffoldMessage(
        SnackBar(
          content: Text(
            tr("check_connection"),
            maxLines: 3,
            style: kTextSmallBodyStyle,
          ),
          duration: const Duration(seconds: 3),
        ),
        context,
      );
      return;
    }

    if (!isValid) return;

    setState(() {
      isLoading = true;
    });
    formKey.currentState!.save();
    try {
      await _auth.signInWithPassword(
        email: emailAddress.toLowerCase().trim(),
        password: password.trim(),
      );
      if (!mounted) return;

      await Provider.of<RecentProvider>(context, listen: false).syncFromCloud();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CaffieneHomePage()),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      if (error.message.contains('Invalid login credentials') ||
          error.message.contains('wrong-password')) {
        globalMethods.authErrorHandle(tr("invalid_credential"), context);
      } else if (error.message.contains('invalid') ||
          error.message.contains('email')) {
        globalMethods.authErrorHandle(tr("invalid_email"), context);
      } else if (error.message.contains('disabled') ||
          error.message.contains('banned')) {
        globalMethods.authErrorHandle(tr("banned_user"), context);
      } else if (error.message.contains('not found') ||
          error.message.contains('user-not-found')) {
        globalMethods.authErrorHandle(tr("user_not_found"), context);
      } else {
        globalMethods.authErrorHandle(error.message, context);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _textSecondary),
      prefixIcon: Icon(icon, color: _textSecondary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _surfaceBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _primaryColor, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _primaryColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _primaryColor, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            top: 110,
            left: -50,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _primaryColor.withValues(alpha: 0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: Get.height - 64,
                    maxWidth: 480,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          foregroundColor: _textPrimary,
                        ),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Hero(
                          tag: 'logo_shadow',
                          child: Container(
                            width: 112,
                            height: 112,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.asset(MovixIcon.appLogo, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Sign in to continue your cinematic streaming experience.',
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
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
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr("login"),
                                style: const TextStyle(
                                  color: _textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Use your email and password to access your watchlist, bookmarks, and synced history.',
                                style: TextStyle(
                                  color: _textSecondary,
                                  fontSize: 13,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                key: const ValueKey('email'),
                                validator: (value) {
                                  if (value!.isEmpty || !value.contains('@')) {
                                    return tr("invalid_email");
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.next,
                                onEditingComplete: () => FocusScope.of(context)
                                    .requestFocus(passwordFocusNode),
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: _textPrimary),
                                decoration: _inputDecoration(
                                  label: tr("email_address"),
                                  icon: Icons.email_outlined,
                                ),
                                onSaved: (value) {
                                  emailAddress = value!;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                key: const ValueKey('Password'),
                                validator: (value) {
                                  if (value!.isEmpty || value.length < 7) {
                                    return tr("weak_password");
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.visiblePassword,
                                focusNode: passwordFocusNode,
                                style: const TextStyle(color: _textPrimary),
                                decoration: _inputDecoration(
                                  label: tr("password"),
                                  icon: Icons.lock_outline_rounded,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        obscureText = !obscureText;
                                      });
                                    },
                                    icon: Icon(
                                      obscureText
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: _textSecondary,
                                    ),
                                  ),
                                ),
                                onSaved: (value) {
                                  password = value!;
                                },
                                obscureText: obscureText,
                              ),
                              const SizedBox(height: 22),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : submitForm,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(56),
                                    backgroundColor: _primaryColor,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        _primaryColor.withValues(alpha: 0.6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          tr("login"),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(52),
                                    side:
                                        const BorderSide(color: _surfaceBorder),
                                    foregroundColor: _textPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.03),
                                  ),
                                  child: Text(tr("forgot_password")),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: 24),
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(
                                color: _textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.toNamed(Routes.signup);
                              },
                              child: const Text(
                                'Sign up',
                                style: TextStyle(
                                  color: _primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }
}
