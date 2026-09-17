import 'dart:math' as math;

import '../../../models/journal_trade.dart';
import '../domain/analytics_filter.dart';
import '../domain/metric_value.dart';
import '../domain/performance_snapshot.dart';
import 'analytics_trade_filter.dart';

/// P&L semantics:
/// - [JournalTrade.grossPnl]: fee-exclusive trading P&L (profit factor, gross buckets).
/// - [JournalTrade.netPnl]: net after fees/funding (equity curve, expectancy in currency).
/// - [JournalTrade.fees] / [funding]: reported separately.
class TradeAnalyticsService {
  static const breakevenEpsilon = 1e-9;
  static const minTradesForRDistribution = 5;

  PerformanceSnapshot compute(
    List<JournalTrade> allTrades,
    AnalyticsFilter filter, {
    required double initialEquity,
    DateTime? now,
  }) {
    final filtered = sortByExitTime(applyAnalyticsFilter(allTrades, filter, now: now));
    if (filtered.isEmpty) return PerformanceSnapshot.empty();

    final wins = <JournalTrade>[];
    final losses = <JournalTrade>[];
    final breakeven = <JournalTrade>[];

    for (final t in filtered) {
      if (t.netPnl > breakevenEpsilon) {
        wins.add(t);
      } else if (t.netPnl < -breakevenEpsilon) {
        losses.add(t);
      } else {
        breakeven.add(t);
      }
    }

    final total = filtered.length;
    final winRate = MetricValue.of(total > 0 ? wins.length / total * 100 : null);
    final lossRate = MetricValue.of(total > 0 ? losses.length / total * 100 : null);

    final grossProfitGross = MetricValue.of(
      wins.fold<double>(0, (s, t) => s + t.grossPnl),
    );
    final grossLossGross = MetricValue.of(
      losses.fold<double>(0, (s, t) => s + t.grossPnl),
    );

    final netPnlSum = filtered.fold<double>(0, (s, t) => s + t.netPnl);
    final feesSum = filtered.fold<double>(0, (s, t) => s + t.fees);
    final fundingSum = filtered.fold<double>(0, (s, t) => s + t.funding);
    final grossPnlSum = filtered.fold<double>(0, (s, t) => s + t.grossPnl);

    final profitFactor = _profitFactor(wins, losses);
    final expectancy = _expectancy(wins, losses, total);

    final rValues = filtered
        .map((t) => t.rMultiple)
        .whereType<double>()
        .where((r) => !r.isNaN && !r.isInfinite)
        .toList();

    final averageR = MetricValue.of(
      rValues.isEmpty ? null : rValues.reduce((a, b) => a + b) / rValues.length,
    );
    final medianR = MetricValue.of(_median(rValues));

    final equityCurve = _buildEquityCurve(filtered, initialEquity);
    final drawdown = _drawdownStats(equityCurve);
    final recoveryFactor = MetricValue.of(
      drawdown.maxDrawdown.hasValue && drawdown.maxDrawdown.value! > 0
          ? netPnlSum / drawdown.maxDrawdown.value!
          : null,
    );

    final durations = filtered
        .map((t) => t.duration?.inSeconds.toDouble())
        .whereType<double>()
        .toList();

    final stats = TradeStatistics(
      totalTrades: total,
      winningTrades: wins.length,
      losingTrades: losses.length,
      breakevenTrades: breakeven.length,
      winRate: winRate,
      lossRate: lossRate,
      grossProfitGross: grossProfitGross,
      grossLossGross: grossLossGross,
      netPnl: MetricValue.of(netPnlSum),
      averageTradeNetPnl: MetricValue.of(total > 0 ? netPnlSum / total : null),
      averageWinNet: MetricValue.of(
        wins.isEmpty
            ? null
            : wins.fold<double>(0, (s, t) => s + t.netPnl) / wins.length,
      ),
      averageLossNet: MetricValue.of(
        losses.isEmpty
            ? null
            : losses.fold<double>(0, (s, t) => s + t.netPnl) / losses.length,
      ),
      largestWinNet: MetricValue.of(
        wins.isEmpty
            ? null
            : wins.map((t) => t.netPnl).reduce(math.max),
      ),
      largestLossNet: MetricValue.of(
        losses.isEmpty
            ? null
            : losses.map((t) => t.netPnl).reduce(math.min),
      ),
      totalFees: MetricValue.of(feesSum),
      totalFunding: MetricValue.of(fundingSum),
      totalGrossPnl: MetricValue.of(grossPnlSum),
      averageHoldingTime: MetricValue.of(
        durations.isEmpty
            ? null
            : durations.reduce((a, b) => a + b) / durations.length,
      ),
      medianHoldingTime: MetricValue.of(_median(durations)),
      shortestTrade: MetricValue.of(
        durations.isEmpty ? null : durations.reduce(math.min),
      ),
      longestTrade: MetricValue.of(
        durations.isEmpty ? null : durations.reduce(math.max),
      ),
    );

    return PerformanceSnapshot(
      hasCompletedTrades: true,
      statistics: stats,
      profitFactor: profitFactor,
      expectancy: expectancy,
      averageR: averageR,
      medianR: medianR,
      recoveryFactor: recoveryFactor,
      equityCurve: equityCurve,
      drawdown: drawdown,
      streaks: _streaks(filtered),
      bySymbol: _bySymbol(filtered),
      longStats: _sideStats(filtered, JournalTradeSide.long),
      shortStats: _sideStats(filtered, JournalTradeSide.short),
      dailyPerformance: _periodStats(filtered, weekly: false),
      weeklyPerformance: _periodStats(filtered, weekly: true),
      distributionKind: rValues.length >= minTradesForRDistribution
          ? DistributionKind.rMultiple
          : DistributionKind.netPnl,
      distribution: rValues.length >= minTradesForRDistribution
          ? _histogramR(rValues)
          : _histogramNet(filtered.map((t) => t.netPnl).toList()),
    );
  }

