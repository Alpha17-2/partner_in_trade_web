import '../../../models/journal_trade.dart';
import '../domain/performance_snapshot.dart';

class TradeInsightsService {
  List<String> observations({
    required List<JournalTrade> trades,
    required PerformanceSnapshot snapshot,
  }) {
    final lines = <String>[];
    final closed = trades
        .where(
          (t) => t.status == JournalTradeStatus.closed && t.exitTime != null,
        )
        .toList();
    if (closed.isEmpty) return lines;

    final withCapture = closed.where((t) => t.profitCapture != null).toList();
    if (withCapture.isNotEmpty) {
      final avg = withCapture.fold<double>(0, (s, t) => s + t.profitCapture!) /
          withCapture.length;
      lines.add(
        '${withCapture.length} trades had an average profit capture of '
        '${(avg * 100).toStringAsFixed(0)}%.',
      );
    }

    var leaked = 0;
    for (final t in closed) {
      final mfeR = t.mfe;
      final realizedR = t.rMultiple;
      if (mfeR != null && realizedR != null && mfeR > 2 && realizedR < 1) {
        leaked++;
      }
    }
    if (leaked > 0) {
      lines.add(
        '$leaked trades moved more than +2R in your favor before closing '
        'below +1R.',
      );
    }

    final losing = closed.where((t) => t.netPnl < -1e-9).toList();
    final loserMae = losing.map((t) => t.mae).whereType<double>().toList();
    if (loserMae.isNotEmpty) {
      final avg =
          loserMae.reduce((a, b) => a + b) / loserMae.length;
      lines.add(
        'Average MAE on losing trades was ${avg.toStringAsFixed(1)}R.',
      );
    }

    final fees = snapshot.statistics.totalFees;
    if (fees.hasValue) {
      lines.add(
        'Trading fees represented \$${fees.value!.abs().toStringAsFixed(2)} '
        'of total P&L.',
      );
    }

    final mfeVals = closed.map((t) => t.mfe).whereType<double>().toList();
    final maeVals = closed.map((t) => t.mae).whereType<double>().toList();
    if (mfeVals.isNotEmpty) {
      final avg = mfeVals.reduce((a, b) => a + b) / mfeVals.length;
      lines.add('Average MFE was ${avg.toStringAsFixed(2)}R.');
    }
    if (maeVals.isNotEmpty) {
      final avg = maeVals.reduce((a, b) => a + b) / maeVals.length;
      lines.add('Average MAE was ${avg.toStringAsFixed(2)}R.');
    }

    return lines;
  }
}
