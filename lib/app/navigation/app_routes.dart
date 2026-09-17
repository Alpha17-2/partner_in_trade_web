import 'package:flutter/material.dart';

class AppRoute {
  const AppRoute({
    required this.path,
    required this.label,
    required this.icon,
  });

  final String path;
  final String label;
  final IconData icon;
}

abstract final class AppRoutes {
  static const dashboard = '/dashboard';
  static const trades = '/trades';
  static const analytics = '/analytics';
  static const strategies = '/strategies';
  static const journal = '/journal';
  static const calendar = '/calendar';
  static const settings = '/settings';

  static String journalDate(String yyyyMmDd) => '$journal/$yyyyMmDd';

  static const List<AppRoute> primary = [
    AppRoute(
      path: dashboard,
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
    ),
    AppRoute(
      path: trades,
      label: 'Trades',
      icon: Icons.receipt_long_outlined,
    ),
    AppRoute(
      path: analytics,
      label: 'Analytics',
      icon: Icons.insights_outlined,
    ),
    AppRoute(
      path: strategies,
      label: 'Strategies',
      icon: Icons.auto_graph_outlined,
    ),
    AppRoute(
      path: journal,
      label: 'Journal',
      icon: Icons.menu_book_outlined,
    ),
    AppRoute(
      path: calendar,
      label: 'Calendar',
      icon: Icons.calendar_month_outlined,
    ),
  ];

  static const AppRoute settingsRoute = AppRoute(
    path: settings,
    label: 'Settings',
    icon: Icons.settings_outlined,
  );

  static const List<AppRoute> all = [...primary, settingsRoute];

  static bool matches(String currentPath, String routePath) {
    return currentPath == routePath ||
        currentPath.startsWith('$routePath/');
  }

  static String? labelForPath(String path) {
    AppRoute? best;
    for (final route in all) {
      if (matches(path, route.path)) {
        if (best == null || route.path.length > best.path.length) {
          best = route;
        }
      }
    }
    return best?.label;
  }
}
