import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../models/journal_trade.dart';
import '../../../../shared/widgets/pnl_text.dart';
import '../../application/trades_filter_sort.dart';
import '../../providers/trades_providers.dart';

class TradesDataTable extends ConsumerWidget {
  const TradesDataTable({
    super.key,
    required this.trades,
    required this.totalFiltered,
    required this.selectedId,
    required this.onSelect,
  });

  final List<JournalTrade> trades;
  final int totalFiltered;
  final String? selectedId;
  final void Function(JournalTrade trade) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final sort = ref.watch(tradesSortProvider);
    final pageState = ref.watch(tradesPageProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(context, ref, sort),
          Expanded(
            child: trades.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Text(
                        totalFiltered == 0
                            ? 'No trades match your filters.'
                            : 'No trades on this page.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: trades.length,
                    itemBuilder: (context, i) {
                      final trade = trades[i];
                      return _row(
                        context,
                        trade,
                        trade.id == selectedId,
                        onSelect,
                      );
                    },
                  ),
          ),
          _pagination(context, ref, totalFiltered, pageState),
        ],
      ),
    );
  }

  Widget _pagination(
    BuildContext context,
    WidgetRef ref,
    int total,
    TradesPageState pageState,
  ) {
    final pages = total == 0 ? 1 : (total / pageState.pageSize).ceil();
    final page = pageState.page.clamp(0, pages - 1);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Text('Page ${page + 1} of $pages ($total trades)'),
          const Spacer(),
          DropdownButton<int>(
            value: pageState.pageSize,
            items: const [
              DropdownMenuItem(value: 25, child: Text('25 / page')),
              DropdownMenuItem(value: 50, child: Text('50 / page')),
              DropdownMenuItem(value: 100, child: Text('100 / page')),
            ],
            onChanged: (v) {
              if (v != null) {
                ref.read(tradesPageProvider.notifier).state =
                    TradesPageState(page: 0, pageSize: v);
              }
            },
          ),
          IconButton(
            onPressed: page > 0
                ? () => ref.read(tradesPageProvider.notifier).state =
                    TradesPageState(page: page - 1, pageSize: pageState.pageSize)
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: page < pages - 1
                ? () => ref.read(tradesPageProvider.notifier).state =
                    TradesPageState(page: page + 1, pageSize: pageState.pageSize)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, WidgetRef ref, TradesSortState sort) {
    const cols = [
      (TradeSortColumn.date, 'Date'),
      (TradeSortColumn.symbol, 'Symbol'),
      (TradeSortColumn.side, 'Side'),
      (TradeSortColumn.strategy, 'Strategy'),
      (TradeSortColumn.entry, 'Entry'),
      (TradeSortColumn.exit, 'Exit'),
      (TradeSortColumn.quantity, 'Qty'),
      (TradeSortColumn.netPnl, 'Net P&L'),
      (TradeSortColumn.rMultiple, 'R'),
      (TradeSortColumn.duration, 'Duration'),
    ];

    return Container(
      color: context.appColors.surfaceElevated,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          for (final (col, label) in cols)
            Expanded(
              flex: col == TradeSortColumn.symbol ? 2 : 1,
              child: InkWell(
                onTap: () {
                  final nextDir = sort.column == col &&
                          sort.direction == SortDirection.desc
                      ? SortDirection.asc
                      : SortDirection.desc;
                  ref.read(tradesSortProvider.notifier).state = TradesSortState(
                    column: col,
                    direction: sort.column == col
                        ? nextDir
                        : SortDirection.desc,
                  );
                },
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    JournalTrade trade,
    bool selected,
    void Function(JournalTrade) onSelect,
  ) {
    final colors = context.appColors;
    final date = tradeDisplayDate(trade);
    final dateStr =
        '${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Material(
      color: selected
          ? colors.accent.withValues(alpha: 0.08)
          : Colors.transparent,
      child: InkWell(
        onTap: () => onSelect(trade),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colors.borderSubtle)),
          ),
          child: Row(
            children: [
              Expanded(child: Text(dateStr, style: context.monoText(fontSize: 11))),
              Expanded(
                flex: 2,
                child: Tooltip(
                  message: trade.symbol,
                  child: Text(
                    trade.symbol,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.mono(colors),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  trade.side == JournalTradeSide.long ? 'Long' : 'Short',
                  style: TextStyle(
                    fontSize: 12,
                    color: trade.side == JournalTradeSide.long
                        ? colors.positive
                        : colors.negative,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  trade.strategy ?? '—',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  trade.averageEntryPrice.toStringAsFixed(2),
                  style: context.monoText(fontSize: 11),
                ),
              ),
              Expanded(
                child: Text(
                  trade.averageExitPrice?.toStringAsFixed(2) ?? '—',
                  style: context.monoText(fontSize: 11),
                ),
              ),
              Expanded(
                child: Text(
                  trade.quantity.toStringAsFixed(2),
                  style: context.monoText(fontSize: 11),
                ),
              ),
              Expanded(child: PnlText(value: trade.netPnl)),
              Expanded(
                child: Text(
                  trade.rMultiple?.toStringAsFixed(2) ?? '—',
                  style: context.monoText(fontSize: 11),
                ),
              ),
              Expanded(
                child: Text(
                  formatTradeDuration(trade.duration),
                  style: context.monoText(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
