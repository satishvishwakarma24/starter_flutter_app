/// Store IDs, share copy, and engagement thresholds.
/// Replace placeholders before shipping to production.
abstract class EngagementConfig {
  EngagementConfig._();

  static const String appDisplayName = 'Starter App';

  /// iOS App Store numeric ID (Settings → App Information in App Store Connect).
  static const String iosAppStoreId = 'YOUR_APP_STORE_ID';

  /// Android applicationId — must match `android/app/build.gradle.kts`.
  static const String androidPackageName = 'com.example.starterapp';

  /// Public store listing URLs (used in share text and fallbacks).
  // static const String playStoreUrl =
  //     'https://play.google.com/store/apps/details?id=$androidPackageName';

  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.krishhapps.weathertoday.environmental.tracker.radar.rain.uv.aqi.widget.forcast&hl=en';

  static const String appStoreUrl =
      'https://apps.apple.com/app/id$iosAppStoreId';

  /// iOS App Group for home_widget (requires paid Apple Developer account).
  static const String iosAppGroupId = 'group.com.example.starterapp';

  /// Android widget provider class name (must match Kotlin receiver).
  static const String androidWidgetProvider = 'StarterAppWidgetProvider';
  static const String androidWidgetQualifiedName =
      '$androidPackageName.$androidWidgetProvider';

  /// iOS Widget Extension kind (set in Xcode Widget Extension).
  static const String iosWidgetKind = 'StarterAppWidget';

  // ── In-app review ─────────────────────────────────────────────────────────

  static const int reviewMinLaunches = 5;
  static const int reviewMinDaysBetween = 30;
  static const bool reviewPromptOnlyOnce = false;

  // ── Share / viral loop ────────────────────────────────────────────────────

  static const int sharePromptMinLaunches = 3;
  static const int sharePromptMinDaysBetween = 14;

  static String defaultShareMessage({String? highlight}) {
    final buffer = StringBuffer();
    if (highlight != null && highlight.isNotEmpty) {
      buffer.writeln(highlight);
      buffer.writeln();
    }
    buffer.writeln('Check out $appDisplayName!');
    buffer.writeln('Android: $playStoreUrl');
    buffer.writeln('iOS: $appStoreUrl');
    return buffer.toString().trim();
  }
}
