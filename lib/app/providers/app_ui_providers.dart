import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DeltaConnectionStatus { notConnected, connected, error }

enum DashboardDateRangePreset { last7Days, last30Days, last90Days }

extension DashboardDateRangePresetLabel on DashboardDateRangePreset {
  String get label {
    switch (this) {
      case DashboardDateRangePreset.last7Days:
        return 'Last 7 days';
      case DashboardDateRangePreset.last30Days:
        return 'Last 30 days';
      case DashboardDateRangePreset.last90Days:
        return 'Last 90 days';
    }
  }

  int get days {
    switch (this) {
      case DashboardDateRangePreset.last7Days:
        return 7;
      case DashboardDateRangePreset.last30Days:
        return 30;
      case DashboardDateRangePreset.last90Days:
        return 90;
    }
  }
}

final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);

final dashboardDateRangeProvider = StateProvider<DashboardDateRangePreset>(
  (ref) => DashboardDateRangePreset.last30Days,
);
