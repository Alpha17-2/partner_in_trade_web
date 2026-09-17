import 'package:flutter_test/flutter_test.dart';
import 'package:partner_in_trade_web/features/journal/application/journal_date.dart';
import 'package:partner_in_trade_web/features/journal/application/trades_for_date.dart';
import 'package:partner_in_trade_web/models/journal_trade.dart';

JournalTrade _trade({
  required String id,
  required DateTime entry,
  DateTime? exit,
  JournalTradeStatus status = JournalTradeStatus.closed,
}) {
  return JournalTrade(
    id: id,
    productId: 1,
    symbol: 'BTCUSD',
    side: JournalTradeSide.long,
    entryTime: entry,
    exitTime: exit,
    entryPrice: 100,
    quantity: 1,
    averageEntryPrice: 100,
    grossPnl: 1,
    fees: 0,
    funding: 0,
    netPnl: 1,
    orderIds: const [],
    fillIds: [id],
    status: status,
  );
}

void main() {
  test('parseDateKey accepts valid dates only', () {
    expect(parseDateKey('2026-09-18'), DateTime(2026, 9, 18));
    expect(parseDateKey('2026-13-01'), isNull);
    expect(parseDateKey('nope'), isNull);
  });

  test('only trades for the selected local date', () {
    final trades = [
      _trade(
        id: 'a',
        entry: DateTime(2026, 9, 18, 10),
        exit: DateTime(2026, 9, 18, 12),
      ),
      _trade(
        id: 'b',
        entry: DateTime(2026, 9, 17, 10),
        exit: DateTime(2026, 9, 17, 12),
      ),
      _trade(
        id: 'open',
        entry: DateTime(2026, 9, 18, 15),
        status: JournalTradeStatus.open,
      ),
    ];
    final day = tradesForLocalDate(trades, '2026-09-18');
    expect(day.map((t) => t.id), ['a', 'open']);
  });
}
