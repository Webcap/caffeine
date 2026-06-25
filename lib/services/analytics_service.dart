import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  static AnalyticsService get instance => _instance;

  AnalyticsService._internal();

  Mixpanel? _mixpanel;
  bool _mixpanelInitialized = false;

  final FirebaseAnalytics _firebaseAnalytics = FirebaseAnalytics.instance;

  Future<void> initialize(String token) async {
    if (token.isEmpty) {
      debugPrint('Mixpanel token is empty, skipping initialization');
    } else if (!_mixpanelInitialized) {
      try {
        _mixpanel = await Mixpanel.init(token, trackAutomaticEvents: true);
        _mixpanelInitialized = true;
        debugPrint('Mixpanel initialized successfully');
      } catch (e) {
        debugPrint('Failed to initialize Mixpanel: $e');
      }
    }

    trackEvent('App Started');
  }

  /// Track a general user engagement event (Google Analytics + Mixpanel)
  void trackEvent(String eventName, [Map<String, dynamic>? properties]) {
    // 1. Log to Mixpanel for product analytics
    if (_mixpanelInitialized && _mixpanel != null) {
      try {
        _mixpanel!.track(eventName, properties: properties);
      } catch (e) {
        debugPrint('Failed to track Mixpanel event: $eventName: $e');
      }
    }

    // 2. Log to Google Analytics (Primary)
    _logToGoogleAnalytics(eventName, properties);
  }

  /// Track a technical Quality of Service (QoS) event (Google Analytics only)
  void trackQoSEvent(String eventName, [Map<String, dynamic>? properties]) {
    debugPrint('Analytics [QoS]: $eventName ${properties ?? ""}');
    _logToGoogleAnalytics(eventName, properties);
  }

  Future<void> _logToGoogleAnalytics(String eventName, Map<String, dynamic>? properties) async {
    try {
      // Firebase Analytics only accepts String, num, bool for parameter values.
      // We must filter out any complex objects before sending.
      Map<String, Object>? safeProperties;
      
      if (properties != null) {
        safeProperties = {};
        properties.forEach((key, value) {
          if (value is String || value is num || value is bool) {
            safeProperties![key] = value;
          } else {
            // Convert to string as a fallback for complex types
            safeProperties![key] = value.toString();
          }
        });
      }

      await _firebaseAnalytics.logEvent(
        name: _sanitizeEventName(eventName),
        parameters: safeProperties,
      );
    } catch (e) {
      debugPrint('Failed to log event to Google Analytics: $e');
    }
  }

  /// Firebase event names must contain only letters, numbers, and underscores,
  /// and must start with a letter. Max length is 40 chars.
  String _sanitizeEventName(String eventName) {
    String sanitized = eventName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    if (sanitized.length > 40) {
      sanitized = sanitized.substring(0, 40);
    }
    // Ensure it starts with a letter
    if (!sanitized.startsWith(RegExp(r'[a-zA-Z]'))) {
      sanitized = 'evt_$sanitized';
    }
    return sanitized;
  }

  void identify(String userId) {
    if (_mixpanelInitialized && _mixpanel != null) {
      debugPrint('Mixpanel identify: $userId');
      _mixpanel!.identify(userId);
    }
    
    debugPrint('Google Analytics setUserId: $userId');
    _firebaseAnalytics.setUserId(id: userId);
  }

  void setUserProfile(String key, dynamic value) {
    if (_mixpanelInitialized && _mixpanel != null) {
      debugPrint('Mixpanel setProfile: $key = $value');
      _mixpanel!.getPeople().set(key, value);
    }

    debugPrint('Google Analytics setUserProperty: $key = $value');
    if (value is String) {
      _firebaseAnalytics.setUserProperty(name: key, value: value);
    } else {
      _firebaseAnalytics.setUserProperty(name: key, value: value.toString());
    }
  }

  void reset() {
    if (_mixpanelInitialized && _mixpanel != null) {
      debugPrint('Mixpanel reset');
      _mixpanel!.reset();
    }
    
    // There isn't a direct "reset" for Firebase Analytics in the same way,
    // but setting user ID to null effectively resets the current user context.
    _firebaseAnalytics.setUserId(id: null);
  }
}
