import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:starter_flutter_app/src/home_screen.dart';
import '/core/const.dart';
import 'routes_name.dart';

class Routes {
  static Route<dynamic>? buildRoute(RouteSettings settings) {
    final Widget? page = switch (settings.name) {
      RoutesName.homeScreen => const HomeScreen(),

      _ => null,
    };

    if (page == null) return null;

    // Shared-axis (horizontal slide) transition between all screens.
    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: AppAnimations.normal,
      reverseTransitionDuration: AppAnimations.fast,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
    );
  }
}
