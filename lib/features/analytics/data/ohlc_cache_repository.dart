import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../services/delta/models/delta_ohlc_candle.dart';

class OhlcCacheRepository {
  OhlcCacheRepository({required this.storageKey});

  final String storageKey;

  String get _boxName => '${storageKey}_ohlc_cache';

  Future<void> _ensureOpen() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<String>(_boxName);
    }
  }

  Future<List<DeltaOhlcCandle>?> get(String key) async {
    await _ensureOpen();
    final raw = Hive.box<String>(_boxName).get(key);
    if (raw == null) return null;
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => DeltaOhlcCandle.fromRow(e as List<dynamic>))
        .whereType<DeltaOhlcCandle>()
        .toList();
  }

  Future<void> put(String key, List<DeltaOhlcCandle> candles) async {
    await _ensureOpen();
    final rows = candles
        .map(
          (c) => [
            c.time,
            c.open,
            c.high,
            c.low,
            c.close,
            c.volume,
          ],
        )
        .toList();
    await Hive.box<String>(_boxName).put(key, jsonEncode(rows));
  }
}
