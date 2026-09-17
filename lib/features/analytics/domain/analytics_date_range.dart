import 'package:flutter/material.dart';

enum AnalyticsDatePreset {
  today,
  last7Days,
  last30Days,
  last90Days,
  thisMonth,
  previousMonth,
  thisYear,
  allTime,
  custom,
}

class AnalyticsDateRange {
  const AnalyticsDateRange({
    this.preset = AnalyticsDatePreset.last30Days,
    this.customStart,
    this.customEnd,
  });

  final AnalyticsDatePreset preset;
  final DateTime? customStart;
  final DateTime? customEnd;

  AnalyticsDateRange copyWith({
    AnalyticsDatePreset? preset,
    DateTime? customStart,
    DateTime? customEnd,
    bool clearCustom = false,
  }) {
    return AnalyticsDateRange(
      preset: preset ?? this.preset,
      customStart: clearCustom ? null : (customStart ?? this.customStart),
      customEnd: clearCustom ? null : (customEnd ?? this.customEnd),
    );
  }

  String get label {
    switch (preset) {
      case AnalyticsDatePreset.today:
        return 'Today';
      case AnalyticsDatePreset.last7Days:
        return '7D';
      case AnalyticsDatePreset.last30Days:
        return '30D';
      case AnalyticsDatePreset.last90Days:
        return '90D';
      case AnalyticsDatePreset.thisMonth:
        return 'This month';
      case AnalyticsDatePreset.previousMonth:
        return 'Previous month';
      case AnalyticsDatePreset.thisYear:
        return 'This year';
      case AnalyticsDatePreset.allTime:
        return 'All time';
      case AnalyticsDatePreset.custom:
        if (customStart != null && customEnd != null) {
          return '${customStart!.month}/${customStart!.day}–'
              '${customEnd!.month}/${customEnd!.day}';
        }
        return 'Custom';
    }
  }

  /// Inclusive local-date range for filtering by trade exit time.
  DateTimeRange resolve({DateTime? now}) {
    final n = now ?? DateTime.now();
    final endOfToday = DateTime(n.year, n.month, n.day, 23, 59, 59, 999);

    switch (preset) {
      case AnalyticsDatePreset.today:
        final start = DateTime(n.year, n.month, n.day);
        return DateTimeRange(start: start, end: endOfToday);
      case AnalyticsDatePreset.last7Days:
        return DateTimeRange(
          start: DateTime(n.year, n.month, n.day).subtract(const Duration(days: 6)),
          end: endOfToday,
        );
      case AnalyticsDatePreset.last30Days:
        return DateTimeRange(
          start: DateTime(n.year, n.month, n.day).subtract(const Duration(days: 29)),
          end: endOfToday,
        );
      case AnalyticsDatePreset.last90Days:
        return DateTimeRange(
          start: DateTime(n.year, n.month, n.day).subtract(const Duration(days: 89)),
          end: endOfToday,
        );
      case AnalyticsDatePreset.thisMonth:
        return DateTimeRange(
          start: DateTime(n.year, n.month, 1),
          end: endOfToday,
        );
      case AnalyticsDatePreset.previousMonth:
        final firstThisMonth = DateTime(n.year, n.month, 1);
        final lastPrev = firstThisMonth.subtract(const Duration(days: 1));
        return DateTimeRange(
          start: DateTime(lastPrev.year, lastPrev.month, 1),
          end: DateTime(
            lastPrev.year,
            lastPrev.month,
            lastPrev.day,
            23,
            59,
            59,
            999,
          ),
        );
      case AnalyticsDatePreset.thisYear:
        return DateTimeRange(
          start: DateTime(n.year, 1, 1),
          end: endOfToday,
        );
      case AnalyticsDatePreset.allTime:
        return DateTimeRange(
          start: DateTime(2000, 1, 1),
          end: endOfToday,
        );
      case AnalyticsDatePreset.custom:
        final start = customStart ?? DateTime(n.year, n.month, n.day);
        final end = customEnd != null
            ? DateTime(
                customEnd!.year,
                customEnd!.month,
                customEnd!.day,
                23,
                59,
                59,
                999,
              )
            : endOfToday;
        return DateTimeRange(start: start, end: end);
    }
  }
}
