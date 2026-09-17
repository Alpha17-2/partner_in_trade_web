import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../trades/providers/trades_providers.dart';
import '../../domain/analytics_date_range.dart';
import '../../domain/analytics_filter.dart';
import '../../providers/analytics_providers.dart';

class AnalyticsFilterBar extends ConsumerWidget {
  const AnalyticsFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(analyticsFilterProvider);
    final trades = ref.watch(journalTradesProvider).valueOrNull ?? [];
    final symbols = trades.map((t) => t.symbol).toSet().toList()..sort();

    void setPreset(AnalyticsDatePreset p) {
      ref.read(analyticsFilterProvider.notifier).state = filter.copyWith(
        dateRange: AnalyticsDateRange(preset: p),
      );
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final p in [
          AnalyticsDatePreset.today,
          AnalyticsDatePreset.last7Days,
          AnalyticsDatePreset.last30Days,
          AnalyticsDatePreset.thisMonth,
          AnalyticsDatePreset.previousMonth,
          AnalyticsDatePreset.thisYear,
          AnalyticsDatePreset.allTime,
        ])
          ChoiceChip(
            label: Text(_presetLabel(p)),
            selected: filter.dateRange.preset == p,
            onSelected: (_) => setPreset(p),
          ),
        ActionChip(
          label: const Text('Custom'),
          onPressed: () async {
            final range = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 1)),
            );
            if (range != null) {
              ref.read(analyticsFilterProvider.notifier).state =
                  filter.copyWith(
                dateRange: AnalyticsDateRange(
                  preset: AnalyticsDatePreset.custom,
                  customStart: range.start,
                  customEnd: range.end,
                ),
              );
            }
          },
        ),
        if (symbols.isNotEmpty)
          DropdownMenu<String?>(
            label: const Text('Symbol'),
            initialSelection: filter.symbol,
            dropdownMenuEntries: [
              const DropdownMenuEntry(value: null, label: 'All'),
              ...symbols.map((s) => DropdownMenuEntry(value: s, label: s)),
            ],
            onSelected: (v) => ref.read(analyticsFilterProvider.notifier).state =
                filter.copyWith(symbol: v, clearSymbol: v == null),
          ),
        DropdownMenu<AnalyticsSideFilter>(
          label: const Text('Side'),
          initialSelection: filter.side,
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: AnalyticsSideFilter.all, label: 'All'),
            DropdownMenuEntry(value: AnalyticsSideFilter.long, label: 'Long'),
            DropdownMenuEntry(value: AnalyticsSideFilter.short, label: 'Short'),
          ],
          onSelected: (v) {
            if (v != null) {
              ref.read(analyticsFilterProvider.notifier).state =
                  filter.copyWith(side: v);
            }
          },
        ),
      ],
    );
  }

  String _presetLabel(AnalyticsDatePreset p) {
    switch (p) {
      case AnalyticsDatePreset.today:
        return 'Today';
      case AnalyticsDatePreset.last7Days:
        return '7D';
      case AnalyticsDatePreset.last30Days:
        return '30D';
      case AnalyticsDatePreset.last90Days:
        return '90D';
      default:
        return AnalyticsDateRange(preset: p).label;
    }
  }
}
