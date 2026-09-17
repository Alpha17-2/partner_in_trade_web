import '../../../services/delta/delta_api_service.dart';
import '../../../services/delta/models/delta_fill.dart';
import '../../../services/delta/models/delta_parse_utils.dart';
import '../domain/normalized_fill.dart';

class DeltaActivityFetcher {
  DeltaActivityFetcher(this._api);

  final DeltaApiService _api;

  static const pageSize = '50';

  Future<List<DeltaFill>> fetchAllFills({
    int? startTimeMicros,
    int? endTimeMicros,
  }) async {
    final all = <DeltaFill>[];
    String? after;
    for (var page = 0; page < 500; page++) {
      final params = <String, String>{
        'page_size': pageSize,
        if (startTimeMicros != null) 'start_time': startTimeMicros.toString(),
        if (endTimeMicros != null) 'end_time': endTimeMicros.toString(),
        if (after != null) 'after': after,
      };
      final result = await _api.getFills(queryParameters: params);
      all.addAll(result.items);
      after = result.meta?.after;
      if (after == null || result.items.isEmpty) break;
    }
    return all;
  }

  Future<List<FundingRecord>> fetchFundingTransactions({
    int? startTimeMicros,
    int? endTimeMicros,
  }) async {
    final all = <FundingRecord>[];
    String? after;
    for (var page = 0; page < 200; page++) {
      final params = <String, String>{
        'page_size': pageSize,
        'transaction_type': 'funding',
        if (startTimeMicros != null) 'start_time': startTimeMicros.toString(),
        if (endTimeMicros != null) 'end_time': endTimeMicros.toString(),
        if (after != null) 'after': after,
      };
      final result = await _api.getWalletTransactions(queryParameters: params);
      for (final tx in result.items) {
        if (tx.transactionType != DeltaTransactionType.funding) continue;
        final amount = double.tryParse(tx.amount ?? '') ?? 0;
        final ts = int.tryParse(tx.createdAt ?? '') ?? 0;
        final symbol = tx.assetSymbol ??
            (tx.extra['product_symbol'] != null
                ? tx.extra['product_symbol'].toString()
                : null) ??
            'UNKNOWN';
        all.add(FundingRecord(
          symbol: symbol,
          amount: amount,
          timestampMicros: ts,
        ));
      }
      after = result.meta?.after;
      if (after == null || result.items.isEmpty) break;
    }
    return all;
  }

  Future<Map<String, OrderBracketInfo>> fetchOrderBracketMap() async {
    final map = <String, OrderBracketInfo>{};
    String? after;
    for (var page = 0; page < 100; page++) {
      final result = await _api.getOrderHistory(
        queryParameters: {
          'page_size': pageSize,
          if (after != null) 'after': after,
        },
      );
      for (final order in result.items) {
        final id = order.id.toString();
        map[id] = OrderBracketInfo(
          stopLoss: _parseDouble(order.extra['bracket_stop_loss_price']),
          takeProfit: _parseDouble(order.extra['bracket_take_profit_price']),
        );
      }
      after = result.meta?.after;
      if (after == null || result.items.isEmpty) break;
    }
    return map;
  }

  double? _parseDouble(dynamic v) {
    if (v == null) return null;
    return double.tryParse(v.toString());
  }
}
