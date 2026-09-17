import '../../../models/journal_trade.dart';

enum TradeSideFilter { all, long, short }

enum TradeOutcomeFilter { all, winning, losing }

enum TradeSortColumn {
  date,
  symbol,
  side,
  strategy,
  entry,
  exit,
  quantity,
  netPnl,
  rMultiple,
  duration,
}

enum SortDirection { asc, desc }

class TradesFilterState {
  const TradesFilterState({
    this.search = '',
    this.startDate,
    this.endDate,
    this.symbol,
    this.side = TradeSideFilter.all,
    this.outcome = TradeOutcomeFilter.all,
    this.strategy,
  });

  final String search;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? symbol;
  final TradeSideFilter side;
  final TradeOutcomeFilter outcome;
  final String? strategy;

  TradesFilterState copyWith({
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    String? symbol,
    TradeSideFilter? side,
    TradeOutcomeFilter? outcome,
    String? strategy,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearSymbol = false,
    bool clearStrategy = false,
  }) {
    return TradesFilterState(
      search: search ?? this.search,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      symbol: clearSymbol ? null : (symbol ?? this.symbol),
      side: side ?? this.side,
      outcome: outcome ?? this.outcome,
      strategy: clearStrategy ? null : (strategy ?? this.strategy),
    );
  }

  bool get hasActiveFilters =>
      search.isNotEmpty ||
      startDate != null ||
      endDate != null ||
      symbol != null ||
      side != TradeSideFilter.all ||
      outcome != TradeOutcomeFilter.all ||
      strategy != null;
}

class TradesSortState {
  const TradesSortState({
    this.column = TradeSortColumn.date,
    this.direction = SortDirection.desc,
  });

  final TradeSortColumn column;
  final SortDirection direction;
}

DateTime tradeDisplayDate(JournalTrade t) => t.exitTime ?? t.entryTime;

List<JournalTrade> filterTrades(
  List<JournalTrade> trades,
  TradesFilterState filter,
) {
  final q = filter.search.trim().toLowerCase();
  return trades.where((t) {
    if (q.isNotEmpty) {
      final haystack = [
        t.symbol,
        t.strategy ?? '',
        t.setup ?? '',
        t.notes ?? '',
        ...t.tags,
      ].join(' ').toLowerCase();
      if (!haystack.contains(q)) return false;
    }
    final date = tradeDisplayDate(t);
    if (filter.startDate != null && date.isBefore(filter.startDate!)) {
      return false;
    }
    if (filter.endDate != null) {
      final end = DateTime(
        filter.endDate!.year,
        filter.endDate!.month,
        filter.endDate!.day,
        23,
        59,
        59,
      );
      if (date.isAfter(end)) return false;
    }
    if (filter.symbol != null &&
        filter.symbol!.isNotEmpty &&
        t.symbol != filter.symbol) {
      return false;
    }
    if (filter.side == TradeSideFilter.long &&
        t.side != JournalTradeSide.long) {
      return false;
    }
    if (filter.side == TradeSideFilter.short &&
        t.side != JournalTradeSide.short) {
      return false;
    }
    if (filter.outcome == TradeOutcomeFilter.winning && t.netPnl <= 0) {
      return false;
    }
    if (filter.outcome == TradeOutcomeFilter.losing && t.netPnl >= 0) {
      return false;
    }
    if (filter.strategy != null &&
        filter.strategy!.isNotEmpty &&
        (t.strategy ?? '') != filter.strategy) {
      return false;
    }
    return true;
  }).toList();
}

int _compareNum(double? a, double? b) {
  final av = a ?? 0;
  final bv = b ?? 0;
  return av.compareTo(bv);
}

List<JournalTrade> sortTrades(
  List<JournalTrade> trades,
  TradesSortState sort,
) {
  final list = List<JournalTrade>.from(trades);
  final dir = sort.direction == SortDirection.asc ? 1 : -1;

  list.sort((a, b) {
    int cmp;
    switch (sort.column) {
      case TradeSortColumn.date:
        cmp = tradeDisplayDate(a).compareTo(tradeDisplayDate(b));
      case TradeSortColumn.symbol:
        cmp = a.symbol.compareTo(b.symbol);
      case TradeSortColumn.side:
        cmp = a.side.name.compareTo(b.side.name);
      case TradeSortColumn.strategy:
        cmp = (a.strategy ?? '').compareTo(b.strategy ?? '');
      case TradeSortColumn.entry:
        cmp = a.averageEntryPrice.compareTo(b.averageEntryPrice);
      case TradeSortColumn.exit:
        cmp = _compareNum(a.averageExitPrice, b.averageExitPrice);
      case TradeSortColumn.quantity:
        cmp = a.quantity.compareTo(b.quantity);
      case TradeSortColumn.netPnl:
        cmp = a.netPnl.compareTo(b.netPnl);
      case TradeSortColumn.rMultiple:
        cmp = _compareNum(a.rMultiple, b.rMultiple);
      case TradeSortColumn.duration:
        final ad = a.duration?.inSeconds ?? 0;
        final bd = b.duration?.inSeconds ?? 0;
        cmp = ad.compareTo(bd);
    }
    return cmp * dir;
  });
  return list;
}

String formatTradeDuration(Duration? d) {
  if (d == null) return '—';
  if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
  if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
  return '${d.inMinutes}m';
}
