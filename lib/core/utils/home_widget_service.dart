import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../config/constants/engagement_config.dart';

/// Bridges Flutter state to native home-screen widgets (Android + iOS).
class HomeWidgetService {
  HomeWidgetService._();
  static final HomeWidgetService instance = HomeWidgetService._();

  static const String keyTitle = 'widget_title';
  static const String keySubtitle = 'widget_subtitle';
  static const String keyUpdatedAt = 'widget_updated_at';

  bool _initialized = false;

  // ── Public API ────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;

    if (!kIsWeb) {
      try {
        await HomeWidget.setAppGroupId(EngagementConfig.iosAppGroupId);
      } catch (e) {
        debugPrint('ℹ️ HomeWidget iOS group not configured yet: $e');
      }
    }

    _initialized = true;
  }

  /// Persists display data and asks the OS to refresh the widget.
  Future<void> syncFromApp({
    String? title,
    String? subtitle,
  }) async {
    await initialize();

    final info = await PackageInfo.fromPlatform();
    final resolvedTitle = title ?? EngagementConfig.appDisplayName;
    final resolvedSubtitle =
        subtitle ?? 'v${info.version} · Tap to open';

    await HomeWidget.saveWidgetData<String>(keyTitle, resolvedTitle);
    await HomeWidget.saveWidgetData<String>(keySubtitle, resolvedSubtitle);
    await HomeWidget.saveWidgetData<String>(
      keyUpdatedAt,
      DateTime.now().toIso8601String(),
    );

    await HomeWidget.updateWidget(
      name: EngagementConfig.androidWidgetProvider,
      androidName: EngagementConfig.androidWidgetProvider,
      iOSName: EngagementConfig.iosWidgetKind,
      qualifiedAndroidName: EngagementConfig.androidWidgetQualifiedName,
    );

    debugPrint('🏠 Home widget data synced');
  }

  /// Opens the platform pin-widget UI (Android 8+ when supported).
  Future<void> requestPinWidget() async {
    await initialize();
    try {
      await HomeWidget.requestPinWidget(
        name: EngagementConfig.androidWidgetProvider,
        androidName: EngagementConfig.androidWidgetProvider,
        qualifiedAndroidName: EngagementConfig.androidWidgetQualifiedName,
      );
    } catch (e) {
      debugPrint('ℹ️ Pin widget not available: $e');
    }
  }

  Future<bool> isPinSupported() async {
    await initialize();
    try {
      return await HomeWidget.isRequestPinWidgetSupported() ?? false;
    } catch (_) {
      return false;
    }
  }
}
