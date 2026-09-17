import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/journal_trade.dart';
import '../../analytics/domain/analytics_date_range.dart';
import '../../analytics/domain/analytics_filter.dart';
import '../../analytics/domain/performance_snapshot.dart';
import '../../analytics/providers/analytics_providers.dart';
import '../../settings/providers/delta_connection_provider.dart';
import '../../trades/providers/trades_providers.dart';
import '../application/journal_date.dart';
import '../application/trades_for_date.dart';
import '../data/daily_journal_repository.dart';
import '../domain/daily_journal.dart';
import '../domain/daily_journal_image.dart';

Future<String> resolveDailyJournalStorageKey(Ref ref) async {
  return await resolveJournalStorageKey(ref) ?? 'local_unlinked';
}

final dailyJournalRepositoryProvider =
    FutureProvider<DailyJournalRepository>((ref) async {
  ref.watch(deltaCredentialsVersionProvider);
  ref.watch(journalTradesRevisionProvider);
  final key = await resolveDailyJournalStorageKey(ref);
  return DailyJournalRepository(storageKey: key);
});

final dailyJournalIndexProvider =
    FutureProvider<List<DailyJournalIndexEntry>>((ref) async {
  ref.watch(dailyJournalRevisionProvider);
  final repo = await ref.watch(dailyJournalRepositoryProvider.future);
  return repo.listIndex();
});

final dailyJournalRevisionProvider = StateProvider<int>((ref) => 0);

class CalendarMonthState {
  CalendarMonthState({DateTime? visibleMonth})
      : visibleMonth = DateTime(
          (visibleMonth ?? DateTime.now()).year,
          (visibleMonth ?? DateTime.now()).month,
        );

  final DateTime visibleMonth;

  CalendarMonthState copyWith({DateTime? visibleMonth}) {
    return CalendarMonthState(visibleMonth: visibleMonth ?? this.visibleMonth);
  }
}

final journalCalendarMonthProvider =
    StateProvider<CalendarMonthState>((ref) => CalendarMonthState());

final journalSearchQueryProvider = StateProvider<String>((ref) => '');

final journalSearchResultsProvider =
    FutureProvider<List<DailyJournal>>((ref) async {
  final q = ref.watch(journalSearchQueryProvider);
  if (q.trim().isEmpty) return [];
  final repo = await ref.watch(dailyJournalRepositoryProvider.future);
  return repo.searchText(q);
});

class JournalDaySummary {
  const JournalDaySummary({
    required this.dateKey,
    required this.tradeCount,
    required this.netPnl,
    required this.hasJournal,
    required this.screenshotCount,
    this.winRate,
  });

  final String dateKey;
  final int tradeCount;
  final double netPnl;
  final bool hasJournal;
  final int screenshotCount;
  final double? winRate;
}

final journalMonthSummariesProvider =
    Provider<Map<String, JournalDaySummary>>((ref) {
  final month = ref.watch(journalCalendarMonthProvider).visibleMonth;
  final trades = ref.watch(journalTradesProvider).valueOrNull ?? [];
  final index = ref.watch(dailyJournalIndexProvider).valueOrNull ?? [];
  final indexByDate = {for (final e in index) e.date: e};

  final start = DateTime(month.year, month.month, 1);
  final end = DateTime(month.year, month.month + 1, 0);
  final service = ref.watch(tradeAnalyticsServiceProvider);
  final snap = service.compute(
    trades,
    AnalyticsFilter(
      dateRange: AnalyticsDateRange(
        preset: AnalyticsDatePreset.custom,
        customStart: start,
        customEnd: end,
      ),
    ),
    initialEquity: 0,
  );
  final byPeriod = {
    for (final row in snap.dailyPerformance)
      localDateKey(row.periodStart): row,
  };

  final map = <String, JournalDaySummary>{};
  for (var day = 1; day <= end.day; day++) {
    final date = DateTime(month.year, month.month, day);
    final key = localDateKey(date);
    final dayTrades = tradesForLocalDate(trades, key);
    final period = byPeriod[key];
    final idx = indexByDate[key];
    map[key] = JournalDaySummary(
      dateKey: key,
      tradeCount: dayTrades.length,
      netPnl: period?.netPnl.value ??
          dayTrades.fold<double>(0, (s, t) => s + t.netPnl),
      hasJournal: idx?.hasContent ?? false,
      screenshotCount: idx?.screenshotCount ?? 0,
      winRate: period?.winRate.value,
    );
  }
  return map;
});

