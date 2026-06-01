import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/theme/theme.dart';

/// App open and native advanced ads for AdMob.
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  static const String _prodAppId = 'ca-app-pub-4424067808361380~4015549046';
  static const String _prodNativeAdvancedId =
      'ca-app-pub-4424067808361380/3357073497';
  static const String _prodAppOpenId = 'ca-app-pub-4424067808361380/2598525592';
  static const String _prodBannerId = 'ca-app-pub-4424067808361380/4494591423';

  static String get appId => _prodAppId;

  static String get nativeAdvancedAdUnitId {
    if (kDebugMode) {
      if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/3986624511';
      }
      return 'ca-app-pub-3940256099942544/2247696110';
    }
    return _prodNativeAdvancedId;
  }

  static String get appOpenAdUnitId =>
      kDebugMode ? 'ca-app-pub-3940256099942544/9257395921' : _prodAppOpenId;

  static String get bannerAdUnitId =>
      kDebugMode ? 'ca-app-pub-3940256099942544/6300978111' : _prodBannerId;

  static NativeTemplateStyle get nativeTemplateStyle => NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: AppColors.bgMid,
        cornerRadius: 12.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.textOnCta,
          backgroundColor: AppColors.starBlue,
          style: NativeTemplateFontStyle.bold,
          size: 14.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.textPrimary,
          style: NativeTemplateFontStyle.bold,
          size: 14.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.textSub,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.textSub,
          style: NativeTemplateFontStyle.normal,
          size: 11.0,
        ),
      );

  AppOpenAd? _appOpenAd;
  bool _isAppOpenReady = false;
  bool _isShowingAppOpenAd = false;
  bool _isLoadingAppOpen = false;
  bool _coldStartComplete = false;
  bool _hasShownAppOpenAd = false;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadAppOpenAd();
  }

  bool get isAppOpenAdAvailable => _appOpenAd != null && _isAppOpenReady;

  bool get isShowingAppOpenAd => _isShowingAppOpenAd;

  bool get isColdStartComplete => _coldStartComplete;

  bool get hasShownAppOpenAd => _hasShownAppOpenAd;

  /// Splash waits for the first app open ad (or [timeout]).
  Future<void> waitForAppOpenAd({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    if (isAppOpenAdAvailable) return;

    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      if (isAppOpenAdAvailable) return;
      // Stop only when loading finished without an ad (failed), not while still loading.
      if (!_isLoadingAppOpen && !isAppOpenAdAvailable) return;
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Shown once per app session from cold start.
  Future<void> showAppOpenAdOnColdStart() async {
    if (_hasShownAppOpenAd) {
      return;
    }
    _hasShownAppOpenAd = true;
    await showAppOpenAdIfAvailable();
  }

  /// Shows app open ad when loaded (for app foreground events).
  Future<void> showAppOpenAdIfAvailable() async {
    if (!isAppOpenAdAvailable || _isShowingAppOpenAd) {
      return;
    }

    final dismissed = Completer<void>();
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => _isShowingAppOpenAd = true,
      onAdDismissedFullScreenContent: (ad) {
        _onAppOpenAdClosed(ad);
        if (!dismissed.isCompleted) dismissed.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        debugPrint('App open ad show failed: $err');
        _onAppOpenAdClosed(ad);
        if (!dismissed.isCompleted) dismissed.complete();
      },
    );

    await _appOpenAd!.show();
    await dismissed.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {},
    );
  }

  void markColdStartComplete() {
    _coldStartComplete = true;
  }

  void _loadAppOpenAd() {
    if (_isLoadingAppOpen) return;
    _isLoadingAppOpen = true;
    _isAppOpenReady = false;

    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenReady = true;
          _isLoadingAppOpen = false;
          debugPrint('App open ad loaded');
        },
        onAdFailedToLoad: (err) {
          _appOpenAd = null;
          _isAppOpenReady = false;
          _isLoadingAppOpen = false;
          debugPrint('App open ad failed: $err');
        },
      ),
    );
  }

  void _onAppOpenAdClosed(Ad ad) {
    _isShowingAppOpenAd = false;
    ad.dispose();
    _appOpenAd = null;
    _isAppOpenReady = false;
    _loadAppOpenAd();
  }

  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _isAppOpenReady = false;
  }
}
