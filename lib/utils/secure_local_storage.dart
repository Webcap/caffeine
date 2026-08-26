import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String _supabaseSecureKey = 'supabase.auth.token';

class SecureLocalStorage extends LocalStorage {
  // Use a singleton approach or constant constructor for the storage
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  SecureLocalStorage() : super();

  @override
  Future<void> initialize() async {
    // Check if we have an existing session in SharedPreferences
    // If so, migrate it to secure storage and remove from SharedPreferences.
    try {
      await _migrateLegacyToken();
    } catch (e) {
      debugPrint('[Auth] ⚠️ Error during migration or init: $e');
      // Transient KeyStore errors can happen right after OS updates or reboot.
      // Retry the migration once before concluding storage is actually corrupted.
      if (e.toString().contains('KeyStore')) {
        await Future.delayed(const Duration(milliseconds: 300));
        try {
          await _migrateLegacyToken();
        } catch (retryError) {
          debugPrint('[Auth] 🚨 KeyStore still failing after retry, clearing: $retryError');
          await _secureStorage.deleteAll();
        }
      }
    }
  }

  Future<void> _migrateLegacyToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_supabaseSecureKey)) {
      final legacyToken = prefs.getString(_supabaseSecureKey);
      if (legacyToken != null) {
        debugPrint('[Auth] 🔑 Migrating legacy token from SharedPreferences to Secure Storage');
        await _secureStorage.write(key: _supabaseSecureKey, value: legacyToken);
      }
      await prefs.remove(_supabaseSecureKey);
    }
  }

  @override
  Future<String?> accessToken() async {
    try {
      final session = await _secureStorage.read(key: _supabaseSecureKey);
      if (session != null) {
        debugPrint('[Auth] 📥 Session recovered from Secure Storage');
      }
      return session;
    } catch (e) {
      debugPrint('[Auth] ❌ Error reading from secure storage: $e');

      // On some Android devices, encryption keys can transiently fail right
      // after boot, OS updates, or power state changes. Retry once before
      // giving up — deleting on the first failure would permanently destroy
      // a perfectly valid session over a one-off glitch.
      if (e.toString().contains('KeyStore') || e.toString().contains('BadPaddingException')) {
        await Future.delayed(const Duration(milliseconds: 300));
        try {
          final session = await _secureStorage.read(key: _supabaseSecureKey);
          if (session != null) {
            debugPrint('[Auth] 📥 Session recovered from Secure Storage on retry');
          }
          return session;
        } catch (retryError) {
          debugPrint('[Auth] 🛡️ Secure storage still failing after retry, resetting: $retryError');
          await _secureStorage.delete(key: _supabaseSecureKey);
        }
      }
      return null;
    }
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    try {
      await _secureStorage.write(key: _supabaseSecureKey, value: persistSessionString);
      debugPrint('[Auth] 💾 Session successfully persisted');
    } catch (e) {
      debugPrint('[Auth] ❌ CRITICAL: Error writing to secure storage: $e');
      // Fallback: If secure storage is totally broken, we might want to log this to analytics
    }
  }

  @override
  Future<void> removePersistedSession() async {
    try {
      await _secureStorage.delete(key: _supabaseSecureKey);
      debugPrint('[Auth] 🗑️ Session removed from persistence');
    } catch (e) {
      debugPrint('[Auth] ⚠️ Error removing session: $e');
    }
  }

  @override
  Future<bool> hasAccessToken() async {
    try {
      return await _secureStorage.containsKey(key: _supabaseSecureKey);
    } catch (e) {
      debugPrint('[Auth] ⚠️ Error checking persistence: $e');
      return false;
    }
  }
}
