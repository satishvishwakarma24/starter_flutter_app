import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../config/services/ads_service.dart';

/// Native Advanced ad (small template) above bottom navigation.
class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({super.key});

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _ad;
  bool _loaded = false;

  static const double _minHeightFactor = 0.22;
  static const double _maxHeightFactor = 0.28;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final ad = NativeAd(
      adUnitId: AdsService.nativeAdvancedAdUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _loaded = true);
          }
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('Native ad failed: $err');
          ad.dispose();
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: AdsService.nativeTemplateStyle,
    );
    _ad = ad;
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final minHeight = (width * _minHeightFactor).clamp(72.0, 110.0);
    final maxHeight = (width * _maxHeightFactor).clamp(90.0, 140.0);

    if (!_loaded || _ad == null) {
      return SizedBox(width: width, height: minHeight);
    }

    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: width,
            maxWidth: width,
            minHeight: minHeight,
            maxHeight: maxHeight,
          ),
          child: AdWidget(ad: _ad!),
        ),
      ),
    );
  }
}
