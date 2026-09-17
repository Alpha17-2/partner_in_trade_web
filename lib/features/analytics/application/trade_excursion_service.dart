import '../../../models/journal_trade.dart';
import '../../../services/delta/models/delta_ohlc_candle.dart';

class TradeExcursionResult {
  const TradeExcursionResult({
    required this.mfePrice,
    required this.maePrice,
    this.mfeR,
    this.maeR,
    this.profitCapture,
    this.entryEfficiency,
    this.exitEfficiency,
  });

  final double mfePrice;
  final double maePrice;
  final double? mfeR;
  final double? maeR;
  final double? profitCapture;
  final double? entryEfficiency;
  final double? exitEfficiency;
}

class TradeExcursionService {
  static const _eps = 1e-12;

  TradeExcursionResult? compute({
    required JournalTradeSide side,
    required double entry,
    required double? exit,
    required DateTime entryTime,
    required DateTime? exitTime,
    required List<DeltaOhlcCandle> candles,
    double? stopLoss,
    double? rMultiple,
    double? netPnl,
  }) {
    if (exitTime == null) return null;
    final inRange = candles.where((c) {
      final t = _candleSeconds(c);
      final start = entryTime.millisecondsSinceEpoch / 1000.0;
      final end = exitTime.millisecondsSinceEpoch / 1000.0;
      return t + _eps >= start && t - _eps <= end;
    }).toList();
    if (inRange.isEmpty) return null;

    final maxHigh = inRange.map((c) => c.high).reduce((a, b) => a > b ? a : b);
    final minLow = inRange.map((c) => c.low).reduce((a, b) => a < b ? a : b);
    final exitPrice = exit ?? entry;

    final double mfePrice;
    final double maePrice;
    final double realized;
    if (side == JournalTradeSide.long) {
      mfePrice = maxHigh - entry;
      maePrice = minLow - entry;
      realized = exitPrice - entry;
    } else {
      mfePrice = entry - minLow;
      maePrice = entry - maxHigh;
      realized = entry - exitPrice;
    }

    final range = mfePrice - maePrice;
    final entryEfficiency = range > _eps ? mfePrice / range : null;
    final exitEfficiency = range > _eps ? (realized - maePrice) / range : null;
    final profitCapture = mfePrice > _eps ? realized / mfePrice : null;

    final rSize = _rSize(
      entry: entry,
      stopLoss: stopLoss,
      rMultiple: rMultiple,
      netPnl: netPnl,
    );

    return TradeExcursionResult(
      mfePrice: mfePrice,
      maePrice: maePrice,
      mfeR: rSize != null ? mfePrice / rSize : null,
      maeR: rSize != null ? maePrice / rSize : null,
      profitCapture: profitCapture,
      entryEfficiency: entryEfficiency,
      exitEfficiency: exitEfficiency,
    );
  }

  TradeExcursionResult? computeForTrade(
    JournalTrade trade,
    List<DeltaOhlcCandle> candles,
  ) {
    return compute(
      side: trade.side,
      entry: trade.averageEntryPrice,
      exit: trade.averageExitPrice,
      entryTime: trade.entryTime,
      exitTime: trade.exitTime,
      candles: candles,
      stopLoss: trade.stopLoss,
      rMultiple: trade.rMultiple,
      netPnl: trade.netPnl,
    );
  }

  double? _rSize({
    required double entry,
    double? stopLoss,
    double? rMultiple,
    double? netPnl,
  }) {
    if (stopLoss != null && (entry - stopLoss).abs() > _eps) {
      return (entry - stopLoss).abs();
    }
    if (rMultiple != null &&
        rMultiple.abs() > _eps &&
        netPnl != null &&
        netPnl.abs() > _eps) {
      return (netPnl / rMultiple).abs();
    }
    return null;
  }

  int _candleSeconds(DeltaOhlcCandle c) {
    if (c.time > 1000000000000) return c.time ~/ 1000;
    return c.time;
  }

  static String resolutionForDuration(Duration? duration) {
    final seconds = duration?.inSeconds ?? 0;
    if (seconds < 2 * 3600) return '1m';
    if (seconds < 2 * 86400) return '5m';
    return '1h';
  }
}
