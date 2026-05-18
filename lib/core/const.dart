import 'package:flutter/material.dart';

abstract class Constants {
  Constants._();

  static const String appName = 'Coin Toaster';
  static const String appVersion = '1.0.0';
}

// 🎬 ANIMATION CONSTANTS
abstract class AppAnimations {
  static const Duration fast = Duration(milliseconds: 300);
  static const Duration normal = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 1000);
  static const Duration verySlow = Duration(milliseconds: 2000);

  static const Duration autoCleanerTotal = Duration(seconds: 45);
  static const Duration autoCleanerTick = Duration(milliseconds: 450);

  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounce = Curves.elasticOut;
  static const Curve spring = Curves.fastOutSlowIn;
  static const Curve linear = Curves.linear;

  static const Duration waveCycle = Duration(seconds: 3);
  static const Duration pulseCycle = Duration(milliseconds: 1200);

  static const Duration gamePickDelay = Duration(milliseconds: 900);
  static const Duration coinFlipDuration = Duration(milliseconds: 1400);
}
