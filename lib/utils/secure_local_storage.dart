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
      debugPrint('[Auth] ⚠️ Error during migration or init: $e');
      // If we can't even initialize, we might need to clear storage
      if (e.toString().contains('KeyStore')) {
        debugPrint('[Auth] 🚨 KeyStore corrupted, attempting to clear...');
        await _secureStorage.deleteAll();
      }
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
      debugPrint('[Auth] ❌ CRITICAL: Error reading from secure storage: $e');
      
      // On some Android devices, encryption keys can be lost or corrupted. 
      // If we detect a KeyStore error, we clear it so the next login can work.
      if (e.toString().contains('KeyStore') || e.toString().contains('BadPaddingException')) {
        debugPrint('[Auth] 🛡️ Resetting corrupted secure storage...');
        await _secureStorage.delete(key: _supabaseSecureKey);
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
