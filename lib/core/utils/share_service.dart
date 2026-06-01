import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/constants/engagement_config.dart';

/// Share mechanics for organic growth (invite friends, achievements, etc.).
class ShareService {
  ShareService._();
  static final ShareService instance = ShareService._();

  static const _shareCountKey = 'share_count';
  static const _lastSharePromptKey = 'share_last_prompt';
  static const _hasSharedKey = 'share_has_shared';

  // ── Public API ────────────────────────────────────────────────────────────

  /// Opens the system share sheet with a store link and optional highlight.
  Future<void> shareApp({String? highlight, Rect? sharePositionOrigin}) async {
    await _share(
      EngagementConfig.defaultShareMessage(highlight: highlight),
      sharePositionOrigin: sharePositionOrigin,
    );
    await _recordShare();
  }

  /// Share after a positive moment (task done, streak, high score, etc.).
  Future<void> shareAchievement(
    String achievement, {
    Rect? sharePositionOrigin,
  }) async {
    await shareApp(
      highlight: achievement,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  /// Whether to show a gentle invite prompt (not on first launch).
  Future<bool> shouldShowSharePrompt() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_hasSharedKey) ?? false) return false;

    final launches = prefs.getInt('review_launch_count') ?? 0;
    if (launches < EngagementConfig.sharePromptMinLaunches) return false;

    final lastMs = prefs.getInt(_lastSharePromptKey) ?? 0;
    if (lastMs == 0) return true;

    final daysSince = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(lastMs))
        .inDays;
    return daysSince >= EngagementConfig.sharePromptMinDaysBetween;
  }

  Future<void> markSharePromptShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _lastSharePromptKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<int> getShareCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_shareCountKey) ?? 0;
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  Future<void> _share(
    String text, {
    Rect? sharePositionOrigin,
  }) async {
    const subject = 'Try ${EngagementConfig.appDisplayName}';
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: subject,
        sharePositionOrigin: _shareOrigin(sharePositionOrigin),
      ),
    );
  }

  Rect? _shareOrigin(Rect? origin) {
    if (origin != null) return origin;
    if (kIsWeb || !Platform.isIOS) return null;
    // iPad requires a non-zero origin for the share popover.
    return const Rect.fromLTWH(0, 0, 1, 1);
  }

  Future<void> _recordShare() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_shareCountKey) ?? 0) + 1;
    await prefs.setInt(_shareCountKey, count);
    await prefs.setBool(_hasSharedKey, true);
    debugPrint('📤 Share recorded (total: $count)');
  }
}
