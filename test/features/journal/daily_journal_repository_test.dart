import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:partner_in_trade_web/features/journal/data/daily_journal_repository.dart';
import 'package:partner_in_trade_web/features/journal/domain/daily_journal.dart';
import 'package:partner_in_trade_web/features/journal/domain/daily_journal_image.dart';
import 'package:partner_in_trade_web/features/sync/data/trade_journal_repository.dart';
import 'package:partner_in_trade_web/features/trades/domain/journal_trade_merge.dart';
import 'package:partner_in_trade_web/models/journal_trade.dart';

void main() {
  late Directory tempDir;
  late DailyJournalRepository repo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_journal_');
    Hive.init(tempDir.path);
    repo = DailyJournalRepository(storageKey: 'test_key');
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test('create load update reload journal', () async {
    final created = DailyJournal.blank('2026-09-18').copyWith(
      whatWentWell: 'Waited for the sweep',
      marketBias: MarketBias.bullish,
    );
    await repo.upsert(created);

    final loaded = await repo.getByDate('2026-09-18');
    expect(loaded, isNotNull);
    expect(loaded!.whatWentWell, 'Waited for the sweep');
    expect(loaded.marketBias, MarketBias.bullish);

    await repo.upsert(loaded.copyWith(whatWentWrong: 'Overtraded'));
    final reloaded = await repo.getByDate('2026-09-18');
    expect(reloaded!.whatWentWrong, 'Overtraded');
    expect(reloaded.whatWentWell, 'Waited for the sweep');
  });

  test('search journal text', () async {
    await repo.upsert(
      DailyJournal.blank('2026-09-18').copyWith(lessons: 'Liquidity sweep'),
    );
    await repo.upsert(
      DailyJournal.blank('2026-09-17').copyWith(lessons: 'Nothing here'),
    );
    final found = await repo.searchText('liquidity');
    expect(found.map((j) => j.date), ['2026-09-18']);
  });

  test('screenshot save reload delete', () async {
    final bytes = Uint8List.fromList(List<int>.generate(64, (i) => i));
    final thumb = Uint8List.fromList([1, 2, 3, 4]);
    final meta = DailyJournalImageMeta(
      id: 'img1',
      journalDate: '2026-09-18',
      createdAt: DateTime.utc(2026, 9, 18),
      fileName: 'chart.png',
      mimeType: 'image/png',
      size: bytes.length,
    );
    await repo.saveImage(meta: meta, bytes: bytes, thumbnail: thumb);

    final loadedMeta = await repo.listImages('2026-09-18');
    expect(loadedMeta.single.fileName, 'chart.png');
    expect(await repo.loadImageBytes('img1'), bytes);
    expect(await repo.loadThumbnail('img1'), thumb);

    final journal = await repo.getByDate('2026-09-18');
    expect(journal!.screenshotIds, ['img1']);

    await repo.deleteImage('2026-09-18', 'img1');
    expect(await repo.loadImageBytes('img1'), isNull);
    expect((await repo.getByDate('2026-09-18'))!.screenshotIds, isEmpty);
  });

  test('delta trade merge does not change daily journals', () async {
    await repo.upsert(
      DailyJournal.blank('2026-09-18').copyWith(generalNotes: 'keep me'),
    );
    final tradesRepo = TradeJournalRepository(storageKey: 'test_key');
    final previous = JournalTrade(
      id: 't1',
      productId: 1,
      symbol: 'BTCUSD',
      side: JournalTradeSide.long,
      entryTime: DateTime.utc(2026, 9, 18),
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
      notes: 'trade note',
    );
    final synced = previous.copyWith();
    final merged = mergeAllTradesAfterSync(
      previous: [previous],
      reconstructed: [synced],
    );
    await tradesRepo.saveTradesMerged(merged);

    final journal = await repo.getByDate('2026-09-18');
    expect(journal!.generalNotes, 'keep me');
  });
}
