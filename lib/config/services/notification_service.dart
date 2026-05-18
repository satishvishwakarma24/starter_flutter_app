import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// Handles both Firebase Cloud Messaging (FCM) and OneSignal notifications.
///
/// Strategy:
///   - Use FCM for server-triggered / topic-based pushes (e.g. news, alerts).
///   - Use OneSignal for marketing & segmented campaigns via OneSignal dashboard.

/// FCM background handler — MUST be a top-level function
@pragma('vm:entry-point')
Future<void> _fcmBackgroundHandler(RemoteMessage message) async {
  debugPrint('📩 FCM BG message: ${message.messageId}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  // ── OneSignal App ID ─────────────────────────────────────────────────────
  // TODO: Replace with your OneSignal App ID from https://onesignal.com
  static const String _oneSignalAppId = 'YOUR_ONESIGNAL_APP_ID';

  // ── Initialize ───────────────────────────────────────────────────────────
  Future<void> initialize() async {
    await _initFCM();
    _initOneSignal();
  }

  // ── Firebase Cloud Messaging (FCM) ───────────────────────────────────────
  Future<void> _initFCM() async {
    FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);

    // Request permission (iOS)
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('🔔 FCM permission: ${settings.authorizationStatus}');

    // Get FCM token
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('🔑 FCM Token: $token');

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📬 FCM foreground: ${message.notification?.title}');
      // TODO: Show local notification using flutter_local_notifications
    });

    // Notification tapped while app in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🔓 FCM opened: ${message.data}');
      // TODO: Navigate based on message.data['route']
    });

    // Subscribe to a default topic
    await FirebaseMessaging.instance.subscribeToTopic('general');
  }

  // ── OneSignal ────────────────────────────────────────────────────────────
  void _initOneSignal() {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(_oneSignalAppId);

    // Request notification permission prompt
    OneSignal.Notifications.requestPermission(true);

    // Listen for foreground notification display
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint('📬 OneSignal foreground: ${event.notification.title}');
      event.notification.display(); // show it
    });

    // Listen for notification click
    OneSignal.Notifications.addClickListener((event) {
      debugPrint('🔓 OneSignal click: ${event.notification.additionalData}');
      // TODO: Navigate based on additionalData['route']
    });

    // Track subscription state
    OneSignal.User.pushSubscription.addObserver((state) {
      debugPrint('📡 OneSignal subscription id: ${state.current.id}');
    });
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Tag a OneSignal user (e.g. after login)
  void tagUser({required String key, required String value}) {
    OneSignal.User.addTagWithKey(key, value);
  }

  /// Remove OneSignal tag
  void removeTag(String key) {
    OneSignal.User.removeTag(key);
  }

  /// Subscribe or unsubscribe from FCM topic
  Future<void> toggleTopic(String topic, {required bool subscribe}) async {
    if (subscribe) {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    }
  }

  /// Get current FCM token (useful to send to backend)
  Future<String?> getFcmToken() => FirebaseMessaging.instance.getToken();
}
