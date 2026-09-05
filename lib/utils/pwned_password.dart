import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Result structure for HaveIBeenPwned password breach check.
class PwnedCheckResult {
  final bool isPwned;
  final int breachCount;

  const PwnedCheckResult({
    required this.isPwned,
    required this.breachCount,
  });
}

const String _configRowId = '00000000-0000-0000-0000-000000000001';
bool? _cachedBreachDetectorEnabled;
DateTime? _lastBreachDetectorCheck;
const Duration _cacheDuration = Duration(seconds: 30);

/// Checks whether password breach detection is enabled in global app_config.
/// Defaults to true if configuration cannot be fetched or is not set.
Future<bool> isBreachDetectorEnabled() async {
  final now = DateTime.now();
  if (_cachedBreachDetectorEnabled != null &&
      _lastBreachDetectorCheck != null &&
      now.difference(_lastBreachDetectorCheck!) < _cacheDuration) {
    return _cachedBreachDetectorEnabled!;
  }

  try {
    final client = Supabase.instance.client;
    final response = await client
        .from('app_config')
        .select('config')
        .eq('id', _configRowId)
        .maybeSingle()
        .timeout(const Duration(seconds: 3));

    if (response != null && response['config'] is Map) {
      final cfg = response['config'] as Map;
      final val = cfg['enable_breach_detector'];
      if (val != null) {
        _cachedBreachDetectorEnabled =
            val == true || val.toString().toLowerCase() == 'true';
        _lastBreachDetectorCheck = now;
        return _cachedBreachDetectorEnabled!;
      }
    }
  } catch (e) {
    debugPrint('[HIBP] Error fetching breach detector config: $e');
  }

  _cachedBreachDetectorEnabled ??= true;
  return _cachedBreachDetectorEnabled!;
}

/// Verifies if a password has been compromised in known public data breaches
/// using the HaveIBeenPwned k-Anonymity mathematical model.
///
/// The plaintext password is NEVER transmitted across the network; only the
/// first 5 characters of its SHA-1 hash (the prefix) are queried against the
/// Pwned Passwords API.
/// If disabled by the administrator in the config page, checks are bypassed immediately.
Future<PwnedCheckResult> checkPwnedPassword(String password) async {
  if (password.isEmpty) {
    return const PwnedCheckResult(isPwned: false, breachCount: 0);
  }

  try {
    final enabled = await isBreachDetectorEnabled();
    if (!enabled) {
      return const PwnedCheckResult(isPwned: false, breachCount: 0);
    }
    final bytes = utf8.encode(password);
    final digest = sha1.convert(bytes);
    final fullHash = digest.toString().toUpperCase();

    final prefix = fullHash.substring(0, 5);
    final suffix = fullHash.substring(5);

    final response = await http
        .get(
          Uri.parse('https://api.pwnedpasswords.com/range/$prefix'),
          headers: {'Add-Padding': 'true'},
        )
        .timeout(const Duration(seconds: 4));

    if (response.statusCode != 200) {
      debugPrint('[HIBP] Service returned status ${response.statusCode}, failing open.');
      return const PwnedCheckResult(isPwned: false, breachCount: 0);
    }

    final lines = response.body.split('\n');
    for (final line in lines) {
      final parts = line.trim().split(':');
      if (parts.length >= 2) {
        final hashSuffix = parts[0].toUpperCase();
        final count = int.tryParse(parts[1]) ?? 0;

        if (hashSuffix == suffix && count > 0) {
          return PwnedCheckResult(isPwned: true, breachCount: count);
        }
      }
    }

    return const PwnedCheckResult(isPwned: false, breachCount: 0);
  } catch (e) {
    debugPrint('[HIBP] Breach check failed or timed out (failing open): $e');
    return const PwnedCheckResult(isPwned: false, breachCount: 0);
  }
}
