import 'dart:async';

import 'package:reelriot/utils/app_images.dart';
import 'package:reelriot/utils/helpers/injection.dart';
import 'package:reelriot/utils/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  /// Override in tests to drive routing without a real Supabase connection.
  final Stream<AuthState>? authStream;

  const SplashScreen({super.key, this.authStream});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Color _bgColor = Color(0xFF030712);
  static const Color _surfaceColor = Color(0xFF0B0F14);
  static const Color _surfaceBorder = Color(0x14FFFFFF);
  static const Color _primaryColor = Color(0xFFDC2626);
  static const Color _secondaryColor = Color(0xFF7C3AED);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xB8FFFFFF);

  // Maximum time to wait for Supabase to emit an auth event.
  static const _kAuthTimeout = Duration(seconds: 6);

  StreamSubscription<AuthState>? _authSub;
  Timer? _fallbackTimer;
  bool _navigated = false;

  Stream<AuthState> get _effectiveStream =>
      widget.authStream ?? Supabase.instance.client.auth.onAuthStateChange;

  @override
  void initState() {
    super.initState();
    // In production, we initialize global dependencies here if they aren't already.
    // In tests, we inject the stream and handle dependencies separately.
    if (widget.authStream == null) {
      DependencyInjection.init();
    }
    _waitForAuthThenRoute();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _fallbackTimer?.cancel();
    super.dispose();
  }

  void _waitForAuthThenRoute() {
    // Check for an in-memory session first (fast path).
    // This is critical for avoiding a flash of the login screen.
    final currentSession = Supabase.instance.client.auth.currentSession;
    if (currentSession != null) {
      debugPrint('[Splash] ⚡ Immediate session found, routing to dash');
      _navigate(authenticated: true);
      return;
    }

    // Start a fallback timer so we never hang forever.
    _fallbackTimer = Timer(_kAuthTimeout, () {
      debugPrint('[Splash] ⏱ Auth timeout — checking current session one last time');
      final finalCheck = Supabase.instance.client.auth.currentSession;
      _navigate(authenticated: finalCheck != null);
    });

    _authSub = _effectiveStream.listen(
      (data) {
        final event = data.event;
        final session = data.session;
        debugPrint('[Splash] 🔄 Auth event received: $event');
        
        // We only navigate on specific events that indicate a terminal state for the splash screen
        if (event == AuthChangeEvent.initialSession ||
            event == AuthChangeEvent.signedIn ||
            event == AuthChangeEvent.signedOut ||
            event == AuthChangeEvent.userUpdated) {
          _navigate(authenticated: session != null);
        }
      },
      onError: (e) {
        debugPrint('[Splash] ⚠️ Auth stream error: $e');
        _navigate(authenticated: Supabase.instance.client.auth.currentSession != null);
      },
    );
  }

  void _navigate({required bool authenticated}) {
    if (_navigated || !mounted) return;
    _navigated = true;

    _authSub?.cancel();
    _fallbackTimer?.cancel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final target = authenticated ? Routes.dash : Routes.login;
      debugPrint('[Splash] 🚀 Navigating from ${Get.currentRoute} to $target');
      Get.offAllNamed(target);
    });
  }

  @override
  Widget build(BuildContext context) {
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
            top: 140,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  const Spacer(),
                  SizedBox(
                    width: 132,
                    height: 132,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        MovixIcon.appLogo,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Reelriot',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Loading your cinematic streaming experience.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _textSecondary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  const SpinKitCircle(
                    color: _primaryColor,
                    size: 52,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Please wait',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.70),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
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
}