  MetricValue<double> _profitFactor(
    List<JournalTrade> wins,
    List<JournalTrade> losses,
  ) {
    final gp = wins.fold<double>(0, (s, t) => s + t.grossPnl);
    final gl = losses.fold<double>(0, (s, t) => s + t.grossPnl);
    if (gl == 0) return MetricValue.of(null);
    final pf = gp / gl.abs();
    if (pf.isNaN || pf.isInfinite) return MetricValue.of(null);
    return MetricValue.of(pf);
  }

  /// Expectancy (currency, net): (winRate × avgWin) − (lossRate × avgLoss)
  /// with win/loss rates as fractions 0–1 and avg loss negative.
  MetricValue<double> _expectancy(
    List<JournalTrade> wins,
    List<JournalTrade> losses,
    int total,
  ) {
    if (total == 0) return MetricValue.of(null);
    final wr = wins.length / total;
    final lr = losses.length / total;
    final avgWin = wins.isEmpty
        ? 0.0
        : wins.fold<double>(0, (s, t) => s + t.netPnl) / wins.length;
    final avgLoss = losses.isEmpty
        ? 0.0
        : losses.fold<double>(0, (s, t) => s + t.netPnl) / losses.length;
    return MetricValue.of(wr * avgWin + lr * avgLoss);
  }

  List<EquityCurvePoint> _buildEquityCurve(
    List<JournalTrade> trades,
    double initialEquity,
  ) {
    var equity = initialEquity;
    var peak = initialEquity;
    final points = <EquityCurvePoint>[];

    for (final t in trades) {
      equity += t.netPnl;
      if (equity > peak) peak = equity;
      final dd = peak - equity;
      final ddPct = peak > 0 ? dd / peak * 100 : 0.0;
      points.add(
        EquityCurvePoint(
          exitTime: t.exitTime!,
          equity: equity,
          tradeNetPnl: t.netPnl,
          peakEquity: peak,
          drawdown: dd,
          drawdownPercent: ddPct,
        ),
      );
    }
    return points;
  }

  DrawdownStats _drawdownStats(List<EquityCurvePoint> curve) {
    if (curve.isEmpty) {
      final na = MetricValue.of(null);
      return DrawdownStats(
        maxDrawdown: na,
        maxDrawdownPercent: na,
        currentDrawdown: na,
        averageDrawdown: na,
        longestDrawdownPeriod: null,
      );
    }
    final dds = curve.map((p) => p.drawdown).toList();
    final ddPcts = curve.map((p) => p.drawdownPercent).toList();
    final maxDd = dds.reduce(math.max);
    final maxDdPct = ddPcts.reduce(math.max);
    final current = curve.last.drawdown;
    final avg = dds.reduce((a, b) => a + b) / dds.length;

    Duration? longest;
    DateTime? ddStart;
    for (final p in curve) {
      if (p.drawdown > breakevenEpsilon) {
        ddStart ??= p.exitTime;
      } else if (ddStart != null) {
        final dur = p.exitTime.difference(ddStart);
        if (longest == null || dur > longest) longest = dur;
        ddStart = null;
      }
    }

    return DrawdownStats(
      maxDrawdown: MetricValue.of(maxDd),
      maxDrawdownPercent: MetricValue.of(maxDdPct),
      currentDrawdown: MetricValue.of(current),
      averageDrawdown: MetricValue.of(avg),
      longestDrawdownPeriod: longest,
    );
  }

  StreakStats _streaks(List<JournalTrade> trades) {
    var curWin = 0;
    var curLoss = 0;
    var maxWin = 0;
    var maxLoss = 0;

    for (final t in trades) {
      if (t.netPnl > breakevenEpsilon) {
        curWin++;
        curLoss = 0;
        maxWin = math.max(maxWin, curWin);
      } else if (t.netPnl < -breakevenEpsilon) {
        curLoss++;
        curWin = 0;
        maxLoss = math.max(maxLoss, curLoss);
      } else {
        curWin = 0;
        curLoss = 0;
      }
    }

    return StreakStats(
      currentWinStreak: curWin,
      currentLossStreak: curLoss,
      longestWinStreak: maxWin,
      longestLossStreak: maxLoss,
    );
  }

