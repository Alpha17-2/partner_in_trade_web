import 'package:flutter_test/flutter_test.dart';
import 'package:partner_in_trade_web/features/sync/domain/normalized_fill.dart';
import 'package:partner_in_trade_web/features/trades/application/trade_timeline_builder.dart';
import 'package:partner_in_trade_web/models/journal_trade.dart';
import 'package:partner_in_trade_web/services/delta/models/delta_parse_utils.dart';

NormalizedFill _fill({
  required String id,
  required DeltaSide side,
  required double size,
  int? positionAfter,
  int ts = 1,
}) {
  return NormalizedFill(
    fillId: id,
    productId: 1,
    symbol: 'BTCUSD',
    side: side,
    size: size,
    price: 100,
    commission: 0,
    timestampMicros: ts,
    positionSizeAfter: positionAfter,
  );
}

void main() {
  final trade = JournalTrade(
    id: 't1',
    productId: 1,
    symbol: 'BTCUSD',
    side: JournalTradeSide.long,
    entryTime: DateTime.utc(2025, 1, 1),
    entryPrice: 100,
    quantity: 3,
    averageEntryPrice: 100,
    grossPnl: 0,
    fees: 0,
    funding: 0,
    netPnl: 0,
    orderIds: const [],
    fillIds: const ['a', 'b', 'c'],
    status: JournalTradeStatus.open,
  );

  test('scale in and partial exit', () {
    final events = buildTradeTimeline(
      trade: trade,
      fills: [
        _fill(id: 'a', side: DeltaSide.buy, size: 1, positionAfter: 1, ts: 1),
        _fill(id: 'b', side: DeltaSide.buy, size: 2, positionAfter: 3, ts: 2),
        _fill(id: 'c', side: DeltaSide.sell, size: 1, positionAfter: 2, ts: 3),
      ],
    );
    expect(events.length, 3);
    expect(events[0].type, TradeTimelineEventType.entry);
    expect(events[1].type, TradeTimelineEventType.scaleIn);
    expect(events[2].type, TradeTimelineEventType.partialExit);
  });
}
