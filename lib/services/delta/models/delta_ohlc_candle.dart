import 'delta_parse_utils.dart';

/// OHLC rows are arrays: [time, open, high, low, close, volume] per API docs.
class DeltaOhlcCandle {
  const DeltaOhlcCandle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.volume,
  });

  final int time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double? volume;

  static DeltaOhlcCandle? fromRow(dynamic row) {
    if (row is! List || row.length < 5) return null;
    double toDouble(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }
    return DeltaOhlcCandle(
      time: parseInt(row[0]) ?? 0,
      open: toDouble(row[1]),
      high: toDouble(row[2]),
      low: toDouble(row[3]),
      close: toDouble(row[4]),
      volume: row.length > 5 ? toDouble(row[5]) : null,
    );
  }
}
