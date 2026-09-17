enum MetricTrend { up, down, neutral }

class MetricComparison {
  const MetricComparison({
    required this.label,
    this.trend = MetricTrend.neutral,
  });

  final String label;
  final MetricTrend trend;
}

class EquityPoint {
  const EquityPoint({
    required this.index,
    required this.equity,
    required this.date,
  });

  final int index;
  final double equity;
  final DateTime date;
}

class SymbolPerformance {
  const SymbolPerformance({
    required this.symbol,
    required this.trades,
    required this.winRate,
    required this.netPnl,
  });

  final String symbol;
  final int trades;
  final double winRate;
  final double netPnl;
}

class StrategyPerformance {
  const StrategyPerformance({
    required this.strategy,
    required this.trades,
    required this.winRate,
    required this.netPnl,
  });

  final String strategy;
  final int trades;
  final double winRate;
  final double netPnl;
}

class DashboardSummary {
  const DashboardSummary({
    required this.netPnl,
    required this.winRate,
    required this.profitFactor,
    required this.averageR,
    required this.maxDrawdown,
    required this.tradeCount,
    required this.netPnlComparison,
    required this.winRateComparison,
    required this.profitFactorComparison,
    required this.averageRComparison,
    required this.maxDrawdownComparison,
    required this.tradeCountComparison,
  });

  final double netPnl;
  final double winRate;
  final double profitFactor;
  final double averageR;
  final double maxDrawdown;
  final int tradeCount;
  final MetricComparison netPnlComparison;
  final MetricComparison winRateComparison;
  final MetricComparison profitFactorComparison;
  final MetricComparison averageRComparison;
  final MetricComparison maxDrawdownComparison;
  final MetricComparison tradeCountComparison;
}

enum TradeSide { long, short }

enum TradeStatus { open, closed, cancelled }

class MockTrade {
  const MockTrade({
    required this.id,
    required this.date,
    required this.symbol,
    required this.side,
    required this.strategy,
    required this.entry,
    required this.exit,
    required this.pnl,
    required this.rMultiple,
    required this.status,
  });

  final String id;
  final DateTime date;
  final String symbol;
  final TradeSide side;
  final String strategy;
  final double entry;
  final double? exit;
  final double pnl;
  final double rMultiple;
  final TradeStatus status;
}

class WinLossDistribution {
  const WinLossDistribution({
    required this.wins,
    required this.losses,
    this.breakeven = 0,
  });

  final int wins;
  final int losses;
  final int breakeven;

  int get total => wins + losses + breakeven;

  double get winRate => total == 0 ? 0 : (wins / total) * 100;
}
