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
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(_supabaseSecureKey)) {
        final legacyToken = prefs.getString(_supabaseSecureKey);
        if (legacyToken != null) {
          debugPrint('[Auth] 🔑 Migrating legacy token from SharedPreferences to Secure Storage');
          await _secureStorage.write(key: _supabaseSecureKey, value: legacyToken);
        }
        await prefs.remove(_supabaseSecureKey);
      }
    } catch (e) {
      debugPrint('[Auth] ⚠️ Error migrating legacy token: $e');
    }
  }

  @override
  Future<String?> accessToken() async {
    try {
      final session = await _secureStorage.read(key: _supabaseSecureKey);
      if (session != null) {
        debugPrint('[Auth] 📥 Session read successfully from Secure Storage');
      }
      return session;
    } catch (e) {
      debugPrint('[Auth] ❌ CRITICAL: Error reading from secure storage: $e');
      // On some Android devices, encryption keys can be lost. 
      // We return null so Supabase knows it needs to re-auth rather than hanging.
      return null;
    }
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    try {
      await _secureStorage.write(key: _supabaseSecureKey, value: persistSessionString);
      debugPrint('[Auth] 💾 Session persisted to Secure Storage');
    } catch (e) {
      debugPrint('[Auth] ❌ CRITICAL: Error writing to secure storage: $e');
    }
  }

  @override
  Future<void> removePersistedSession() async {
    try {
      await _secureStorage.delete(key: _supabaseSecureKey);
      debugPrint('[Auth] 🗑️ Session removed from Secure Storage');
    } catch (e) {
      debugPrint('[Auth] ⚠️ Error removing from secure storage: $e');
    }
  }

  @override
  Future<bool> hasAccessToken() async {
    try {
      final exists = await _secureStorage.containsKey(key: _supabaseSecureKey);
      return exists;
    } catch (e) {
      debugPrint('[Auth] ⚠️ Error checking secure storage key: $e');
      return false;
    }
  }
}
