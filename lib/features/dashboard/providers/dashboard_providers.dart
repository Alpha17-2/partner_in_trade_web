import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_ui_providers.dart';
import '../mock/dashboard_mock_data.dart';
import '../mock/dashboard_mock_models.dart';

final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  return DashboardMockData.summary;
});

final equityCurveProvider = Provider<List<EquityPoint>>((ref) {
  final range = ref.watch(dashboardDateRangeProvider);
  return DashboardMockData.equityCurve(dayCount: range.days);
});

final symbolPerformanceProvider = Provider<List<SymbolPerformance>>((ref) {
  return DashboardMockData.bySymbol;
});

final strategyPerformanceProvider = Provider<List<StrategyPerformance>>((ref) {
  return DashboardMockData.byStrategy;
});

final winLossProvider = Provider<WinLossDistribution>((ref) {
  return DashboardMockData.winLoss;
});

final recentTradesProvider = Provider<List<MockTrade>>((ref) {
  return DashboardMockData.recentTrades;
});
