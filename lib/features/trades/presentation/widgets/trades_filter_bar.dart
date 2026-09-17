import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../models/journal_trade.dart';
import '../../application/trades_filter_sort.dart';
import '../../providers/trades_providers.dart';

class TradesFilterBar extends ConsumerWidget {
  const TradesFilterBar({
    super.key,
    required this.allTrades,
  });

  final List<JournalTrade> allTrades;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(tradesFilterProvider);
    final symbols = allTrades.map((t) => t.symbol).toSet().toList()..sort();
    final strategies = allTrades
        .map((t) => t.strategy)
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 220,
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search',
              isDense: true,
            ),
            onChanged: (v) => ref.read(tradesFilterProvider.notifier).state =
                filter.copyWith(search: v),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            final range = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 1)),
            );
            if (range != null) {
              ref.read(tradesFilterProvider.notifier).state =
                  filter.copyWith(
                startDate: range.start,
                endDate: range.end,
              );
            }
          },
          icon: const Icon(Icons.date_range, size: 18),
          label: Text(
            filter.startDate != null
                ? '${_fmt(filter.startDate!)} – ${_fmt(filter.endDate ?? filter.startDate!)}'
                : 'Date range',
          ),
        ),
        DropdownMenu<String?>(
          label: const Text('Symbol'),
          initialSelection: filter.symbol,
          dropdownMenuEntries: [
            const DropdownMenuEntry(value: null, label: 'All'),
            ...symbols.map((s) => DropdownMenuEntry(value: s, label: s)),
          ],
          onSelected: (v) => ref.read(tradesFilterProvider.notifier).state =
              filter.copyWith(symbol: v, clearSymbol: v == null),
        ),
        DropdownMenu<TradeSideFilter>(
          label: const Text('Side'),
          initialSelection: filter.side,
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: TradeSideFilter.all, label: 'All'),
            DropdownMenuEntry(value: TradeSideFilter.long, label: 'Long'),
            DropdownMenuEntry(value: TradeSideFilter.short, label: 'Short'),
          ],
          onSelected: (v) {
            if (v != null) {
              ref.read(tradesFilterProvider.notifier).state =
                  filter.copyWith(side: v);
            }
          },
        ),
        DropdownMenu<TradeOutcomeFilter>(
          label: const Text('Outcome'),
          initialSelection: filter.outcome,
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: TradeOutcomeFilter.all, label: 'All'),
            DropdownMenuEntry(
              value: TradeOutcomeFilter.winning,
              label: 'Winning',
            ),
            DropdownMenuEntry(
              value: TradeOutcomeFilter.losing,
              label: 'Losing',
            ),
          ],
          onSelected: (v) {
            if (v != null) {
              ref.read(tradesFilterProvider.notifier).state =
                  filter.copyWith(outcome: v);
            }
          },
        ),
        if (strategies.isNotEmpty)
          DropdownMenu<String?>(
            label: const Text('Strategy'),
            initialSelection: filter.strategy,
            dropdownMenuEntries: [
              const DropdownMenuEntry(value: null, label: 'All'),
              ...strategies.map((s) => DropdownMenuEntry(value: s, label: s)),
            ],
            onSelected: (v) => ref.read(tradesFilterProvider.notifier).state =
                filter.copyWith(strategy: v, clearStrategy: v == null),
          ),
        if (filter.hasActiveFilters)
          TextButton(
            onPressed: () {
              ref.read(tradesFilterProvider.notifier).state =
                  const TradesFilterState();
              ref.read(tradesPageProvider.notifier).state =
                  const TradesPageState();
            },
            child: const Text('Clear filters'),
          ),
      ],
    );
  }

  String _fmt(DateTime d) => '${d.month}/${d.day}/${d.year}';
}
