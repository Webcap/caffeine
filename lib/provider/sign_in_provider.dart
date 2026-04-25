import 'package:reelriot/services/analytics_service.dart';
import 'package:reelriot/controller/bookmark_database_controller.dart';
import 'package:reelriot/controller/recently_watched_database_controller.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/services/purchase_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:username_generator/username_generator.dart';
import 'package:reelriot/utils/routes/app_pages.dart';
import 'package:get/get.dart';
import 'dart:async';

class SignInProvider extends ChangeNotifier {
  final AppDependencyProvider? appDependencyProvider;
  final _auth = Supabase.instance.client.auth;
  var generator = UsernameGenerator();

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _provider;
  String? get provider => _provider;

  String? _uid;
  String? get uid => _uid;

  String? _email;
  String? get email => _email;

  String? _name;
  String? get name => _name;

  String? _imageUrl;
  String? get imageUrl => _imageUrl;

  String? _username;
  String? get username => _username;

  int? _profileId;
  int? get profileId => _profileId;

  bool? _firstRun;
  bool? get firstRun => _firstRun;

  /// The auth stream to subscribe to. Defaults to the real Supabase stream.
  /// Override in tests to drive auth events without a real Supabase connection.
  final Stream<AuthState> _authStream;

  StreamSubscription<AuthState>? _authSubscription;

  SignInProvider({
    this.appDependencyProvider,
    Stream<AuthState>? authStream,
  }) : _authStream = authStream ?? Supabase.instance.client.auth.onAuthStateChange {
    _init();
  }

  void _init() {
    // Seed state from any session that is already present in memory (fast path).
    // Note: Supabase.initialize in main.dart should have already awaited storage loading.
    final existing = _auth.currentSession;
    if (existing != null) {
      debugPrint('[Auth] ⚡ Initial session found in memory: ${existing.user.email}');
      _applySession(existing);
    } else {
       debugPrint('[Auth] ℹ️ No initial session found in memory');
    }

    // Listen reactively to all future auth events.
    _authSubscription = _authStream.listen(
      (data) {
         _onAuthEvent(data.event, data.session);
      },
      onError: (e) {
        // Network-level errors (AuthRetryableFetchException) are emitted here.
        // They do NOT mean the user signed out — just that we couldn't reach
        // Supabase right now. Log and ignore.
        debugPrint('[Auth] ⚠️ Auth stream error (network?): $e');
      },
    );
  }

  Future<void> _onAuthEvent(AuthChangeEvent event, Session? session) async {
    debugPrint('[Auth] 🔄 Event: $event');

    switch (event) {
      case AuthChangeEvent.initialSession:
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.tokenRefreshed:
      case AuthChangeEvent.userUpdated:
        if (session != null) {
          // Fetch fresh user to bypass stale session metadata
          try {
            final freshUser = await _auth.getUser();
            if (freshUser.user != null) {
              _applyUser(freshUser.user!);
            } else {
              _applySession(session);
            }
          } catch (e) {
            debugPrint('[Auth] ⚠️ Could not fetch fresh user (session expired?): $e');
            _applySession(session);
          }
          
          // Fetch fresh profile data (this will also update UID/provider/etc.)
          try {
            await getUserDataFromFirestore(session.user.id);
          } catch (e) {
            debugPrint('[Auth] ⚠️ Could not fetch profile (offline?): $e');
          }
          _initRevenueCat(session.user.id);
          AnalyticsService.instance.identify(session.user.id);
        } else if (event == AuthChangeEvent.initialSession) {
           debugPrint('[Auth] ℹ️ Initial session was null');
        }
        break;

      case AuthChangeEvent.signedOut:
        // Only treat this as a real sign-out if Supabase has no cached
        // session left. When a token-refresh fails due to no network,
        // Supabase fires signedOut but the old session is still valid
        // locally. In that case, do nothing.
        // Also added check for _isSignedIn to avoid redundant logouts on startup.
        if (_auth.currentSession == null && _isSignedIn) {
          debugPrint('[Auth] 🔑 Real sign-out detected');
          _handleSignOut();
        } else {
          debugPrint('[Auth] ℹ️ signedOut event ignored — session still present locally or already signed out');
        }
        break;

      case AuthChangeEvent.passwordRecovery:
        break;

      // Supabase SDK may add new events in future versions — handle gracefully.
      // ignore: no_default_cases
      default:
        debugPrint('[Auth] 🔄 Unhandled event: $event');
    }
  }

  void _applySession(Session session) {
    _applyUser(session.user);
  }

  void _applyUser(User user) {
    _uid = user.id;
    _email = user.email;
    _name = user.userMetadata?['full_name'] as String? ??
        user.userMetadata?['name'] as String?;
    _imageUrl = user.userMetadata?['avatar_url'] as String?;
    _profileId = int.tryParse(user.userMetadata?['avatar']?.toString() ?? '');
    _isSignedIn = true;
    notifyListeners();

    // Fetch extended profile in background (username, etc.)
    getUserDataFromFirestore(user.id).catchError((e) {
      debugPrint('[Auth] ⚠️ Could not fetch profile in background: $e');
    });
  }