  List<SymbolPerformanceRow> _bySymbol(List<JournalTrade> trades) {
    final map = <String, List<JournalTrade>>{};
    for (final t in trades) {
      map.putIfAbsent(t.symbol, () => []).add(t);
    }
    return map.entries.map((e) {
      final list = e.value;
      final wins = list.where((t) => t.netPnl > breakevenEpsilon).length;
      final r = list.map((t) => t.rMultiple).whereType<double>().toList();
      return SymbolPerformanceRow(
        symbol: e.key,
        trades: list.length,
        winRate: MetricValue.of(list.isEmpty ? null : wins / list.length * 100),
        netPnl: MetricValue.of(list.fold<double>(0, (s, t) => s + t.netPnl)),
        averageR: MetricValue.of(
          r.isEmpty ? null : r.reduce((a, b) => a + b) / r.length,
        ),
      );
    }).toList()
      ..sort(
        (a, b) => (b.netPnl.value ?? 0).compareTo(a.netPnl.value ?? 0),
      );
  }

  SidePerformanceRow _sideStats(List<JournalTrade> trades, JournalTradeSide side) {
    final list = trades.where((t) => t.side == side).toList();
    final na = MetricValue.of(null);
    if (list.isEmpty) {
      return SidePerformanceRow(
        side: side,
        trades: 0,
        winRate: na,
        netPnl: na,
        profitFactor: na,
        averageR: na,
      );
    }
    final wins = list.where((t) => t.netPnl > breakevenEpsilon).toList();
    final losses = list.where((t) => t.netPnl < -breakevenEpsilon).toList();
    final r = list.map((t) => t.rMultiple).whereType<double>().toList();
    return SidePerformanceRow(
      side: side,
      trades: list.length,
      winRate: MetricValue.of(wins.length / list.length * 100),
      netPnl: MetricValue.of(list.fold<double>(0, (s, t) => s + t.netPnl)),
      profitFactor: _profitFactor(wins, losses),
      averageR: MetricValue.of(
        r.isEmpty ? null : r.reduce((a, b) => a + b) / r.length,
      ),
    );
  }

  List<PeriodPerformanceRow> _periodStats(
    List<JournalTrade> trades, {
    required bool weekly,
  }) {
    final map = <DateTime, List<JournalTrade>>{};
    for (final t in trades) {
      final exit = t.exitTime!;
      final key = weekly ? _weekStart(exit) : DateTime(exit.year, exit.month, exit.day);
      map.putIfAbsent(key, () => []).add(t);
    }
    final keys = map.keys.toList()..sort();
    return keys.map((k) {
      final list = map[k]!;
      final wins = list.where((t) => t.netPnl > breakevenEpsilon).length;
      final r = list.map((t) => t.rMultiple).whereType<double>().toList();
      final label = weekly
          ? 'Wk ${k.month}/${k.day}/${k.year}'
          : '${k.year}-${k.month.toString().padLeft(2, '0')}-${k.day.toString().padLeft(2, '0')}';
      return PeriodPerformanceRow(
        periodStart: k,
        label: label,
        trades: list.length,
        netPnl: MetricValue.of(list.fold<double>(0, (s, t) => s + t.netPnl)),
        winRate: MetricValue.of(wins / list.length * 100),
        averageR: MetricValue.of(
          r.isEmpty ? null : r.reduce((a, b) => a + b) / r.length,
        ),
      );
    }).toList();
  }

  DateTime _weekStart(DateTime d) {
    final weekday = d.weekday;
    final monday = d.subtract(Duration(days: weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  List<DistributionBin> _histogramNet(List<double> values) {
    if (values.isEmpty) return [];
    final min = values.reduce(math.min);
    final max = values.reduce(math.max);
    const bins = 8;
    if (min == max) {
      return [DistributionBin(label: min.toStringAsFixed(0), count: values.length, midValue: min)];
    }
    final step = (max - min) / bins;
    final counts = List<int>.filled(bins, 0);
    for (final v in values) {
      var i = ((v - min) / step).floor();
      if (i >= bins) i = bins - 1;
      if (i < 0) i = 0;
      counts[i]++;
    }
    return List.generate(bins, (i) {
      final lo = min + step * i;
      final hi = lo + step;
      return DistributionBin(
        label: '${lo.toStringAsFixed(0)}–${hi.toStringAsFixed(0)}',
        count: counts[i],
        midValue: (lo + hi) / 2,
      );
    });
  }

  List<DistributionBin> _histogramR(List<double> values) {
    return _histogramNet(values);
  }

  double? _median(List<double> values) {
    if (values.isEmpty) return null;
    final sorted = List<double>.from(values)..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length.isOdd) return sorted[mid];
    return (sorted[mid - 1] + sorted[mid]) / 2;
  }
}
