import 'package:hive_flutter/hive_flutter.dart';

import '../../../services/delta/delta_api_service.dart';
import '../../../services/delta/delta_credentials.dart';
import '../data/delta_activity_fetcher.dart';
import '../data/trade_journal_repository.dart';
import '../domain/normalized_fill.dart';
import '../engine/trade_reconstruction_engine.dart';

class SyncResult {
  const SyncResult({
    required this.importedFills,
    required this.createdTrades,
    required this.updatedTrades,
    required this.totalTrades,
  });

  final int importedFills;
  final int createdTrades;
  final int updatedTrades;
  final int totalTrades;
}

class SyncOrchestrator {
  SyncOrchestrator({
    required DeltaApiService api,
    required TradeJournalRepository repository,
    TradeReconstructionEngine? engine,
  })  : _fetcher = DeltaActivityFetcher(api),
        _repository = repository,
        _engine = engine ?? TradeReconstructionEngine();

  final DeltaActivityFetcher _fetcher;
  final TradeJournalRepository _repository;
  final TradeReconstructionEngine _engine;

  Future<SyncResult> run({required DeltaCredentials credentials}) async {
    final meta = await _repository.loadSyncMeta();
    final now = DateTime.now();
    final endMicros = now.microsecondsSinceEpoch;

    final days = meta.initialLookbackDays;
    final windowStartMicros =
        now.subtract(Duration(days: days)).microsecondsSinceEpoch;
    final rawFills = await _fetcher.fetchAllFills(
      startTimeMicros: windowStartMicros,
      endTimeMicros: endMicros,
    );
    final normalized = rawFills
        .map(NormalizedFill.fromDeltaFill)
        .where((f) => f.productId != 0 && f.size > 0)
        .toList();

    final importedFillIds = Set<String>.from(meta.importedFillIds);
    final addedCount = await _repository.upsertFills(normalized);

    for (final f in normalized) {
      importedFillIds.add(f.fillId);
    }

    final funding = await _fetcher.fetchFundingTransactions(
      startTimeMicros: windowStartMicros,
      endTimeMicros: endMicros,
    );
    final existingFunding = await _repository.loadFunding();
    final mergedFunding = _dedupeFunding([...existingFunding, ...funding]);
    await _repository.saveFunding(mergedFunding);

    final orderBrackets = await _fetcher.fetchOrderBracketMap();

    final allFills = await _repository.loadAllFills();
    final previousTrades = await _repository.loadTrades();
    final previousIds = previousTrades.map((t) => t.id).toSet();

    final trades = _engine.reconstruct(
      fills: allFills,
      orderBrackets: orderBrackets,
    );

    final newIds = trades.map((t) => t.id).toSet();
    final created = newIds.difference(previousIds).length;
    var updated = 0;
    if (addedCount > 0) {
      for (final id in previousIds.intersection(newIds)) {
        final old = previousTrades.firstWhere((t) => t.id == id);
        final neu = trades.firstWhere((t) => t.id == id);
        if (old.netPnl != neu.netPnl ||
            old.status != neu.status ||
            old.fillIds.length != neu.fillIds.length) {
          updated++;
        }
      }
    }

    await _repository.saveTrades(trades);

    var maxTs = meta.lastFillTimestampMicros ?? 0;
    for (final f in normalized) {
      if (f.timestampMicros > maxTs) maxTs = f.timestampMicros;
    }
    if (maxTs == 0 && allFills.isNotEmpty) {
      maxTs = allFills.map((f) => f.timestampMicros).reduce((a, b) => a > b ? a : b);
    }

    await _repository.saveSyncMeta(
      meta.copyWith(
        lastSyncAt: now,
        lastFillTimestampMicros: maxTs > 0 ? maxTs : meta.lastFillTimestampMicros,
        importedFillIds: importedFillIds,
      ),
    );

    await _persistGlobalStorageKey(
      TradeJournalRepository.storageKeyFor(
        environment: credentials.environment,
        apiKey: credentials.apiKey,
      ),
    );

    return SyncResult(
      importedFills: addedCount,
      createdTrades: created,
      updatedTrades: updated,
      totalTrades: trades.length,
    );
  }

  List<FundingRecord> _dedupeFunding(List<FundingRecord> items) {
    final seen = <String>{};
    final out = <FundingRecord>[];
    for (final f in items) {
      final key = '${f.symbol}_${f.timestampMicros}_${f.amount}';
      if (seen.add(key)) out.add(f);
    }
    return out;
  }

  Future<void> _persistGlobalStorageKey(String key) async {
    final box = await Hive.openBox<String>('app_global');
    await box.put('lastJournalStorageKey', key);
  }
}
