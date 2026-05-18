import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../config/services/ads_service.dart';

/// Drop-in Banner Ad widget.
/// Loads its own ad instance; safe to use in any screen.
class BannerAdWidget extends StatefulWidget {
  final AdSize size;

  const BannerAdWidget({super.key, this.size = AdSize.banner});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    final ad = await AdsService.instance.loadBannerAd();
    if (mounted) {
      setState(() {
        _ad = ad;
        _loaded = true;
      });
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _ad == null) {
      return SizedBox(height: widget.size.height.toDouble());
    }
    return SafeArea(
      top: false,
      child: SizedBox(
        width: widget.size.width.toDouble(),
        height: widget.size.height.toDouble(),
        child: AdWidget(ad: _ad!),
      ),
    );
  }
}
