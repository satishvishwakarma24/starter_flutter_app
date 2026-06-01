import 'package:flutter/material.dart';
import '../../config/services/ads_service.dart';

/// App open ads are shown once on cold start from [SplashScreen] only.
/// This wrapper exists so [MaterialApp] can stay wrapped without resume ads.
class AppOpenAdWidget extends StatefulWidget {
  final Widget child;

  const AppOpenAdWidget({super.key, required this.child});

  @override
  State<AppOpenAdWidget> createState() => _AppOpenAdWidgetState();
}

class _AppOpenAdWidgetState extends State<AppOpenAdWidget>
    with WidgetsBindingObserver {
  static bool _handledThisSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_handledThisSession) return;
    _handledThisSession = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AdsService.instance.waitForAppOpenAd();
      if (!mounted) return;
      await AdsService.instance.showAppOpenAdOnColdStart();
      AdsService.instance.markColdStartComplete();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        AdsService.instance.isColdStartComplete &&
        !AdsService.instance.isShowingAppOpenAd) {
      AdsService.instance.showAppOpenAdIfAvailable();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
