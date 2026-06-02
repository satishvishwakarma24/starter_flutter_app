import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/src/views/home_screen.dart';
import '/src/views/settings.dart';
import '../../src/widgets/main_nav_bar.dart';
import 'routes_name.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RoutesName.homeScreen,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => _AppShell(
        navigationShell: navigationShell,
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutesName.homeScreen,
              name: RoutesName.homeRouteName,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutesName.settingsScreen,
              name: RoutesName.settingsRouteName,
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class _AppShell extends StatelessWidget {
  const _AppShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: MainNavBarWidget(  
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
