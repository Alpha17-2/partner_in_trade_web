// MOCK DATA — replace with real trade import when Delta sync is implemented.

import 'dashboard_mock_models.dart';

abstract final class DashboardMockData {
  static const DashboardSummary summary = DashboardSummary(
    netPnl: 4287.65,
    winRate: 58.4,
    profitFactor: 1.82,
    averageR: 0.74,
    maxDrawdown: -1240.30,
    tradeCount: 142,
    netPnlComparison: MetricComparison(
      label: '+12.4% vs prior period',
      trend: MetricTrend.up,
    ),
    winRateComparison: MetricComparison(
      label: '+3.2 pts vs prior period',
      trend: MetricTrend.up,
    ),
    profitFactorComparison: MetricComparison(
      label: '+0.18 vs prior period',
      trend: MetricTrend.up,
    ),
    averageRComparison: MetricComparison(
      label: '+0.12R vs prior period',
      trend: MetricTrend.up,
    ),
    maxDrawdownComparison: MetricComparison(
      label: 'Improved vs prior period',
      trend: MetricTrend.up,
    ),
    tradeCountComparison: MetricComparison(
      label: '+18 vs prior period',
      trend: MetricTrend.neutral,
    ),
  );

  static List<EquityPoint> equityCurve({int dayCount = 30}) {
    const start = 10000.0;
    final deltas = [
      120, 85, -40, 210, 95, -120, 180, 60, -90, 150,
      220, -70, 130, 45, -55, 190, 110, -80, 165, 90,
      -100, 240, 75, -60, 200, 130, -45, 175, 55, -95,
      140, -30, 88, 160, -110, 95, 70, -50, 185, 42,
      -75, 210, 55, -40, 120, 90, -85, 175, 60, -95,
      130, 45, -60, 200, 80, -70, 150, 95, -55, 165,
      110, -90, 220, 75, -45, 190, 85, -100, 140, 65,
      -80, 175, 50, -65, 155, 90, -55, 200, 70, -120,
      180, 95, -40, 165, 110, -75, 145, 60, -90, 210,
    ];
    final count = dayCount.clamp(7, deltas.length);
    final endDate = DateTime.now();
    var equity = start;
    final points = <EquityPoint>[];
    for (var i = 0; i < count; i++) {
      equity += deltas[i];
      final date = endDate.subtract(Duration(days: count - 1 - i));
      points.add(
        EquityPoint(
          index: i,
          equity: equity,
          date: DateTime(date.year, date.month, date.day),
        ),
      );
    }
    return points;
  }

  static const List<SymbolPerformance> bySymbol = [
    SymbolPerformance(symbol: 'BTCUSD', trades: 48, winRate: 62.5, netPnl: 2140.20),
    SymbolPerformance(symbol: 'ETHUSD', trades: 36, winRate: 55.6, netPnl: 980.45),
    SymbolPerformance(symbol: 'SOLUSD', trades: 28, winRate: 53.6, netPnl: 620.00),
    SymbolPerformance(symbol: 'XRPUSD', trades: 18, winRate: 50.0, netPnl: -120.50),
    SymbolPerformance(symbol: 'BNBUSD', trades: 12, winRate: 58.3, netPnl: 667.50),
  ];

  static const List<StrategyPerformance> byStrategy = [
    StrategyPerformance(
      strategy: 'Breakout Momentum',
      trades: 52,
      winRate: 61.5,
      netPnl: 1890.00,
    ),
    StrategyPerformance(
      strategy: 'Mean Reversion',
      trades: 44,
      winRate: 54.5,
      netPnl: 1120.35,
    ),
    StrategyPerformance(
      strategy: 'Trend Follow',
      trades: 30,
      winRate: 56.7,
      netPnl: 890.30,
    ),
    StrategyPerformance(
      strategy: 'Scalp',
      trades: 16,
      winRate: 43.8,
      netPnl: 387.00,
    ),
  ];

