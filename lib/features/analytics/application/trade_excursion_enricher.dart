import '../../../models/journal_trade.dart';
import '../../../services/delta/delta_api_service.dart';
import '../../../services/delta/models/delta_ohlc_candle.dart';
import '../data/ohlc_cache_repository.dart';
import 'trade_excursion_service.dart';

class TradeExcursionEnricher {
  TradeExcursionEnricher({
    required DeltaApiService api,
    required OhlcCacheRepository cache,
    TradeExcursionService? service,
  })  : _api = api,
        _cache = cache,
        _service = service ?? TradeExcursionService();

  final DeltaApiService _api;
  final OhlcCacheRepository _cache;
  final TradeExcursionService _service;

  Future<JournalTrade> enrich(JournalTrade trade) async {
    if (trade.status != JournalTradeStatus.closed || trade.exitTime == null) {
      return trade;
    }
    final candles = await _loadCandles(trade);
    final result = _service.computeForTrade(trade, candles);
    if (result == null) return trade;
    return trade.copyWith(
      mfe: result.mfeR,
      mae: result.maeR,
      profitCapture: result.profitCapture,
      entryEfficiency: result.entryEfficiency,
      exitEfficiency: result.exitEfficiency,
    );
  }

  Future<List<DeltaOhlcCandle>> _loadCandles(JournalTrade trade) async {
    final resolution = TradeExcursionService.resolutionForDuration(trade.duration);
    final start = trade.entryTime.millisecondsSinceEpoch ~/ 1000;
    final end = trade.exitTime!.millisecondsSinceEpoch ~/ 1000;
    final key = '${trade.symbol}_${resolution}_${start}_$end';
    final cached = await _cache.get(key);
    if (cached != null && cached.isNotEmpty) return cached;
    final candles = await _api.getOhlcCandles(
      symbol: trade.symbol,
      resolution: resolution,
      start: start,
      end: end,
    );
    if (candles.isNotEmpty) {
      await _cache.put(key, candles);
    }
    return candles;
  }
}
