import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../models/journal_trade.dart';
import '../../../services/delta/delta_config.dart';
import '../domain/normalized_fill.dart';
import 'sync_metadata.dart';

class TradeJournalRepository {
  TradeJournalRepository({required this.storageKey});

  final String storageKey;

  static String storageKeyFor({
    required DeltaEnvironment environment,
    required String apiKey,
  }) {
    final hash = sha256.convert(utf8.encode(apiKey)).toString();
    return '${environment.name}_$hash'.substring(0, 48);
  }

  String get _metaBox => '${storageKey}_sync_meta';
  String get _fillsBox => '${storageKey}_fills';
  String get _tradesBox => '${storageKey}_trades';
  String get _fundingBox => '${storageKey}_funding';

  Future<void> _ensureOpen() async {
    if (!Hive.isBoxOpen(_metaBox)) await Hive.openBox<String>(_metaBox);
    if (!Hive.isBoxOpen(_fillsBox)) await Hive.openBox<String>(_fillsBox);
    if (!Hive.isBoxOpen(_tradesBox)) await Hive.openBox<String>(_tradesBox);
    if (!Hive.isBoxOpen(_fundingBox)) await Hive.openBox<String>(_fundingBox);
  }

  Future<SyncMetadata> loadSyncMeta() async {
    await _ensureOpen();
    final raw = Hive.box<String>(_metaBox).get('meta');
    if (raw == null) return const SyncMetadata();
    return SyncMetadata.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> saveSyncMeta(SyncMetadata meta) async {
    await _ensureOpen();
    await Hive.box<String>(_metaBox).put('meta', jsonEncode(meta.toJson()));
  }

  Future<List<NormalizedFill>> loadAllFills() async {
    await _ensureOpen();
    final box = Hive.box<String>(_fillsBox);
    return box.values
        .map((v) => NormalizedFill.fromJson(jsonDecode(v) as Map<String, dynamic>))
        .toList();
  }

  Future<int> upsertFills(List<NormalizedFill> fills) async {
    await _ensureOpen();
    final box = Hive.box<String>(_fillsBox);
    var added = 0;
    for (final f in fills) {
      final isNew = !box.containsKey(f.fillId);
      await box.put(f.fillId, jsonEncode(f.toJson()));
      if (isNew) added++;
    }
    return added;
  }

  Future<List<JournalTrade>> loadTrades() async {
    await _ensureOpen();
    final box = Hive.box<String>(_tradesBox);
    return box.values
        .map((v) => JournalTrade.fromJson(jsonDecode(v) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTrades(List<JournalTrade> trades) async {
    await _ensureOpen();
    final box = Hive.box<String>(_tradesBox);
    await box.clear();
    for (final t in trades) {
      await box.put(t.id, jsonEncode(t.toJson()));
    }
  }

  Future<void> saveFunding(List<FundingRecord> records) async {
    await _ensureOpen();
    final box = Hive.box<String>(_fundingBox);
    await box.clear();
    for (var i = 0; i < records.length; i++) {
      await box.put('$i', jsonEncode(records[i].toJson()));
    }
  }

  Future<List<FundingRecord>> loadFunding() async {
    await _ensureOpen();
    final box = Hive.box<String>(_fundingBox);
    return box.values
        .map((v) => FundingRecord.fromJson(jsonDecode(v) as Map<String, dynamic>))
        .toList();
  }

  Future<void> clearAll() async {
    await _ensureOpen();
    await Hive.box<String>(_metaBox).clear();
    await Hive.box<String>(_fillsBox).clear();
    await Hive.box<String>(_tradesBox).clear();
    await Hive.box<String>(_fundingBox).clear();
  }
}
