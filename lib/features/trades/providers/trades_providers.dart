import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../models/journal_trade.dart';
import '../../settings/providers/delta_connection_provider.dart';
import '../../sync/data/trade_journal_repository.dart';
import '../../sync/domain/normalized_fill.dart';
import '../application/trades_filter_sort.dart';

/// Bumped after a successful sync so [journalTradesProvider] reloads without
/// watching [syncControllerProvider] (that caused a circular dependency).
final journalTradesRevisionProvider = StateProvider<int>((ref) => 0);

Future<String?> resolveJournalStorageKey(Ref ref) async {
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

final tradeJournalRepositoryProvider = FutureProvider<TradeJournalRepository?>((ref) async {
  ref.watch(deltaCredentialsVersionProvider);
  ref.watch(deltaConnectionControllerProvider);
  final key = await resolveJournalStorageKey(ref);
  if (key == null) return null;
  return TradeJournalRepository(storageKey: key);
});

class JournalTradesNotifier extends AsyncNotifier<List<JournalTrade>> {
  @override
  Future<List<JournalTrade>> build() async {
    ref.watch(journalTradesRevisionProvider);
    ref.watch(tradeJournalRepositoryProvider);
    return _loadFromDisk();
  }

  /// Reload from disk after sync (same boxes, fresh read).
  Future<void> reloadFromDisk() async {
    state = const AsyncLoading();
    state = AsyncData(await _loadFromDisk());
  }

  Future<List<JournalTrade>> _loadFromDisk() async {
    final repo = await ref.read(tradeJournalRepositoryProvider.future);
    if (repo == null) return [];
    return repo.loadTrades();
  }

  /// Persists journal edits without reloading the list (avoids detail panel reset).
  Future<void> patchTrade(JournalTrade trade) async {
    final repo = await ref.read(tradeJournalRepositoryProvider.future);
    if (repo == null) {
      throw StateError('Storage not available');
    }
    await repo.upsertTrade(trade);
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData([
      for (final t in current) t.id == trade.id ? trade : t,
    ]);
  }
}

final journalTradesProvider =
    AsyncNotifierProvider<JournalTradesNotifier, List<JournalTrade>>(
  JournalTradesNotifier.new,
);

final selectedTradeIdProvider = StateProvider<String?>((ref) => null);

final tradesFilterProvider =
    StateProvider<TradesFilterState>((ref) => const TradesFilterState());

final tradesSortProvider =
    StateProvider<TradesSortState>((ref) => const TradesSortState());

class TradesPageState {
  const TradesPageState({this.page = 0, this.pageSize = 25});

  final int page;
  final int pageSize;
}

final tradesPageProvider =
    StateProvider<TradesPageState>((ref) => const TradesPageState());

final filteredTradesProvider = Provider<AsyncValue<List<JournalTrade>>>((ref) {
  final tradesAsync = ref.watch(journalTradesProvider);
  final filter = ref.watch(tradesFilterProvider);
  final sort = ref.watch(tradesSortProvider);

  return tradesAsync.whenData((trades) {
    final filtered = filterTrades(trades, filter);
    return sortTrades(filtered, sort);
  });
});

final paginatedTradesProvider = Provider<AsyncValue<List<JournalTrade>>>((ref) {
  final filtered = ref.watch(filteredTradesProvider);
  final pageState = ref.watch(tradesPageProvider);

  return filtered.whenData((trades) {
    final start = pageState.page * pageState.pageSize;
    if (start >= trades.length) return <JournalTrade>[];
    final end = (start + pageState.pageSize).clamp(0, trades.length);
    return trades.sublist(start, end);
  });
});

final filteredTradesCountProvider = Provider<int>((ref) {
  return ref.watch(filteredTradesProvider).value?.length ?? 0;
});

final tradeFillsProvider =
    FutureProvider.family<List<NormalizedFill>, String>((ref, tradeId) async {
  // Reload fills only after Delta sync, not on journal field saves.
  ref.watch(journalTradesRevisionProvider);
  final trades = ref.watch(journalTradesProvider).valueOrNull;
  JournalTrade? trade;
  if (trades != null) {
    for (final t in trades) {
      if (t.id == tradeId) {
        trade = t;
        break;
      }
    }
  }
  if (trade == null) {
    final repo = await ref.read(tradeJournalRepositoryProvider.future);
    if (repo == null) return [];
    final fromDisk = await repo.getTrade(tradeId);
    if (fromDisk == null) return [];
    return repo.loadFillsForTrade(fromDisk);
  }
  final repo = await ref.read(tradeJournalRepositoryProvider.future);
  if (repo == null) return [];
  return repo.loadFillsForTrade(trade);
});

final selectedTradeProvider = Provider<JournalTrade?>((ref) {
  final id = ref.watch(selectedTradeIdProvider);
  if (id == null) return null;
  final trades = ref.watch(journalTradesProvider).valueOrNull;
  if (trades == null) return null;
  for (final t in trades) {
    if (t.id == id) return t;
  }
  return null;
});

enum JournalSaveStatus { idle, saving, saved, error }

class JournalSaveState {
  const JournalSaveState({
    this.status = JournalSaveStatus.idle,
    this.message,
  });

  final JournalSaveStatus status;
  final String? message;
}

class JournalEditController extends Notifier<JournalSaveState> {
  Timer? _debounce;

  @override
  JournalSaveState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const JournalSaveState();
  }

  void scheduleSave(JournalTrade trade) {
    _debounce?.cancel();
    state = const JournalSaveState(status: JournalSaveStatus.saving);
    _debounce = Timer(const Duration(milliseconds: 500), () => _persist(trade));
  }

  Future<void> _persist(JournalTrade trade) async {
    try {
      final repo = await ref.read(tradeJournalRepositoryProvider.future);
      if (repo == null) {
        state = const JournalSaveState(
          status: JournalSaveStatus.error,
          message: 'Storage not available',
        );
        return;
      }
      await ref.read(journalTradesProvider.notifier).patchTrade(trade);
      state = const JournalSaveState(status: JournalSaveStatus.saved);
    } catch (e) {
      state = JournalSaveState(
        status: JournalSaveStatus.error,
        message: e.toString(),
      );
    }
  }

}

final journalEditControllerProvider =
    NotifierProvider<JournalEditController, JournalSaveState>(
  JournalEditController.new,
);
