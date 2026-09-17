import 'package:flutter_test/flutter_test.dart';
import 'package:partner_in_trade_web/features/analytics/application/trade_analytics_service.dart';
import 'package:partner_in_trade_web/features/analytics/domain/analytics_date_range.dart';
import 'package:partner_in_trade_web/features/analytics/domain/analytics_filter.dart';
import 'package:partner_in_trade_web/features/analytics/domain/metric_value.dart';
import 'package:partner_in_trade_web/features/analytics/domain/performance_snapshot.dart';
import 'package:partner_in_trade_web/models/journal_trade.dart';

const _filterAll = AnalyticsFilter(
  dateRange: AnalyticsDateRange(preset: AnalyticsDatePreset.allTime),
);

JournalTrade closedTrade({
  required String id,
  required DateTime exitTime,
  double grossPnl = 100,
  double netPnl = 90,
  double fees = 10,
  double funding = 0,
  JournalTradeSide side = JournalTradeSide.long,
  String symbol = 'BTCUSD',
  double? rMultiple,
}) {
  return JournalTrade(
    id: id,
    productId: 1,
    symbol: symbol,
    side: side,
    entryTime: exitTime.subtract(const Duration(hours: 1)),
    exitTime: exitTime,
    entryPrice: 100,
    exitPrice: 110,
    quantity: 1,
    averageEntryPrice: 100,
    averageExitPrice: 110,
    grossPnl: grossPnl,
    fees: fees,
    funding: funding,
    netPnl: netPnl,
    orderIds: const [],
    fillIds: const ['f'],
    status: JournalTradeStatus.closed,
    rMultiple: rMultiple,
  );
}

void assertNoBadDoubles(PerformanceSnapshot snap) {
  void check(MetricValue<double> m) {
    if (m.hasValue) {
      expect(m.value!.isNaN, isFalse);
      expect(m.value!.isInfinite, isFalse);
    }
  }

  check(snap.profitFactor);
  check(snap.expectancy);
  check(snap.averageR);
  check(snap.statistics.netPnl);
  check(snap.statistics.winRate);
  check(snap.drawdown.maxDrawdown);
  for (final p in snap.equityCurve) {
    expect(p.equity.isNaN, isFalse);
    expect(p.drawdown.isNaN, isFalse);
  }
}

