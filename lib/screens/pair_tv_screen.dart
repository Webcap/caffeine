import 'dart:convert';

import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/utils/routes/app_pages.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reelriot/utils/constant.dart';

void _pairTvLog(String message, [Object? detail]) {
  if (kDebugMode) {
    debugPrint('[PairTV] $message${detail != null ? ': $detail' : ''}');
  }
}

// ── Design tokens (design.json) ─────────────────────────────────────────────
class _Design {
  static const primary = Color(0xFFDC2626);

  static const bgCanvasDark = Color(0xFF030712);
  static const bgCanvasLight = Color(0xFFF8FAFC);
  static const bgSurfaceDark = Color(0xFF0B0F14);
  static const bgSurfaceLight = Color(0xFFFFFFFF);
  static const bgCardDark = Color(0xFF111827);
  static const bgCardLight = Color(0xFFF1F5F9);

  static const borderDark = Color(0x14FFFFFF);
  static const borderLight = Color(0x140F172A);

  static const textPrimDark = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
  static const textSecDark = Color(0xB8FFFFFF);
  static const textSecLight = Color(0xFF64748B);

  static const radiusLg = 20.0;
  static const radiusMd = 16.0;
  static const radiusSm = 12.0;
  static const screenPadH = 20.0;
  static const ctaHeight = 52.0;
  static const shadowCard = BoxShadow(
    color: Color(0x38000000),
    blurRadius: 30,
    offset: Offset(0, 10),
  );
}

/// Pair Caffeine TV: only for signed-in (non-anonymous) users.
/// User enters the code shown on the TV; app sends current session to API.
class PairTvScreen extends StatefulWidget {
  const PairTvScreen({super.key});

  @override
  State<PairTvScreen> createState() => _PairTvScreenState();
}

class _PairTvScreenState extends State<PairTvScreen> {
  final _auth = Supabase.instance.client.auth;
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _message;
  bool _success = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  bool get _isSignedIn {
    final user = _auth.currentUser;
    return user != null && !user.isAnonymous;
  }

