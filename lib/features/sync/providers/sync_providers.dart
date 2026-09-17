import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../models/journal_trade.dart';
import '../../settings/providers/delta_connection_provider.dart';
import '../application/sync_orchestrator.dart';
import '../data/trade_journal_repository.dart';

enum SyncStatus { idle, syncing, synced, error }

class SyncState {
  const SyncState({
    this.status = SyncStatus.idle,
    this.lastSyncAt,
    this.message,
    this.importedFills = 0,
    this.createdTrades = 0,
    this.updatedTrades = 0,
  });

  final SyncStatus status;
  final DateTime? lastSyncAt;
  final String? message;
  final int importedFills;
  final int createdTrades;
  final int updatedTrades;
}

class SyncController extends Notifier<SyncState> {
  @override
  SyncState build() {
    Future.microtask(_refreshLastSyncFromDisk);
    return const SyncState();
  }

  Future<void> _refreshLastSyncFromDisk() async {
    final key = await _resolveStorageKey();
    if (key == null) return;
    final meta = await TradeJournalRepository(storageKey: key).loadSyncMeta();
    if (meta.lastSyncAt != null) {
      state = SyncState(lastSyncAt: meta.lastSyncAt);
    }
  }

  Future<String?> _resolveStorageKey() async {
    final creds = ref.read(deltaCredentialsStoreProvider).read();
    if (creds != null) {
      return TradeJournalRepository.storageKeyFor(
        environment: creds.environment,
        apiKey: creds.apiKey,
      );
    }
    final box = await Hive.openBox<String>('app_global');
    return box.get('lastJournalStorageKey');
  }

  Future<void> syncNow() async {
    final api = ref.read(deltaApiServiceProvider);
    final creds = ref.read(deltaCredentialsStoreProvider).read();
    if (api == null || creds == null) {
      state = const SyncState(
        status: SyncStatus.error,
        message:
            'Connect to Delta Exchange first (Settings). Credentials are cleared on refresh.',
      );
      return;
    }

    state = SyncState(
      status: SyncStatus.syncing,
      lastSyncAt: state.lastSyncAt,
    );

    try {
      final storageKey = TradeJournalRepository.storageKeyFor(
        environment: creds.environment,
        apiKey: creds.apiKey,
      );
      final repo = TradeJournalRepository(storageKey: storageKey);
      final lookback = ref.read(syncLookbackDaysProvider);
      final meta = await repo.loadSyncMeta();
      if (meta.lastFillTimestampMicros == null) {
        await repo.saveSyncMeta(
          meta.copyWith(initialLookbackDays: lookback),
        );
      }

      final orchestrator = SyncOrchestrator(api: api, repository: repo);
      final result = await orchestrator.run(credentials: creds);
      state = SyncState(
        status: SyncStatus.synced,
        lastSyncAt: DateTime.now(),
        importedFills: result.importedFills,
        createdTrades: result.createdTrades,
        updatedTrades: result.updatedTrades,
        message:
            'Imported ${result.importedFills} fills · '
            'Created ${result.createdTrades} trades · '
            'Updated ${result.updatedTrades} trades',
      );
      ref.read(journalTradesRevisionProvider.notifier).state++;
    } catch (e) {
      state = SyncState(
        status: SyncStatus.error,
        lastSyncAt: state.lastSyncAt,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}

final syncControllerProvider =
    NotifierProvider<SyncController, SyncState>(SyncController.new);

final syncLookbackDaysProvider = StateProvider<int>((ref) => 90);

/// Bumped after a successful sync so [journalTradesProvider] reloads without
/// watching [syncControllerProvider] (that caused a circular dependency).
final journalTradesRevisionProvider = StateProvider<int>((ref) => 0);

final journalTradesProvider = FutureProvider<List<JournalTrade>>((ref) async {
  ref.watch(journalTradesRevisionProvider);
  final creds = ref.read(deltaCredentialsStoreProvider).read();
  String? storageKey;
  if (creds != null) {
    storageKey = TradeJournalRepository.storageKeyFor(
      environment: creds.environment,
      apiKey: creds.apiKey,
    );
  } else {
    final box = await Hive.openBox<String>('app_global');
    storageKey = box.get('lastJournalStorageKey');
  }
  if (storageKey == null) return [];
  final repo = TradeJournalRepository(storageKey: storageKey);
  return repo.loadTrades();
});
