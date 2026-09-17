import 'analytics_date_range.dart';

enum AnalyticsSideFilter { all, long, short }

class AnalyticsFilter {
  const AnalyticsFilter({
    this.dateRange = const AnalyticsDateRange(),
    this.symbol,
    this.side = AnalyticsSideFilter.all,
  });

  final AnalyticsDateRange dateRange;
  final String? symbol;
  final AnalyticsSideFilter side;

  AnalyticsFilter copyWith({
    AnalyticsDateRange? dateRange,
    String? symbol,
    AnalyticsSideFilter? side,
    bool clearSymbol = false,
  }) {
    return AnalyticsFilter(
      dateRange: dateRange ?? this.dateRange,
      symbol: clearSymbol ? null : (symbol ?? this.symbol),
      side: side ?? this.side,
    );
  }
}