void main() {
  final service = TradeAnalyticsService();
  final now = DateTime(2025, 6, 15, 12);

  test('empty trades returns empty snapshot', () {
    final snap = service.compute([], _filterAll, initialEquity: 0, now: now);
    expect(snap.hasCompletedTrades, isFalse);
    expect(snap.profitFactor.hasValue, isFalse);
  });

  test('win rate and net pnl', () {
    final trades = [
      closedTrade(
        id: '1',
        exitTime: DateTime(2025, 6, 1),
        grossPnl: 100,
        netPnl: 90,
      ),
      closedTrade(
        id: '2',
        exitTime: DateTime(2025, 6, 2),
        grossPnl: -50,
        netPnl: -55,
        fees: 5,
      ),
    ];
    final snap = service.compute(trades, _filterAll, initialEquity: 0, now: now);
    expect(snap.statistics.totalTrades, 2);
    expect(snap.statistics.winningTrades, 1);
    expect(snap.statistics.losingTrades, 1);
    expect(snap.statistics.winRate.value, closeTo(50, 0.01));
    expect(snap.statistics.netPnl.value, closeTo(35, 0.01));
    assertNoBadDoubles(snap);
  });

  test('profit factor uses gross pnl on losses', () {
    final trades = [
      closedTrade(
        id: '1',
        exitTime: DateTime(2025, 6, 1),
        grossPnl: 200,
        netPnl: 200,
        fees: 0,
      ),
      closedTrade(
        id: '2',
        exitTime: DateTime(2025, 6, 2),
        grossPnl: -100,
        netPnl: -100,
        fees: 0,
      ),
    ];
    final snap = service.compute(trades, _filterAll, initialEquity: 0, now: now);
    expect(snap.profitFactor.value, closeTo(2, 0.001));
  });

  test('profit factor null when no gross losses', () {
    final trades = [
      closedTrade(
        id: '1',
        exitTime: DateTime(2025, 6, 1),
        grossPnl: 50,
        netPnl: 50,
      ),
    ];
    final snap = service.compute(trades, _filterAll, initialEquity: 0, now: now);
    expect(snap.profitFactor.hasValue, isFalse);
  });

  test('expectancy on net', () {
    final trades = [
      closedTrade(
        id: '1',
        exitTime: DateTime(2025, 6, 1),
        grossPnl: 100,
        netPnl: 100,
      ),
      closedTrade(
        id: '2',
        exitTime: DateTime(2025, 6, 2),
        grossPnl: -100,
        netPnl: -100,
      ),
    ];
    final snap = service.compute(trades, _filterAll, initialEquity: 0, now: now);
    expect(snap.expectancy.value, closeTo(0, 0.001));
  });

  test('equity curve and max drawdown', () {
    final trades = [
      closedTrade(
        id: '1',
        exitTime: DateTime(2025, 6, 1),
        netPnl: 100,
        grossPnl: 100,
      ),
      closedTrade(
        id: '2',
        exitTime: DateTime(2025, 6, 2),
        netPnl: -150,
        grossPnl: -150,
      ),
      closedTrade(
        id: '3',
        exitTime: DateTime(2025, 6, 3),
        netPnl: 50,
        grossPnl: 50,
      ),
    ];
    final snap = service.compute(trades, _filterAll, initialEquity: 1000, now: now);
    expect(snap.equityCurve.length, 3);
    expect(snap.equityCurve.last.equity, closeTo(1000, 0.01));
    expect(snap.drawdown.maxDrawdown.value, closeTo(150, 0.01));
  });

  test('streaks', () {
    final trades = [
      closedTrade(id: '1', exitTime: DateTime(2025, 6, 1), netPnl: 10, grossPnl: 10),
      closedTrade(id: '2', exitTime: DateTime(2025, 6, 2), netPnl: 10, grossPnl: 10),
      closedTrade(id: '3', exitTime: DateTime(2025, 6, 3), netPnl: -5, grossPnl: -5),
    ];
    final snap = service.compute(trades, _filterAll, initialEquity: 0, now: now);
    expect(snap.streaks.longestWinStreak, 2);
    expect(snap.streaks.currentLossStreak, 1);
  });

  test('date filter excludes by exit time', () {
    final trades = [
      closedTrade(id: '1', exitTime: DateTime(2025, 5, 1), netPnl: 10, grossPnl: 10),
      closedTrade(id: '2', exitTime: DateTime(2025, 6, 10), netPnl: 20, grossPnl: 20),
    ];
    final filter = AnalyticsFilter(
      dateRange: AnalyticsDateRange(
        preset: AnalyticsDatePreset.custom,
        customStart: DateTime(2025, 6, 1),
        customEnd: DateTime(2025, 6, 30, 23, 59, 59),
      ),
    );
    final snap = service.compute(trades, filter, initialEquity: 0, now: now);
    expect(snap.statistics.totalTrades, 1);
    expect(snap.statistics.netPnl.value, closeTo(20, 0.01));
  });

  test('symbol and side filters', () {
    final trades = [
      closedTrade(
        id: '1',
        exitTime: DateTime(2025, 6, 1),
        symbol: 'BTCUSD',
        side: JournalTradeSide.long,
        netPnl: 10,
        grossPnl: 10,
      ),
      closedTrade(
        id: '2',
        exitTime: DateTime(2025, 6, 2),
        symbol: 'ETHUSD',
        side: JournalTradeSide.short,
        netPnl: 5,
        grossPnl: 5,
      ),
    ];
    final bySymbol = AnalyticsFilter(
      dateRange: _filterAll.dateRange,
      symbol: 'ETHUSD',
    );
    final snap = service.compute(trades, bySymbol, initialEquity: 0, now: now);
    expect(snap.statistics.totalTrades, 1);

    final longOnly = AnalyticsFilter(
      dateRange: _filterAll.dateRange,
      side: AnalyticsSideFilter.long,
    );
    final snapLong = service.compute(trades, longOnly, initialEquity: 0, now: now);
    expect(snapLong.longStats.trades, 1);
    expect(snapLong.shortStats.trades, 0);
  });

  test('open trades excluded', () {
    final open = JournalTrade(
      id: 'o',
      productId: 1,
      symbol: 'BTCUSD',
      side: JournalTradeSide.long,
      entryTime: DateTime(2025, 6, 1),
      entryPrice: 100,
      quantity: 1,
      averageEntryPrice: 100,
      grossPnl: 0,
      fees: 0,
      funding: 0,
      netPnl: 0,
      orderIds: const [],
      fillIds: const [],
      status: JournalTradeStatus.open,
    );
    final snap = service.compute([open], _filterAll, initialEquity: 0, now: now);
    expect(snap.hasCompletedTrades, isFalse);
  });

  test('average R ignores missing R', () {
    final trades = [
      closedTrade(
        id: '1',
        exitTime: DateTime(2025, 6, 1),
        rMultiple: 2,
        netPnl: 10,
        grossPnl: 10,
      ),
      closedTrade(
        id: '2',
        exitTime: DateTime(2025, 6, 2),
        rMultiple: null,
        netPnl: -5,
        grossPnl: -5,
      ),
    ];
    final snap = service.compute(trades, _filterAll, initialEquity: 0, now: now);
    expect(snap.averageR.value, closeTo(2, 0.001));
  });

  test('breakeven trade by net epsilon', () {
    final trades = [
      closedTrade(
        id: '1',
        exitTime: DateTime(2025, 6, 1),
        grossPnl: 1,
        netPnl: 0,
        fees: 0,
      ),
    ];
    final snap = service.compute(trades, _filterAll, initialEquity: 0, now: now);
    expect(snap.statistics.breakevenTrades, 1);
    expect(snap.statistics.winningTrades, 0);
    expect(snap.statistics.losingTrades, 0);
    assertNoBadDoubles(snap);
  });

  test('all losses profit factor and no nan', () {
    final trades = [
      closedTrade(
        id: '1',
        exitTime: DateTime(2025, 6, 1),
        grossPnl: -10,
        netPnl: -10,
      ),
      closedTrade(
        id: '2',
        exitTime: DateTime(2025, 6, 2),
        grossPnl: -20,
        netPnl: -20,
      ),
    ];
    final snap = service.compute(trades, _filterAll, initialEquity: 0, now: now);
    expect(snap.profitFactor.value, closeTo(0, 0.001));
    expect(snap.statistics.winRate.value, 0);
    assertNoBadDoubles(snap);
  });

  test('fees and funding totals', () {
    final trades = [
      closedTrade(
        id: '1',
        exitTime: DateTime(2025, 6, 1),
        fees: 3,
        funding: 1,
        grossPnl: 10,
        netPnl: 6,
      ),
    ];
    final snap = service.compute(trades, _filterAll, initialEquity: 0, now: now);
    expect(snap.statistics.totalFees.value, 3);
    expect(snap.statistics.totalFunding.value, 1);
    expect(snap.statistics.totalGrossPnl.value, 10);
  });
}