final dailyJournalProvider =
    FutureProvider.family<DailyJournal, String>((ref, dateKey) async {
  ref.watch(dailyJournalRevisionProvider);
  final repo = await ref.watch(dailyJournalRepositoryProvider.future);
  return await repo.getByDate(dateKey) ?? DailyJournal.blank(dateKey);
});

final dailyJournalImagesProvider =
    FutureProvider.family<List<DailyJournalImageMeta>, String>(
        (ref, dateKey) async {
  ref.watch(dailyJournalRevisionProvider);
  final repo = await ref.watch(dailyJournalRepositoryProvider.future);
  return repo.listImages(dateKey);
});

final journalThumbnailProvider =
    FutureProvider.family<Uint8List?, String>((ref, id) async {
  final repo = await ref.watch(dailyJournalRepositoryProvider.future);
  return repo.loadThumbnail(id);
});

final journalImageBytesProvider =
    FutureProvider.family<Uint8List?, String>((ref, id) async {
  final repo = await ref.watch(dailyJournalRepositoryProvider.future);
  return repo.loadImageBytes(id);
});

final tradesForDateProvider = Provider.family<List<JournalTrade>, String>(
  (ref, dateKey) {
    final trades = ref.watch(journalTradesProvider).valueOrNull ?? [];
    return tradesForLocalDate(trades, dateKey);
  },
);

final dayPerformanceProvider =
    Provider.family<PerformanceSnapshot, String>((ref, dateKey) {
  final date = parseDateKey(dateKey);
  final trades = ref.watch(journalTradesProvider).valueOrNull ?? [];
  final service = ref.watch(tradeAnalyticsServiceProvider);
  if (date == null) return PerformanceSnapshot.empty();
  return service.compute(
    trades,
    AnalyticsFilter(
      dateRange: AnalyticsDateRange(
        preset: AnalyticsDatePreset.custom,
        customStart: date,
        customEnd: date,
      ),
    ),
    initialEquity: 0,
  );
});

enum DailyJournalSaveStatus { idle, saving, saved, error }

class DailyJournalSaveState {
  const DailyJournalSaveState({
    this.status = DailyJournalSaveStatus.idle,
    this.message,
  });

  final DailyJournalSaveStatus status;
  final String? message;
}

class DailyJournalEditController extends Notifier<DailyJournalSaveState> {
  Timer? _debounce;

  @override
  DailyJournalSaveState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const DailyJournalSaveState();
  }

  void scheduleSave(DailyJournal journal) {
    _debounce?.cancel();
    state = const DailyJournalSaveState(status: DailyJournalSaveStatus.saving);
    _debounce = Timer(const Duration(milliseconds: 750), () {
      _persist(journal);
    });
  }

  Future<void> saveNow(DailyJournal journal) => _persist(journal);

  Future<void> _persist(DailyJournal journal) async {
    try {
      final repo = await ref.read(dailyJournalRepositoryProvider.future);
      final next = journal.copyWith(updatedAt: DateTime.now());
      await repo.upsert(next);
      ref.read(dailyJournalRevisionProvider.notifier).state++;
      state = const DailyJournalSaveState(status: DailyJournalSaveStatus.saved);
    } catch (e) {
      state = DailyJournalSaveState(
        status: DailyJournalSaveStatus.error,
        message: e.toString(),
      );
    }
  }
}

final dailyJournalEditControllerProvider =
    NotifierProvider<DailyJournalEditController, DailyJournalSaveState>(
  DailyJournalEditController.new,
);
