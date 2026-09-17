import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_ui_providers.dart';
import '../../../models/journal_trade.dart';
import '../../trades/providers/trades_providers.dart';
import '../application/analytics_trade_filter.dart';
import '../application/trade_analytics_service.dart';
import '../domain/analytics_date_range.dart';
import '../domain/analytics_filter.dart';
import '../domain/performance_snapshot.dart';

final tradeAnalyticsServiceProvider = Provider<TradeAnalyticsService>(
  (ref) => TradeAnalyticsService(),
);

final analyticsInitialEquityProvider = StateProvider<double>((ref) => 0);

final analyticsFilterProvider = StateProvider<AnalyticsFilter>((ref) {
  return const AnalyticsFilter(
    dateRange: AnalyticsDateRange(preset: AnalyticsDatePreset.last30Days),
  );
});

/// Maps dashboard header presets to analytics date range.
void syncDashboardPresetToAnalytics(WidgetRef ref, DashboardDateRangePreset preset) {
  final analyticsPreset = switch (preset) {
    DashboardDateRangePreset.last7Days => AnalyticsDatePreset.last7Days,
    DashboardDateRangePreset.last30Days => AnalyticsDatePreset.last30Days,
    DashboardDateRangePreset.last90Days => AnalyticsDatePreset.last90Days,
  };
  ref.read(analyticsFilterProvider.notifier).state = AnalyticsFilter(
    dateRange: AnalyticsDateRange(preset: analyticsPreset),
  );
}

final completedTradesForAnalyticsProvider = Provider<List<JournalTrade>>((ref) {
  final trades = ref.watch(journalTradesProvider).valueOrNull ?? [];
  final filter = ref.watch(analyticsFilterProvider);
  return sortByExitTime(applyAnalyticsFilter(trades, filter));
});

final performanceSnapshotProvider = Provider<PerformanceSnapshot>((ref) {
  ref.watch(journalTradesRevisionProvider);
  final tradesAsync = ref.watch(journalTradesProvider);
  final filter = ref.watch(analyticsFilterProvider);
  final initialEquity = ref.watch(analyticsInitialEquityProvider);
  final service = ref.watch(tradeAnalyticsServiceProvider);

  return tradesAsync.when(
    data: (trades) => service.compute(trades, filter, initialEquity: initialEquity),
    loading: () => PerformanceSnapshot.empty(),
    error: (_, _) => PerformanceSnapshot.empty(),
  );
});

final analyticsEquityCurveProvider = Provider<List<EquityCurvePoint>>((ref) {
  return ref.watch(performanceSnapshotProvider).equityCurve;
});

final recentClosedTradesProvider = Provider<List<JournalTrade>>((ref) {
  final trades = ref.watch(journalTradesProvider).valueOrNull ?? [];
  final closed = trades
      .where(
        (t) => t.status == JournalTradeStatus.closed && t.exitTime != null,
      )
      .toList();
  closed.sort((a, b) => b.exitTime!.compareTo(a.exitTime!));
  return closed.take(10).toList();
});
