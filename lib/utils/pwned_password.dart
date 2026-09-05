import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Result structure for HaveIBeenPwned password breach check.
class PwnedCheckResult {
  final bool isPwned;
  final int breachCount;

  const PwnedCheckResult({
    required this.isPwned,
    required this.breachCount,
  });
}

/// Verifies if a password has been compromised in known public data breaches
/// using the HaveIBeenPwned k-Anonymity mathematical model.
///
/// The plaintext password is NEVER transmitted across the network; only the
/// first 5 characters of its SHA-1 hash (the prefix) are queried against the
/// Pwned Passwords API.
Future<PwnedCheckResult> checkPwnedPassword(String password) async {
  if (password.isEmpty) {
    return const PwnedCheckResult(isPwned: false, breachCount: 0);
  }

  try {
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
