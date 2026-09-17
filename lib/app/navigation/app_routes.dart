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
  static const calendar = '/calendar';
  static const settings = '/settings';

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
}