  static const WinLossDistribution winLoss = WinLossDistribution(
    wins: 83,
    losses: 56,
    breakeven: 3,
  );

  static final List<MockTrade> recentTrades = [
    MockTrade(
      id: 't1',
      date: DateTime(2026, 9, 17, 14, 32),
      symbol: 'BTCUSD',
      side: TradeSide.long,
      strategy: 'Breakout Momentum',
      entry: 64250.5,
      exit: 64810.0,
      pnl: 559.50,
      rMultiple: 1.85,
      status: TradeStatus.closed,
    ),
    MockTrade(
      id: 't2',
      date: DateTime(2026, 9, 17, 11, 05),
      symbol: 'ETHUSD',
      side: TradeSide.short,
      strategy: 'Mean Reversion',
      entry: 3420.25,
      exit: 3388.0,
      pnl: 322.25,
      rMultiple: 1.12,
      status: TradeStatus.closed,
    ),
    MockTrade(
      id: 't3',
      date: DateTime(2026, 9, 16, 16, 48),
      symbol: 'SOLUSD',
      side: TradeSide.long,
      strategy: 'Trend Follow',
      entry: 148.62,
      exit: 146.90,
      pnl: -172.00,
      rMultiple: -0.95,
      status: TradeStatus.closed,
    ),
    MockTrade(
      id: 't4',
      date: DateTime(2026, 9, 16, 10, 15),
      symbol: 'BTCUSD',
      side: TradeSide.short,
      strategy: 'Scalp',
      entry: 63980.0,
      exit: 64120.0,
      pnl: -140.00,
      rMultiple: -0.72,
      status: TradeStatus.closed,
    ),
    MockTrade(
      id: 't5',
      date: DateTime(2026, 9, 15, 15, 22),
      symbol: 'BNBUSD',
      side: TradeSide.long,
      strategy: 'Breakout Momentum',
      entry: 582.40,
      exit: 591.15,
      pnl: 87.50,
      rMultiple: 0.68,
      status: TradeStatus.closed,
    ),
    MockTrade(
      id: 't6',
      date: DateTime(2026, 9, 15, 9, 40),
      symbol: 'XRPUSD',
      side: TradeSide.long,
      strategy: 'Mean Reversion',
      entry: 0.5821,
      exit: 0.5894,
      pnl: 73.00,
      rMultiple: 0.55,
      status: TradeStatus.closed,
    ),
    MockTrade(
      id: 't7',
      date: DateTime(2026, 9, 14, 17, 05),
      symbol: 'ETHUSD',
      side: TradeSide.long,
      strategy: 'Trend Follow',
      entry: 3355.0,
      exit: 3412.5,
      pnl: 575.00,
      rMultiple: 2.1,
      status: TradeStatus.closed,
    ),
    MockTrade(
      id: 't8',
      date: DateTime(2026, 9, 14, 12, 18),
      symbol: 'BTCUSD',
      side: TradeSide.long,
      strategy: 'Breakout Momentum',
      entry: 62840.0,
      exit: null,
      pnl: 210.00,
      rMultiple: 0.45,
      status: TradeStatus.open,
    ),
    MockTrade(
      id: 't9',
      date: DateTime(2026, 9, 13, 14, 55),
      symbol: 'SOLUSD',
      side: TradeSide.short,
      strategy: 'Scalp',
      entry: 152.30,
      exit: 150.85,
      pnl: 145.00,
      rMultiple: 0.92,
      status: TradeStatus.closed,
    ),
    MockTrade(
      id: 't10',
      date: DateTime(2026, 9, 12, 11, 30),
      symbol: 'ETHUSD',
      side: TradeSide.short,
      strategy: 'Mean Reversion',
      entry: 3488.0,
      exit: 3510.0,
      pnl: -220.00,
      rMultiple: -1.15,
      status: TradeStatus.closed,
    ),
  ];
}
