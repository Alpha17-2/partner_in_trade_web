import '../../../models/journal_trade.dart';
import '../domain/analytics_filter.dart';

List<JournalTrade> applyAnalyticsFilter(
  List<JournalTrade> trades,
  AnalyticsFilter filter, {
  DateTime? now,
}) {
  final range = filter.dateRange.resolve(now: now);
  return trades.where((t) {
    if (t.status != JournalTradeStatus.closed || t.exitTime == null) {
      return false;
    }
    final exit = t.exitTime!;
    if (exit.isBefore(range.start) || exit.isAfter(range.end)) return false;
    if (filter.symbol != null && filter.symbol!.isNotEmpty) {
      if (t.symbol != filter.symbol) return false;
    }
    if (filter.side == AnalyticsSideFilter.long &&
        t.side != JournalTradeSide.long) {
      return false;
    }
    if (filter.side == AnalyticsSideFilter.short &&
        t.side != JournalTradeSide.short) {
      return false;
    }
    return true;
  }).toList();
}

List<JournalTrade> sortByExitTime(List<JournalTrade> trades) {
  final list = List<JournalTrade>.from(trades);
  list.sort((a, b) {
    final ae = a.exitTime!;
    final be = b.exitTime!;
    final c = ae.compareTo(be);
    if (c != 0) return c;
    return a.id.compareTo(b.id);
  });
  return list;
}
