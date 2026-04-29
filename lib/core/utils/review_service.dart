import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-App Review Service
class ReviewService {
  ReviewService._();
  static final ReviewService instance = ReviewService._();

  static const _launchKey = 'review_launch_count';
  static const _lastPromptKey = 'review_last_prompt';
  static const _promptedKey = 'review_prompted';

  static const int _minLaunches = 5; // prompt after N launches
  static const int _minDaysBetween =
      30; // and at least N days since last prompt
  static const bool _promptOnlyOnce = false; // set true to prompt max once

  final InAppReview _review = InAppReview.instance;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Call this once per app session (e.g. in HomeScreen initState).
  Future<void> trackSessionAndPromptIfEligible() async {
    final prefs = await SharedPreferences.getInstance();

    if (_promptOnlyOnce && (prefs.getBool(_promptedKey) ?? false)) return;

    final launches = (prefs.getInt(_launchKey) ?? 0) + 1;
    await prefs.setInt(_launchKey, launches);

    if (launches < _minLaunches) return;

    final lastPromptMs = prefs.getInt(_lastPromptKey) ?? 0;
    final daysSincePrompt = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(lastPromptMs))
        .inDays;

    if (lastPromptMs != 0 && daysSincePrompt < _minDaysBetween) return;

    await _prompt(prefs);
  }

  /// Manually trigger the review dialog (e.g. after a win/success moment).
  Future<void> requestReviewNow() async {
    final prefs = await SharedPreferences.getInstance();
    await _prompt(prefs);
  }

  // ── Internal ─────────────────────────────────────────────────────────────

  Future<void> _prompt(SharedPreferences prefs) async {
    if (!await _review.isAvailable()) {
      debugPrint('ℹ️ In-App Review not available — opening store fallback');
      await _review.openStoreListing(
        // TODO: replace with your real App / Play Store IDs
        appStoreId: 'YOUR_APP_STORE_ID', // iOS
      );
      return;
    }

    await _review.requestReview();
    await prefs.setInt(_lastPromptKey, DateTime.now().millisecondsSinceEpoch);
    await prefs.setBool(_promptedKey, true);
    debugPrint('⭐ In-App Review prompt triggered');
  }
}

/// Android behavior (API 11–15+ tested):
///   - Uses Google Play In-App Review API (native dialog, no redirect).
///   - Google throttles the prompt — it may not always show.
///
/// iOS behavior:
///   - Uses SKStoreReviewController (native prompt).
///   - Apple allows max 3 prompts per 365 days.
