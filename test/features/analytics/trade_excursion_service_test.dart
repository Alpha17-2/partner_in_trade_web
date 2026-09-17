import 'package:flutter_test/flutter_test.dart';
import 'package:partner_in_trade_web/features/analytics/application/trade_excursion_service.dart';
import 'package:partner_in_trade_web/models/journal_trade.dart';
import 'package:partner_in_trade_web/services/delta/models/delta_ohlc_candle.dart';

DeltaOhlcCandle c({
  required int seconds,
  required double high,
  required double low,
  double close = 100,
}) {
  return DeltaOhlcCandle(
    time: seconds,
    open: 100,
    high: high,
    low: low,
    close: close,
  );
}

void main() {
  final service = TradeExcursionService();
  final entry = DateTime.utc(2026, 9, 18, 10);
  final exit = DateTime.utc(2026, 9, 18, 11);
  final start = entry.millisecondsSinceEpoch ~/ 1000;
  final end = exit.millisecondsSinceEpoch ~/ 1000;

  test('LONG MFE and MAE from candles inside the trade window', () {
    final result = service.compute(
      side: JournalTradeSide.long,
      entry: 100,
      exit: 110,
      entryTime: entry,
      exitTime: exit,
      candles: [
        c(seconds: start, high: 104, low: 99),
        c(seconds: start + 60, high: 112, low: 98),
        c(seconds: end + 3600, high: 200, low: 50),
      ],
      stopLoss: 95,
    );
    expect(result, isNotNull);
    expect(result!.mfePrice, 12);
    expect(result.maePrice, -2);
    expect(result.mfeR, closeTo(12 / 5, 1e-9));
    expect(result.maeR, closeTo(-2 / 5, 1e-9));
    expect(result.profitCapture, closeTo(10 / 12, 1e-9));
  });

  test('SHORT MFE and MAE', () {
    final result = service.compute(
      side: JournalTradeSide.short,
      entry: 100,
      exit: 90,
      entryTime: entry,
      exitTime: exit,
      candles: [
        c(seconds: start, high: 101, low: 92),
        c(seconds: start + 30, high: 103, low: 88),
      ],
      stopLoss: 105,
    );
    expect(result!.mfePrice, 12);
    expect(result.maePrice, -3);
    expect(result.profitCapture, closeTo(10 / 12, 1e-9));
  });

  test('profit capture is null when MFE is not positive', () {
    final result = service.compute(
      side: JournalTradeSide.long,
      entry: 100,
      exit: 99,
      entryTime: entry,
      exitTime: exit,
      candles: [c(seconds: start, high: 100, low: 98)],
    );
    expect(result!.mfePrice, 0);
    expect(result.profitCapture, isNull);
  });

  test('missing candles returns null', () {
    final result = service.compute(
      side: JournalTradeSide.long,
      entry: 100,
      exit: 110,
      entryTime: entry,
      exitTime: exit,
      candles: const [],
    );
    expect(result, isNull);
  });

  test('entry and exit efficiency for LONG', () {
    final result = service.compute(
      side: JournalTradeSide.long,
      entry: 100,
      exit: 110,
      entryTime: entry,
      exitTime: exit,
      candles: [
        c(seconds: start, high: 120, low: 90),
      ],
    );
    expect(result!.entryEfficiency, closeTo(20 / 30, 1e-9));
    expect(result.exitEfficiency, closeTo(20 / 30, 1e-9));
  });
}
