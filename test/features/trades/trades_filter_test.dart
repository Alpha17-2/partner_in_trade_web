import 'package:flutter_test/flutter_test.dart';
import 'package:partner_in_trade_web/features/trades/application/trades_filter_sort.dart';
import 'package:partner_in_trade_web/models/journal_trade.dart';

JournalTrade _t({
  required String symbol,
  double netPnl = 10,
  JournalTradeSide side = JournalTradeSide.long,
  String? strategy,
  DateTime? entry,
}) {
  return JournalTrade(
    id: symbol,
    productId: 1,
    symbol: symbol,
    side: side,
    entryTime: entry ?? DateTime.utc(2025, 6, 1),
    entryPrice: 100,
    quantity: 1,
    averageEntryPrice: 100,
    grossPnl: netPnl,
    fees: 0,
    funding: 0,
    netPnl: netPnl,
    orderIds: const [],
    fillIds: const ['f'],
    status: JournalTradeStatus.closed,
    strategy: strategy,
  );
}

void main() {
  final trades = [
    _t(symbol: 'BTCUSD', netPnl: 10, strategy: 'FVG'),
    _t(symbol: 'ETHUSD', netPnl: -5, side: JournalTradeSide.short),
  ];

  test('search filters by symbol', () {
    final out = filterTrades(
      trades,
      const TradesFilterState(search: 'eth'),
    );
    expect(out.length, 1);
    expect(out.first.symbol, 'ETHUSD');
  });

  test('winning filter', () {
    final out = filterTrades(
      trades,
      const TradesFilterState(outcome: TradeOutcomeFilter.winning),
    );
    expect(out.length, 1);
    expect(out.first.netPnl, greaterThan(0));
  });

  test('strategy filter', () {
    final out = filterTrades(
      trades,
      const TradesFilterState(strategy: 'FVG'),
    );
    expect(out.length, 1);
  });
}