  Future<void> _linkTv() async {
    final code = _codeController.text.trim().toUpperCase();
    _pairTvLog('Link TV tapped', 'code length=${code.length}');
    if (code.length < 6) {
      setState(() {
        _message = tr("pair_tv_enter_code");
        _success = false;
      });
      return;
    }
    final session = _auth.currentSession;
    if (session == null) {
      _pairTvLog('No session', 'user not signed in');
      setState(() {
        _message = tr("pair_tv_sign_in_first");
        _success = false;
      });
      return;
    }
    setState(() {
      _message = null;
      _loading = true;
    });
    try {
      final appDep = Provider.of<AppDependencyProvider>(context, listen: false);
      final base = (appDep.caffeineAPIURL).replaceFirst(RegExp(r'/$'), '');
      final url = '$base/tv/pair/confirm';
      _pairTvLog('POST', url);
      final body = jsonEncode({
        'code': code,
        'access_token': session.accessToken,
        'refresh_token': session.refreshToken ?? '',
      });
      _pairTvLog('Request body length', body.length);
      final res = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              ...caffeineApiHeaders,
            },
            body: body,
          )
          .timeout(const Duration(seconds: 15));
      _pairTvLog(
          'Response', 'status=${res.statusCode} bodyLength=${res.body.length}');
      if (res.body.isNotEmpty) {
        final preview =
            res.body.length > 300 ? '${res.body.substring(0, 300)}…' : res.body;
        _pairTvLog('Response body', preview);
      }
      Map<String, dynamic>? data;
      try {
        if (res.body.isNotEmpty) {
          data = jsonDecode(res.body) as Map<String, dynamic>?;
        }
      } catch (e) {
        _pairTvLog('Failed to parse response JSON', e);
      }
      if (!mounted) return;
      if (res.statusCode == 200 && data != null && data['success'] == true) {
        _pairTvLog('Success', 'TV linked');
        setState(() {
          _message = tr("pair_tv_success");
          _success = true;
          _loading = false;
          _codeController.clear();
        });
      } else {
        final err = (data?['error'] as String?)?.trim() ?? '';
        _pairTvLog('Link failed', 'status=${res.statusCode} error=$err');
        setState(() {
          _message = err.isNotEmpty ? err : tr("pair_tv_link_failed");
          _success = false;
          _loading = false;
        });
      }
    } catch (e, stack) {
      _pairTvLog('Request error', e);
      if (kDebugMode) debugPrint(stack.toString());
      if (!mounted) return;
      setState(() {
        _message = tr("pair_tv_network_error");
        _success = false;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isDark = themeMode == 'dark' || themeMode == 'amoled';
    final bg = isDark ? _Design.bgCanvasDark : _Design.bgCanvasLight;
    final surface = isDark ? _Design.bgSurfaceDark : _Design.bgSurfaceLight;
    final cardBg = isDark ? _Design.bgCardDark : _Design.bgCardLight;
    final textPrim = isDark ? _Design.textPrimDark : _Design.textPrimLight;
    final textSec = isDark ? _Design.textSecDark : _Design.textSecLight;
    final border = isDark ? _Design.borderDark : _Design.borderLight;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;

    if (!_isSignedIn) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: surface,
          centerTitle: isTablet,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrim, size: 20),
            onPressed: () => Navigator.maybePop(context),
            tooltip: tr("back"),
          ),
          title: Text(
            tr("pair_tv"),
            style: TextStyle(
              color: textPrim,
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'PoppinsSB',
            ),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : _Design.screenPadH),
              child: Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(_Design.radiusLg),
                  border: Border.all(color: border),
                  boxShadow: const [_Design.shadowCard],
                ),
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _Design.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _Design.primary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        size: 34,
                        color: _Design.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      tr("pair_tv_sign_in_required"),
                      style: TextStyle(
                        color: textPrim,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'PoppinsSB',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to synchronize your account, bookmarks, and watch history with your TV device.',
                      style: TextStyle(
                        color: textSec,
                        fontSize: 13.5,
                        fontFamily: 'Poppins',
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      height: _Design.ctaHeight,
                      child: ElevatedButton(
                        onPressed: () => Get.toNamed(Routes.login),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _Design.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(_Design.radiusMd),
                          ),
                        ),
                        child: Text(
                          tr("pair_tv_go_sign_in"),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'PoppinsSB',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surface,
        centerTitle: isTablet,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrim, size: 20),
          onPressed: () => Navigator.maybePop(context),
          tooltip: tr("back"),
        ),
        title: Text(
          tr("pair_tv"),
          style: TextStyle(
            color: textPrim,
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'PoppinsSB',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32 : _Design.screenPadH,
            vertical: isTablet ? 28 : 20,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Hero Header Card
                  Container(
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(_Design.radiusLg),
                      border: Border.all(color: border),
                      boxShadow: const [_Design.shadowCard],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: _Design.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _Design.primary.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.tv_rounded,
                            size: 34,
                            color: _Design.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Link ReelRiot TV',
                          style: TextStyle(
                            color: textPrim,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'PoppinsSB',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          tr("pair_tv_instructions"),
                          style: TextStyle(
                            color: textSec,
                            fontSize: 13.5,
                            fontFamily: 'Poppins',
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Code Input Card
                  Container(
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(_Design.radiusLg),
                      border: Border.all(color: border),
                      boxShadow: const [_Design.shadowCard],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'ENTER TV PAIRING CODE',
                          style: TextStyle(
                            color: textSec,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            fontFamily: 'PoppinsSB',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _codeController,
                          maxLength: 8,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                            UpperCaseTextFormatter(),
                          ],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textPrim,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 8,
                            fontFamily: 'PoppinsSB',
                          ),
                          decoration: InputDecoration(
                            hintText: 'ABC123',
                            hintStyle: TextStyle(
                              color: textSec.withValues(alpha: 0.35),
                              letterSpacing: 6,
                            ),
                            counterText: '',
                            filled: true,
                            fillColor: cardBg,
                            contentPadding: const EdgeInsets.symmetric(vertical: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(_Design.radiusMd),
                              borderSide: BorderSide(color: border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(_Design.radiusMd),
                              borderSide: BorderSide(color: border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(_Design.radiusMd),
                              borderSide: const BorderSide(
                                color: _Design.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        if (_message != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: (_success ? Colors.green : Colors.red)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: (_success ? Colors.green : Colors.red)
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _success
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.error_outline_rounded,
                                  color: _success
                                      ? Colors.green.shade400
                                      : Colors.red.shade400,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _message!,
                                    style: TextStyle(
                                      color: _success
                                          ? Colors.green.shade400
                                          : Colors.red.shade400,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'PoppinsSB',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          height: _Design.ctaHeight,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _linkTv,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _Design.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  _Design.primary.withValues(alpha: 0.35),
                              disabledForegroundColor:
                                  Colors.white.withValues(alpha: 0.4),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(_Design.radiusMd),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.link_rounded, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        tr("pair_tv_link_button"),
                                        style: const TextStyle(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'PoppinsSB',
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3. Step-by-Step Instructions Card
                  Container(
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(_Design.radiusLg),
                      border: Border.all(color: border),
                      boxShadow: const [_Design.shadowCard],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HOW IT WORKS',
                          style: TextStyle(
                            color: textSec,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            fontFamily: 'PoppinsSB',
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildStepRow(
                          number: '1',
                          title: 'Launch ReelRiot on TV',
                          description: 'Open the ReelRiot TV app on your television or streaming box.',
                          textPrim: textPrim,
                          textSec: textSec,
                        ),
                        const Divider(height: 20),
                        _buildStepRow(
                          number: '2',
                          title: 'Find Pairing Code',
                          description: 'Navigate to Settings > Link Account on your TV to view the 6-character code.',
                          textPrim: textPrim,
                          textSec: textSec,
                        ),
                        const Divider(height: 20),
                        _buildStepRow(
                          number: '3',
                          title: 'Enter Code & Confirm',
                          description: 'Type the code above and tap Link TV Device to instantly sync your account.',
                          textPrim: textPrim,
                          textSec: textSec,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow({
    required String number,
    required String title,
    required String description,
    required Color textPrim,
    required Color textSec,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _Design.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: _Design.primary.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: _Design.primary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'PoppinsSB',
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textPrim,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'PoppinsSB',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: textSec,
                  fontSize: 12.5,
                  fontFamily: 'Poppins',
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
