import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../domain/daily_journal.dart';
import '../domain/daily_journal_image.dart';

class DailyJournalRepository {
  DailyJournalRepository({required this.storageKey});

  final String storageKey;

  String get _journalsBox => '${storageKey}_daily_journals';
  String get _imageMetaBox => '${storageKey}_journal_image_meta';
  String get _imageBytesBox => '${storageKey}_journal_image_bytes';
  String get _imageThumbsBox => '${storageKey}_journal_image_thumbs';

  Future<void> _ensureOpen() async {
    if (!Hive.isBoxOpen(_journalsBox)) {
      await Hive.openBox<String>(_journalsBox);
    }
    if (!Hive.isBoxOpen(_imageMetaBox)) {
      await Hive.openBox<String>(_imageMetaBox);
    }
    if (!Hive.isBoxOpen(_imageBytesBox)) {
      await Hive.openBox<Uint8List>(_imageBytesBox);
    }
    if (!Hive.isBoxOpen(_imageThumbsBox)) {
      await Hive.openBox<Uint8List>(_imageThumbsBox);
    }
  }

  Future<DailyJournal?> getByDate(String dateKey) async {
    await _ensureOpen();
    final raw = Hive.box<String>(_journalsBox).get(dateKey);
    if (raw == null) return null;
    try {
      return DailyJournal.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e, st) {
      debugPrint('Skipped corrupt daily journal $dateKey: $e\n$st');
      return null;
    }
  }

  Future<void> upsert(DailyJournal journal) async {
    await _ensureOpen();
    await Hive.box<String>(_journalsBox).put(
      journal.date,
      jsonEncode(journal.toJson()),
    );
  }

  Future<List<DailyJournal>> loadAll() async {
    await _ensureOpen();
    final box = Hive.box<String>(_journalsBox);
    final out = <DailyJournal>[];
    for (final v in box.values) {
      try {
        out.add(DailyJournal.fromJson(jsonDecode(v) as Map<String, dynamic>));
      } catch (e, st) {
        debugPrint('Skipped corrupt daily journal: $e\n$st');
      }
    }
    return out;
  }

  Future<List<DailyJournalIndexEntry>> listIndex() async {
    final journals = await loadAll();
    return journals
        .map(
          (j) => DailyJournalIndexEntry(
            date: j.date,
            screenshotCount: j.screenshotIds.length,
            hasContent: j.hasUserContent,
          ),
        )
        .toList();
  }

  Future<List<DailyJournal>> searchText(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    final all = await loadAll();
    return all
        .where((j) => j.searchableText.toLowerCase().contains(q))
        .toList();
  }

  Future<List<DailyJournalImageMeta>> listImages(String dateKey) async {
    await _ensureOpen();
    final journal = await getByDate(dateKey);
    if (journal == null || journal.screenshotIds.isEmpty) return [];
    final box = Hive.box<String>(_imageMetaBox);
    final metas = <DailyJournalImageMeta>[];
    for (final id in journal.screenshotIds) {
      final raw = box.get(id);
      if (raw == null) continue;
      try {
        metas.add(
          DailyJournalImageMeta.fromJson(
            jsonDecode(raw) as Map<String, dynamic>,
          ),
        );
      } catch (e, st) {
        debugPrint('Skipped corrupt image meta $id: $e\n$st');
      }
    }
    return metas;
  }

  Future<Uint8List?> loadImageBytes(String id) async {
    await _ensureOpen();
    return Hive.box<Uint8List>(_imageBytesBox).get(id);
  }

  Future<Uint8List?> loadThumbnail(String id) async {
    await _ensureOpen();
    return Hive.box<Uint8List>(_imageThumbsBox).get(id);
  }

  Future<DailyJournalImageMeta> saveImage({
    required DailyJournalImageMeta meta,
    required Uint8List bytes,
    required Uint8List thumbnail,
  }) async {
    await _ensureOpen();
    var journal = await getByDate(meta.journalDate) ??
        DailyJournal.blank(meta.journalDate);
    await Hive.box<String>(_imageMetaBox).put(
      meta.id,
      jsonEncode(meta.toJson()),
    );
    await Hive.box<Uint8List>(_imageBytesBox).put(meta.id, bytes);
    await Hive.box<Uint8List>(_imageThumbsBox).put(meta.id, thumbnail);
    if (!journal.screenshotIds.contains(meta.id)) {
      journal = journal.copyWith(
        screenshotIds: [...journal.screenshotIds, meta.id],
        updatedAt: DateTime.now(),
      );
      await upsert(journal);
    }
    return meta;
  }

  Future<void> updateImageMeta(DailyJournalImageMeta meta) async {
    await _ensureOpen();
    await Hive.box<String>(_imageMetaBox).put(
      meta.id,
      jsonEncode(meta.toJson()),
    );
  }

  Future<void> deleteImage(String dateKey, String imageId) async {
    await _ensureOpen();
    final journal = await getByDate(dateKey);
    if (journal != null) {
      await upsert(
        journal.copyWith(
          screenshotIds:
              journal.screenshotIds.where((id) => id != imageId).toList(),
          updatedAt: DateTime.now(),
        ),
      );
    }
    await Hive.box<String>(_imageMetaBox).delete(imageId);
    await Hive.box<Uint8List>(_imageBytesBox).delete(imageId);
    await Hive.box<Uint8List>(_imageThumbsBox).delete(imageId);
  }
}
