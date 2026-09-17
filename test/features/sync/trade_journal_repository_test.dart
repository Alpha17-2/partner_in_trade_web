import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:partner_in_trade_web/features/sync/data/trade_journal_repository.dart';
import 'package:partner_in_trade_web/features/sync/domain/normalized_fill.dart';
import 'package:partner_in_trade_web/models/journal_trade.dart';
import 'package:partner_in_trade_web/services/delta/models/delta_parse_utils.dart';

void main() {
  late Directory tempDir;
  late TradeJournalRepository repo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
    repo = TradeJournalRepository(storageKey: 'test_key');
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test('persists fills and trades', () async {
    final fill = NormalizedFill(
      fillId: 'f1',
      productId: 1,
      symbol: 'BTCUSD',
      side: DeltaSide.buy,
      size: 1,
      price: 100,
      commission: 0.5,
      timestampMicros: 123,
    );
    expect(await repo.upsertFills([fill]), 1);
    expect(await repo.upsertFills([fill]), 0);

    final loaded = await repo.loadAllFills();
    expect(loaded.length, 1);
    expect(loaded.first.fillId, 'f1');

    final trade = JournalTrade(
      id: 't1',
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
      netPnl: 9,
      orderIds: const [],
      fillIds: const ['f1'],
      status: JournalTradeStatus.closed,
    );
    await repo.saveTrades([trade]);
    final trades = await repo.loadTrades();
    expect(trades.length, 1);
    expect(trades.first.id, 't1');
  });
}
