import '../../../models/journal_trade.dart';
import 'metric_value.dart';

class EquityCurvePoint {
  const EquityCurvePoint({
    required this.exitTime,
    required this.equity,
    required this.tradeNetPnl,
    required this.peakEquity,
    required this.drawdown,
    required this.drawdownPercent,
  });

  final DateTime exitTime;
  final double equity;
  final double tradeNetPnl;
  final double peakEquity;
  final double drawdown;
  final double drawdownPercent;
}

class TradeStatistics {
  const TradeStatistics({
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.breakevenTrades,
    required this.winRate,
    required this.lossRate,
    required this.grossProfitGross,
    required this.grossLossGross,
    required this.netPnl,
    required this.averageTradeNetPnl,
    required this.averageWinNet,
    required this.averageLossNet,
    required this.largestWinNet,
    required this.largestLossNet,
    required this.totalFees,
    required this.totalFunding,
    required this.totalGrossPnl,
    required this.averageHoldingTime,
    required this.medianHoldingTime,
    required this.shortestTrade,
    required this.longestTrade,
  });

  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final int breakevenTrades;
  final MetricValue<double> winRate;
  final MetricValue<double> lossRate;
  final MetricValue<double> grossProfitGross;
  final MetricValue<double> grossLossGross;
  final MetricValue<double> netPnl;
  final MetricValue<double> averageTradeNetPnl;
  final MetricValue<double> averageWinNet;
  final MetricValue<double> averageLossNet;
  final MetricValue<double> largestWinNet;
  final MetricValue<double> largestLossNet;
  final MetricValue<double> totalFees;
  final MetricValue<double> totalFunding;
  final MetricValue<double> totalGrossPnl;
  final MetricValue<double> averageHoldingTime;
  final MetricValue<double> medianHoldingTime;
  final MetricValue<double> shortestTrade;
  final MetricValue<double> longestTrade;
}

class DrawdownStats {
  const DrawdownStats({
    required this.maxDrawdown,
    required this.maxDrawdownPercent,
    required this.currentDrawdown,
    required this.averageDrawdown,
    required this.longestDrawdownPeriod,
  });

  final MetricValue<double> maxDrawdown;
  final MetricValue<double> maxDrawdownPercent;
  final MetricValue<double> currentDrawdown;
  final MetricValue<double> averageDrawdown;
  final Duration? longestDrawdownPeriod;
}

class StreakStats {
  const StreakStats({
    required this.currentWinStreak,
    required this.currentLossStreak,
    required this.longestWinStreak,
    required this.longestLossStreak,
  });

  final int currentWinStreak;
  final int currentLossStreak;
  final int longestWinStreak;
  final int longestLossStreak;
}

class SymbolPerformanceRow {
  const SymbolPerformanceRow({
    required this.symbol,
    required this.trades,
    required this.winRate,
    required this.netPnl,
    required this.averageR,
  });

  final String symbol;
  final int trades;
  final MetricValue<double> winRate;
  final MetricValue<double> netPnl;
  final MetricValue<double> averageR;
}

class SidePerformanceRow {
  const SidePerformanceRow({
    required this.side,
    required this.trades,
    required this.winRate,
    required this.netPnl,
    required this.profitFactor,
    required this.averageR,
  });

  final JournalTradeSide side;
  final int trades;
  final MetricValue<double> winRate;
  final MetricValue<double> netPnl;
  final MetricValue<double> profitFactor;
  final MetricValue<double> averageR;
}

class PeriodPerformanceRow {
  const PeriodPerformanceRow({
    required this.periodStart,
    required this.label,
    required this.trades,
    required this.netPnl,
    required this.winRate,
    required this.averageR,
  });

  final DateTime periodStart;
  final String label;
  final int trades;
  final MetricValue<double> netPnl;
  final MetricValue<double> winRate;
  final MetricValue<double> averageR;
}

class DistributionBin {
  const DistributionBin({
    required this.label,
    required this.count,
    required this.midValue,
  });

  final String label;
  final int count;
  final double midValue;
}

enum DistributionKind { rMultiple, netPnl }

class PerformanceSnapshot {
  const PerformanceSnapshot({
    required this.hasCompletedTrades,
    required this.statistics,
    required this.profitFactor,
    required this.expectancy,
    required this.averageR,
    required this.medianR,
    required this.recoveryFactor,
    required this.equityCurve,
    required this.drawdown,
    required this.streaks,
    required this.bySymbol,
    required this.longStats,
    required this.shortStats,
    required this.dailyPerformance,
    required this.weeklyPerformance,
    required this.distributionKind,
    required this.distribution,
  });

  final bool hasCompletedTrades;
  final TradeStatistics statistics;
  final MetricValue<double> profitFactor;
  final MetricValue<double> expectancy;
  final MetricValue<double> averageR;
  final MetricValue<double> medianR;
  final MetricValue<double> recoveryFactor;
  final List<EquityCurvePoint> equityCurve;
  final DrawdownStats drawdown;
  final StreakStats streaks;
  final List<SymbolPerformanceRow> bySymbol;
  final SidePerformanceRow longStats;
  final SidePerformanceRow shortStats;
  final List<PeriodPerformanceRow> dailyPerformance;
  final List<PeriodPerformanceRow> weeklyPerformance;
  final DistributionKind distributionKind;
  final List<DistributionBin> distribution;

  static final MetricValue<double> _na = MetricValue.of(null);

  static PerformanceSnapshot empty() {
    final na = _na;
    return PerformanceSnapshot(
      hasCompletedTrades: false,
      statistics: TradeStatistics(
        totalTrades: 0,
        winningTrades: 0,
        losingTrades: 0,
        breakevenTrades: 0,
        winRate: na,
        lossRate: na,
        grossProfitGross: na,
        grossLossGross: na,
        netPnl: na,
        averageTradeNetPnl: na,
        averageWinNet: na,
        averageLossNet: na,
        largestWinNet: na,
        largestLossNet: na,
        totalFees: na,
        totalFunding: na,
        totalGrossPnl: na,
        averageHoldingTime: na,
        medianHoldingTime: na,
        shortestTrade: na,
        longestTrade: na,
      ),
      profitFactor: na,
      expectancy: na,
      averageR: na,
      medianR: na,
      recoveryFactor: na,
      equityCurve: const [],
      drawdown: DrawdownStats(
        maxDrawdown: na,
        maxDrawdownPercent: na,
        currentDrawdown: na,
        averageDrawdown: na,
        longestDrawdownPeriod: null,
      ),
      streaks: const StreakStats(
        currentWinStreak: 0,
        currentLossStreak: 0,
        longestWinStreak: 0,
        longestLossStreak: 0,
      ),
      bySymbol: const [],
      longStats: SidePerformanceRow(
        side: JournalTradeSide.long,
        trades: 0,
        winRate: na,
        netPnl: na,
        profitFactor: na,
        averageR: na,
      ),
      shortStats: SidePerformanceRow(
        side: JournalTradeSide.short,
        trades: 0,
        winRate: na,
        netPnl: na,
        profitFactor: na,
        averageR: na,
      ),
      dailyPerformance: const [],
      weeklyPerformance: const [],
      distributionKind: DistributionKind.netPnl,
      distribution: const [],
    );
  }
}
