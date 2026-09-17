import 'package:flutter/material.dart';

import '../../app/theme/app_text_styles.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';
import '../../models/journal_trade.dart';
import 'pnl_text.dart';
import 'status_badge.dart';

class JournalTradesTable extends StatelessWidget {
  const JournalTradesTable({
    super.key,
    required this.trades,
    this.onTradeTap,
  });

  final List<JournalTrade> trades;
  final void Function(JournalTrade trade)? onTradeTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Column(
          children: [
            _header(context),
            if (trades.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'No synced trades yet. Connect to Delta and run Sync Now.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              for (final trade in trades)
                _JournalRow(
                  trade: trade,
                  onTap: onTradeTap != null ? () => onTradeTap!(trade) : null,
                ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    const headers = [
      'Date',
      'Symbol',
      'Side',
      'Entry',
      'Exit',
      'P&L',
      'Fees',
      'Status',
    ];
    return Container(
      color: context.appColors.surfaceElevated,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          for (final h in headers)
            Expanded(
              flex: h == 'Symbol' ? 2 : 1,
              child: Text(
                h,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
        ],
      ),
    );
  }
}

class _JournalRow extends StatelessWidget {
  const _JournalRow({required this.trade, this.onTap});

  final JournalTrade trade;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final sideColor = trade.side == JournalTradeSide.long
        ? colors.positive.withValues(alpha: 0.5)
        : colors.negative.withValues(alpha: 0.5);
    final tint = trade.netPnl >= 0
        ? colors.positive.withValues(alpha: 0.04)
        : colors.negative.withValues(alpha: 0.04);

    final date = trade.exitTime ?? trade.entryTime;
    final dateStr =
        '${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    final content = Container(
      decoration: BoxDecoration(
        color: tint,
        border: Border(
          top: BorderSide(color: colors.borderSubtle),
          left: BorderSide(color: sideColor, width: 2),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(child: Text(dateStr, style: context.monoText(fontSize: 12))),
          Expanded(
            flex: 2,
            child: Text(
              trade.symbol,
              style: AppTextStyles.mono(colors, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              trade.side == JournalTradeSide.long ? 'Long' : 'Short',
              style: TextStyle(
                color: trade.side == JournalTradeSide.long
                    ? colors.positive
                    : colors.negative,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              trade.averageEntryPrice.toStringAsFixed(2),
              style: context.monoText(),
            ),
          ),
          Expanded(
            child: Text(
              trade.averageExitPrice?.toStringAsFixed(2) ?? '—',
              style: context.monoText(),
            ),
          ),
          Expanded(child: PnlText(value: trade.netPnl)),
          Expanded(
            child: Text(
              trade.fees.toStringAsFixed(2),
              style: context.monoText(),
            ),
          ),
          Expanded(
            child: StatusBadge(
              label: trade.status == JournalTradeStatus.open ? 'Open' : 'Closed',
              variant: trade.status == JournalTradeStatus.open
                  ? StatusBadgeVariant.warning
                  : StatusBadgeVariant.neutral,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }
}
