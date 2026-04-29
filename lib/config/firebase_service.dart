import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:flutter/foundation.dart';

/// Firebase Analytics + Crashlytics Service
class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // ── Analytics ────────────────────────────────────────────────────────────

  /// Log a custom screen view
  Future<void> logScreenView(String screenName, {String? screenClass}) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  /// Log a custom event
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    await _analytics.logEvent(name: name, parameters: params);
  }

  /// Log a purchase / revenue event
  Future<void> logPurchase({
    required String productId,
    required double value,
    String currency = 'USD',
  }) async {
    await _analytics.logPurchase(
      currency: currency,
      value: value,
      items: [AnalyticsEventItem(itemId: productId, itemName: productId)],
    );
  }

  /// Set user property (e.g. is_premium)
  Future<void> setUserProperty(String name, String? value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  /// Set user ID
  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
  }

  // ── Crashlytics ──────────────────────────────────────────────────────────

  /// Enable/disable crash reporting (respect user consent)
  Future<void> setCrashlyticsEnabled(bool enabled) async {
    await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
  }

  /// Log a non-fatal error
  Future<void> recordError(dynamic exception, StackTrace? stack,
      {String? reason}) async {
    await _crashlytics.recordError(exception, stack, reason: reason);
  }

  /// Set a custom key for crash context
  Future<void> setCustomKey(String key, Object value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  /// Set user identifier for crash reports
  Future<void> setCrashlyticsUserId(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
  }

  // ── Navigator Observer ───────────────────────────────────────────────────
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);
}
