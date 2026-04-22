import 'dart:convert';

import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/utils/routes/app_pages.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void _pairTvLog(String message, [Object? detail]) {
  if (kDebugMode) {
    debugPrint('[PairTV] $message${detail != null ? ': $detail' : ''}');
  }
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
            headers: {'Content-Type': 'application/json'},
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
    if (!_isSignedIn) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B0F14),
        appBar: AppBar(
          title:
              Text(tr("pair_tv"), style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.tv_rounded, size: 64, color: Colors.white54),
                const SizedBox(height: 24),
                Text(
                  tr("pair_tv_sign_in_required"),
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Get.offAllNamed(Routes.login),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: Text(tr("pair_tv_go_sign_in")),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        title: Text(tr("pair_tv"), style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              tr("pair_tv_instructions"),
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              maxLength: 8,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                letterSpacing: 6,
              ),
              decoration: InputDecoration(
                hintText: 'ABC12XYZ',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                counterText: '',
                filled: true,
                fillColor: const Color(0xFF1a1a2e),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color:
                        _success ? Colors.green.shade300 : Colors.red.shade300,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
              onPressed: _loading ? null : _linkTv,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                  _loading ? tr("pair_tv_linking") : tr("pair_tv_link_button")),
            ),
          ],
        ),
      ),
    );
  }
}
