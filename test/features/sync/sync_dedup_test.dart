import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:partner_in_trade_web/features/sync/data/trade_journal_repository.dart';
import 'package:partner_in_trade_web/features/sync/domain/normalized_fill.dart';
import 'package:partner_in_trade_web/services/delta/models/delta_parse_utils.dart';

void main() {
  test('duplicate fill IDs are not imported twice', () async {
    final tempDir = await Directory.systemTemp.createTemp('hive_dedup_');
    Hive.init(tempDir.path);
    final repo = TradeJournalRepository(storageKey: 'dedup_key');
    final fill = NormalizedFill(
      fillId: 'same-id',
      productId: 1,
      symbol: 'BTCUSD',
      side: DeltaSide.buy,
      size: 1,
      price: 100,
      commission: 0,
      timestampMicros: 1,
    );
    expect(await repo.upsertFills([fill]), 1);
    expect(await repo.upsertFills([fill]), 0);
    expect((await repo.loadAllFills()).length, 1);
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });
}