  void _initRevenueCat(String userId) {
    if (appDependencyProvider == null) return;
    PurchaseService.init(
      userId,
      androidKey: appDependencyProvider!.revenueCatApiKeyAndroid,
      iosKey: appDependencyProvider!.revenueCatApiKeyIOS,
      entitlementId: appDependencyProvider!.revenueCatEntitlementId,
      disabled: appDependencyProvider!.disableRevenueCat,
    );
  }

  void _handleSignOut() async {
    _isSignedIn = false;
    _uid = null;
    _email = null;
    _name = null;
    _imageUrl = null;
    _profileId = null;
    _username = null;
    notifyListeners();
    await clearStoredData();

    // Initialize RevenueCat anonymously after sign-out.
    if (appDependencyProvider != null) {
      PurchaseService.init(
        null,
        androidKey: appDependencyProvider!.revenueCatApiKeyAndroid,
        iosKey: appDependencyProvider!.revenueCatApiKeyIOS,
        entitlementId: appDependencyProvider!.revenueCatEntitlementId,
        disabled: appDependencyProvider!.disableRevenueCat,
      );
    }
    AnalyticsService.instance.trackEvent('Signed Out');
    AnalyticsService.instance.reset();

    // Global redirect to login if we are signed out.
    // Use a small delay to ensure providers and state are fully updated.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isSignedIn) {
        Get.offAllNamed(Routes.login);
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  // ─── Public API ────────────────────────────────────────────────────────────

  Future<void> insertUsername(String username, String uid) async {
    await Supabase.instance.client
        .from('usernames')
        .insert({'username': username.toLowerCase(), 'user_id': uid});
  }

  Future<String> createRandomUsername() async {
    final supabase = Supabase.instance.client;
    String username = '';
    var available = false;

    while (!available) {
      username = generator.generateRandom();
      final res = await supabase
          .from('usernames')
          .select('username')
          .eq('username', username.toLowerCase())
          .limit(1);
      available = res.isEmpty;
    }

    return username;
  }

  Future<void> signInWithGoogle() async {
    _hasError = false;
    _errorCode = null;
    try {
      await _auth.signInWithOAuth(OAuthProvider.google);
      // Auth state is picked up by _onAuthEvent listener — no manual update needed.
      notifyListeners();
    } on AuthException catch (e) {
      _hasError = true;
      _errorCode = e.message;
      notifyListeners();
    }
  }

  Future<void> getUserDataFromFirestore([String? uid]) async {
    final id = uid ?? _uid;
    if (id == null) return;

    try {
      final res = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', id)
          .limit(1);

      if (res.isNotEmpty) {
        final data = res[0];
        _uid = data['id']?.toString();
        _name = data['name'] as String?;
        _email = data['email'] as String?;
        _imageUrl = data['image_url'] as String?;
        final dbProfileId = int.tryParse(data['profile_id']?.toString() ?? '');
        if (dbProfileId != null && dbProfileId != 0) {
          _profileId = dbProfileId;
        }
        _provider = data['provider'] as String?;
        _firstRun = data['first_run'] as bool?;
        _username = data['username'] as String?;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[Auth] ⚠️ Could not fetch profile (offline?): $e');
    }
  }

  Future<void> saveDatatoFirestore() async {
    if (_uid == null) return;

    await Supabase.instance.client.from('profiles').upsert({
      'id': _uid,
      'name': _name,
      'email': _email,
      'profile_id': 0,
      'image_url': _imageUrl ?? '',
      'provider': _provider ?? 'email',
      'verified': false,
      'is_subscribed': false,
      'first_run': false,
    });
    notifyListeners();
  }

  Future<bool> checkuserExists() async {
    if (_uid == null) return false;

    final res = await Supabase.instance.client
        .from('profiles')
        .select('id')
        .eq('id', _uid!)
        .limit(1);

    return res.isNotEmpty;
  }

  Future<bool> checkUsername(String username) async {
    final res = await Supabase.instance.client
        .from('usernames')
        .select('username')
        .eq('username', username.trim().toLowerCase())
        .limit(1);

    return res.isEmpty;
  }

  Future<void> userSignOut() async {
    await _auth.signOut();
    // _handleSignOut will be triggered by the onAuthStateChange listener.
    // Force it locally too in case the event doesn't fire (e.g. offline).
    _handleSignOut();
  }

  Future<void> clearStoredData() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    await s.remove('name');
    await s.remove('email');
    await s.remove('uid');
    await s.remove('imageUrl');
    await s.remove('provider');
    await s.remove('username');
    await s.remove('firstRun');
    await s.remove('caffeine_recent_searches');
    await s.remove('adultStatus-v2');

    // Clear local watch data so new user does not see previous user's data.
    await RecentlyWatchedMoviesController().clearAllMovies();
    await RecentlyWatchedEpisodeController().clearAllEpisodes();
    await MovieDatabaseController().clearAll();
    await TVDatabaseController().clearAll();
  }
}
