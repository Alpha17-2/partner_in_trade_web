import 'package:flutter_test/flutter_test.dart';
import 'package:partner_in_trade_web/features/trades/domain/journal_trade_merge.dart';
import 'package:partner_in_trade_web/models/journal_trade.dart';

JournalTrade _trade({
  required String id,
  List<String> fillIds = const ['f1'],
  double netPnl = 10,
  String? strategy,
  String? notes,
}) {
  return JournalTrade(
    id: id,
    productId: 1,
    symbol: 'BTCUSD',
    side: JournalTradeSide.long,
    entryTime: DateTime.utc(2025, 1, 1),
    entryPrice: 100,
    quantity: 1,
    averageEntryPrice: 100,
    grossPnl: 10,
    fees: 1,
    funding: 0,
    netPnl: netPnl,
    orderIds: const [],
    fillIds: fillIds,
    status: JournalTradeStatus.closed,
    strategy: strategy,
    notes: notes,
  );
}

void main() {
  test('preserves journal fields on sync merge', () {
    final prev = _trade(
      id: 'a',
      strategy: 'FVG',
      notes: 'Good execution',
    );
    final synced = _trade(id: 'a', netPnl: 20);
    final merged = mergeExchangeData(previous: prev, synced: synced);
    expect(merged.netPnl, 20);
    expect(merged.strategy, 'FVG');
    expect(merged.notes, 'Good execution');
  });

  test('matches by fill overlap when id changes', () {
    final prev = _trade(
      id: 'old',
      fillIds: ['f1', 'f2'],
      strategy: 'Sweep',
    );
    final synced = _trade(
      id: 'new',
      fillIds: ['f1', 'f2', 'f3'],
      netPnl: 5,
    );
    final merged = mergeAllTradesAfterSync(
      previous: [prev],
      reconstructed: [synced],
    );
    expect(merged.length, 1);
    expect(merged.first.strategy, 'Sweep');
    expect(merged.first.id, 'new');
  });

  test('preserves excursion analysis across sync', () {
    final prev = _trade(id: 'a').copyWith(
      mfe: 2.1,
      mae: -0.4,
      profitCapture: 0.5,
      entryEfficiency: 0.8,
      exitEfficiency: 0.6,
    );
    final synced = _trade(id: 'a', netPnl: 20);
    final merged = mergeExchangeData(previous: prev, synced: synced);
    expect(merged.mfe, 2.1);
    expect(merged.mae, -0.4);
    expect(merged.profitCapture, 0.5);
    expect(merged.entryEfficiency, 0.8);
    expect(merged.exitEfficiency, 0.6);
  });
}
