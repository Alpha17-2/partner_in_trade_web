import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/analytics/presentation/analytics_page.dart';
import '../features/calendar/presentation/calendar_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/journal/presentation/daily_journal_page.dart';
import '../features/journal/presentation/journal_calendar_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/strategies/presentation/strategies_page.dart';
import '../features/trades/presentation/trades_page.dart';
import '../shared/widgets/app_shell.dart';
import 'navigation/app_routes.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) {
      if (state.uri.path == '/') {
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.trades,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TradesPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.analytics,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AnalyticsPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.strategies,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StrategiesPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.journal,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: JournalCalendarPage(),
            ),
          ),
          GoRoute(
            path: '${AppRoutes.journal}/:date',
            pageBuilder: (context, state) {
              final date = state.pathParameters['date'] ?? '';
              return NoTransitionPage(
                child: DailyJournalPage(dateKey: date),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.calendar,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CalendarPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsPage(),
            ),
          ),
        ],
      ),
    ],
  );
}
