import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/journal_trade.dart';
import '../../../services/delta/delta_api_service.dart';
import '../../settings/providers/delta_connection_provider.dart';
import '../../trades/providers/trades_providers.dart';
import '../application/trade_excursion_enricher.dart';
import '../data/ohlc_cache_repository.dart';

final publicOrConnectedDeltaApiProvider = Provider<DeltaApiService>((ref) {
  ref.watch(deltaCredentialsVersionProvider);
  final connected = ref.watch(deltaApiServiceProvider);
  if (connected != null) return connected;
  return DeltaApiService.public(
    environment: ref.watch(deltaEnvironmentProvider),
  );
});

final ohlcCacheRepositoryProvider = FutureProvider<OhlcCacheRepository?>(
  (ref) async {
    final key = await resolveJournalStorageKey(ref);
    if (key == null) return OhlcCacheRepository(storageKey: 'local_unlinked');
    return OhlcCacheRepository(storageKey: key);
  },
);

final tradeExcursionEnricherProvider =
    FutureProvider<TradeExcursionEnricher>((ref) async {
  final api = ref.watch(publicOrConnectedDeltaApiProvider);
  final cache = await ref.watch(ohlcCacheRepositoryProvider.future);
  return TradeExcursionEnricher(
    api: api,
    cache: cache ?? OhlcCacheRepository(storageKey: 'local_unlinked'),
  );
});

class TradeExcursionController extends AsyncNotifier<void> {
  final _inFlight = <String>{};

  @override
  Future<void> build() async {}

  Future<void> ensure(JournalTrade trade) async {
    if (trade.status != JournalTradeStatus.closed || trade.exitTime == null) {
      return;
    }
    if (trade.profitCapture != null || trade.mfe != null) return;
    if (!_inFlight.add(trade.id)) return;
    try {
      final enricher = await ref.read(tradeExcursionEnricherProvider.future);
      final next = await enricher.enrich(trade);
      if (next.mfe != trade.mfe ||
          next.mae != trade.mae ||
          next.profitCapture != trade.profitCapture) {
        await ref.read(journalTradesProvider.notifier).patchTrade(next);
      }
    } catch (_) {
      // Leave N/A when candles are unavailable.
    } finally {
      _inFlight.remove(trade.id);
    }
  }

  Future<void> ensureMissing(List<JournalTrade> trades, {int limit = 20}) async {
    var n = 0;
    for (final trade in trades) {
      if (n >= limit) break;
      if (trade.profitCapture != null || trade.mfe != null) continue;
      n++;
      await ensure(trade);
    }
  }
}

final tradeExcursionControllerProvider =
    AsyncNotifierProvider<TradeExcursionController, void>(
  TradeExcursionController.new,
);
