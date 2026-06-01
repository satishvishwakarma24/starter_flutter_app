import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/constants/engagement_config.dart';

/// Smart in-app review prompts (Play Store + App Store).
class ReviewService {
  ReviewService._();
  static final ReviewService instance = ReviewService._();

  static const _launchKey = 'review_launch_count';
  static const _lastPromptKey = 'review_last_prompt';
  static const _promptedKey = 'review_prompted';
  static const _positiveMomentsKey = 'review_positive_moments';

  final InAppReview _review = InAppReview.instance;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Call once per app session (e.g. HomeScreen initState).
  Future<void> trackSessionAndPromptIfEligible() async {
    final prefs = await SharedPreferences.getInstance();

    if (EngagementConfig.reviewPromptOnlyOnce &&
        (prefs.getBool(_promptedKey) ?? false)) {
      return;
    }

    final launches = (prefs.getInt(_launchKey) ?? 0) + 1;
    await prefs.setInt(_launchKey, launches);

    if (launches < EngagementConfig.reviewMinLaunches) return;

    final lastPromptMs = prefs.getInt(_lastPromptKey) ?? 0;
    final daysSincePrompt = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(lastPromptMs))
        .inDays;

    if (lastPromptMs != 0 &&
        daysSincePrompt < EngagementConfig.reviewMinDaysBetween) {
      return;
    }

    await _prompt(prefs);
  }

  /// After a success moment (task completed, streak, etc.) — lower bar than sessions.
  Future<void> trackPositiveMomentAndPromptIfEligible() async {
    final prefs = await SharedPreferences.getInstance();
    final moments = (prefs.getInt(_positiveMomentsKey) ?? 0) + 1;
    await prefs.setInt(_positiveMomentsKey, moments);

    // Prompt on 1st, 3rd, and 10th positive moments (customize as needed).
    const triggerMoments = {1, 3, 10};
    if (!triggerMoments.contains(moments)) return;

    if (EngagementConfig.reviewPromptOnlyOnce &&
        (prefs.getBool(_promptedKey) ?? false)) {
      return;
    }

    await _prompt(prefs);
  }

  /// Opens the platform in-app review UI directly (no custom pre-dialog).
  ///
  /// Android: Play bottom sheet with stars + optional review text.
  /// iOS: SKStoreReviewController (system star prompt).
  /// Google/Apple may throttle how often it appears outside production.
  Future<void> requestReviewNow() async {
    final prefs = await SharedPreferences.getInstance();
    await _prompt(prefs);
  }

  Future<int> getLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_launchKey) ?? 0;
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  Future<void> _prompt(SharedPreferences prefs) async {
    if (!await _review.isAvailable()) {
      debugPrint('ℹ️ In-App Review not available — opening store listing');
      await _review.openStoreListing(
        appStoreId: EngagementConfig.iosAppStoreId,
      );
      await _markPrompted(prefs);
      return;
    }

    await _review.requestReview();
    await _markPrompted(prefs);
    debugPrint('⭐ In-App Review prompt triggered');
  }

  Future<void> _markPrompted(SharedPreferences prefs) async {
    await prefs.setInt(_lastPromptKey, DateTime.now().millisecondsSinceEpoch);
    await prefs.setBool(_promptedKey, true);
  }
}

/// Android: Google Play In-App Review API (throttled by Google).
/// iOS: SKStoreReviewController (max ~3 prompts / 365 days).
