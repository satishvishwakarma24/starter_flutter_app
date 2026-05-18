import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Handles: Banner, Interstitial, Rewarded, App Open Ads
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  // ── Ad Unit IDs ──────────────────────────────────────────────────────────
  // Replace with your real Ad Unit IDs from AdMob console: TODO
  // Test IDs are used automatically in debug mode.

  static String get _bannerId => kDebugMode
      ? 'ca-app-pub-3940256099942544/6300978111'     // test
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';   // production

  static String get _interstitialId => kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  static String get _rewardedId => kDebugMode
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  static String get _appOpenId => kDebugMode
      ? 'ca-app-pub-3940256099942544/9257395921'
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  // ── Internal State ───────────────────────────────────────────────────────
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  AppOpenAd? _appOpenAd;

  bool _isInterstitialReady = false;
  bool _isRewardedReady = false;
  bool _isAppOpenReady = false;

  // ── Initialize ───────────────────────────────────────────────────────────
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadInterstitial();
    _loadRewarded();
    _loadAppOpenAd();
  }

  // ── Banner Ad ────────────────────────────────────────────────────────────
  Future<BannerAd> loadBannerAd() async {
    _bannerAd = BannerAd(
      adUnitId: _bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => debugPrint('✅ Banner loaded'),
        onAdFailedToLoad: (ad, err) {
          debugPrint('❌ Banner failed: $err');
          ad.dispose();
        },
      ),
    );
    await _bannerAd!.load();
    return _bannerAd!;
  }

  BannerAd? get bannerAd => _bannerAd;

  // ── Interstitial Ad ──────────────────────────────────────────────────────
  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialReady = true;
          debugPrint('✅ Interstitial loaded');
        },
        onAdFailedToLoad: (err) {
          _isInterstitialReady = false;
          debugPrint('❌ Interstitial failed: $err');
        },
      ),
    );
  }

  void showInterstitial() {
    if (_isInterstitialReady && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isInterstitialReady = false;
          _loadInterstitial(); // preload next
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _loadInterstitial();
        },
      );
      _interstitialAd!.show();
    }
  }

  // ── Rewarded Ad ──────────────────────────────────────────────────────────
  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: _rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedReady = true;
          debugPrint('✅ Rewarded loaded');
        },
        onAdFailedToLoad: (err) {
          _isRewardedReady = false;
          debugPrint('❌ Rewarded failed: $err');
        },
      ),
    );
  }

  void showRewarded({required void Function(AdWithoutView, RewardItem) onRewarded}) {
    if (_isRewardedReady && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isRewardedReady = false;
          _loadRewarded();
        },
      );
      _rewardedAd!.show(onUserEarnedReward: onRewarded);
    }
  }

  // ── App Open Ad ──────────────────────────────────────────────────────────
  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: _appOpenId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenReady = true;
          debugPrint('✅ App Open Ad loaded');
        },
        onAdFailedToLoad: (err) {
          _isAppOpenReady = false;
          debugPrint('❌ App Open Ad failed: $err');
        },
      ),
    );
  }

  void showAppOpenAd() {
    if (_isAppOpenReady && _appOpenAd != null) {
      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isAppOpenReady = false;
          _loadAppOpenAd();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _loadAppOpenAd();
        },
      );
      _appOpenAd!.show();
    }
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _appOpenAd?.dispose();
  }
}