import 'package:flutter/material.dart';

import 'banner_ad_widget.dart';
import 'native_ad_widget.dart';

/// Shared bottom ads area used across app screens.
class BottomAdsSection extends StatelessWidget {
  const BottomAdsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:  [
            NativeAdWidget(),
            SizedBox(height: 6),
            Center(child: BannerAdWidget()),
          ],
        ),
      ),
    );
  }
}
