import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/journal_trade.dart';
import '../../analytics/application/journal_trade_display_mapper.dart';
import '../../analytics/application/analytics_trade_filter.dart';
import '../../analytics/providers/analytics_providers.dart';
import '../../trades/providers/trades_providers.dart';
import '../mock/dashboard_mock_models.dart';

final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  ref.watch(analyticsFilterProvider);
  final snap = ref.watch(performanceSnapshotProvider);
  const neutral = MetricComparison(label: '—');

  if (!snap.hasCompletedTrades) {
    return DashboardSummary(
      netPnl: 0,
      winRate: 0,
      profitFactor: 0,
      averageR: 0,
      maxDrawdown: 0,
      tradeCount: 0,
      netPnlComparison: neutral,
      winRateComparison: neutral,
      profitFactorComparison: neutral,
      averageRComparison: neutral,
      maxDrawdownComparison: neutral,
      tradeCountComparison: neutral,
    );
  }

  final s = snap.statistics;
  return DashboardSummary(
    netPnl: s.netPnl.value ?? 0,
    winRate: s.winRate.value ?? 0,
    profitFactor: snap.profitFactor.value ?? 0,
    averageR: snap.averageR.value ?? 0,
    maxDrawdown: snap.drawdown.maxDrawdown.value ?? 0,
    tradeCount: s.totalTrades,
    netPnlComparison: neutral,
    winRateComparison: neutral,
    profitFactorComparison: neutral,
    averageRComparison: neutral,
    maxDrawdownComparison: neutral,
    tradeCountComparison: neutral,
  );
});

final dashboardCostSummaryProvider = Provider<({
  double fees,
  double funding,
  double grossPnl,
})>((ref) {
  final snap = ref.watch(performanceSnapshotProvider);
  if (!snap.hasCompletedTrades) {
    return (fees: 0, funding: 0, grossPnl: 0);
  }
  final s = snap.statistics;
  return (
    fees: s.totalFees.value ?? 0,
    funding: s.totalFunding.value ?? 0,
    grossPnl: s.totalGrossPnl.value ?? 0,
  );
});

final equityCurveProvider = Provider<List<EquityPoint>>((ref) {
  final snap = ref.watch(performanceSnapshotProvider);
  return snap.equityCurve
      .asMap()
      .entries
      .map(
        (e) => EquityPoint(
          index: e.key,
          equity: e.value.equity,
          date: e.value.exitTime,
        ),
      )
      .toList();
});

final symbolPerformanceProvider = Provider<List<SymbolPerformance>>((ref) {
  final snap = ref.watch(performanceSnapshotProvider);
  return snap.bySymbol
      .map(
        (r) => SymbolPerformance(
          symbol: r.symbol,
          trades: r.trades,
          winRate: r.winRate.value ?? 0,
          netPnl: r.netPnl.value ?? 0,
        ),
      )
      .toList();
});

final strategyPerformanceProvider = Provider<List<StrategyPerformance>>((ref) {
  final trades = ref.watch(journalTradesProvider).valueOrNull ?? [];
  final filter = ref.watch(analyticsFilterProvider);
  final filtered = applyAnalyticsFilter(trades, filter);
  if (filtered.isEmpty) return [];

  final map = <String, List<JournalTrade>>{};
  for (final t in filtered) {
    final st = t.strategy?.trim();
    if (st == null || st.isEmpty) continue;
    map.putIfAbsent(st, () => []).add(t);
  }
  return map.entries.map((e) {
    final list = e.value;
    final wins = list.where((t) => t.netPnl > 0).length;
    return StrategyPerformance(
      strategy: e.key,
      trades: list.length,
      winRate: list.isEmpty ? 0 : wins / list.length * 100,
      netPnl: list.fold<double>(0, (s, t) => s + t.netPnl),
    );
  }).toList();
});

final winLossProvider = Provider<WinLossDistribution>((ref) {
  final snap = ref.watch(performanceSnapshotProvider);
  return winLossFromSnapshot(snap);
});

final recentTradesProvider = Provider<List<MockTrade>>((ref) {
  return ref
      .watch(recentClosedTradesProvider)
      .map(journalTradeToMockTrade)
      .toList();
});
