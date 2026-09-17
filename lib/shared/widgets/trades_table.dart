import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';
import '../../features/dashboard/mock/dashboard_mock_models.dart';
import 'pnl_text.dart';
import 'status_badge.dart';

class TradesTable extends StatelessWidget {
  const TradesTable({
    super.key,
    required this.trades,
    this.onTradeTap,
  });

  final List<MockTrade> trades;
  final void Function(MockTrade trade)? onTradeTap;

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, $h:$m';
  }

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
            _HeaderRow(colors: colors),
            if (trades.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'No trades',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              for (final trade in trades)
                _TradeRow(
                  trade: trade,
                  onTap: onTradeTap != null ? () => onTradeTap!(trade) : null,
                ),
          ],
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    const headers = [
      _Col('Date', 2),
      _Col('Symbol', 1),
      _Col('Side', 1),
      _Col('Strategy', 2),
      _Col('Entry', 1, end: true),
      _Col('Exit', 1, end: true),
      _Col('P&L', 1, end: true),
      _Col('R', 1, end: true),
      _Col('Status', 1),
    ];

    return Container(
      color: colors.surfaceElevated,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          for (final h in headers)
            Expanded(
              flex: h.flex,
              child: Text(
                h.label,
                textAlign: h.end ? TextAlign.end : TextAlign.start,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
        ],
      ),
    );
  }
}

class _Col {
  const _Col(this.label, this.flex, {this.end = false});
  final String label;
  final int flex;
  final bool end;
}

class _TradeRow extends StatelessWidget {
  const _TradeRow({required this.trade, this.onTap});

  final MockTrade trade;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final sideColor = trade.side == TradeSide.long
        ? colors.positive.withValues(alpha: 0.5)
        : colors.negative.withValues(alpha: 0.5);
    final pnlTint = trade.pnl >= 0
        ? colors.positive.withValues(alpha: 0.04)
        : colors.negative.withValues(alpha: 0.04);

    Widget cell(Widget child, {int flex = 1, bool end = false}) {
      return Expanded(
        flex: flex,
        child: Align(
          alignment: end ? Alignment.centerRight : Alignment.centerLeft,
          child: child,
        ),
      );
    }

    final content = Container(
      decoration: BoxDecoration(
        color: pnlTint,
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
          cell(
            Text(
              TradesTable._formatDate(trade.date),
              style: context.monoText(fontSize: 12),
            ),
            flex: 2,
          ),
          cell(
            Text(
              trade.symbol,
              style: AppTextStyles.mono(colors, fontWeight: FontWeight.w500),
            ),
          ),
          cell(
            Text(
              trade.side == TradeSide.long ? 'Long' : 'Short',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: trade.side == TradeSide.long
                        ? colors.positive
                        : colors.negative,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          cell(Text(trade.strategy, overflow: TextOverflow.ellipsis), flex: 2),
          cell(Text(_formatPrice(trade.entry), style: context.monoText()), end: true),
          cell(
            Text(
              trade.exit != null ? _formatPrice(trade.exit!) : '—',
              style: context.monoText(),
            ),
            end: true,
          ),
          cell(PnlText(value: trade.pnl), end: true),
          cell(
            Text(
              trade.rMultiple.toStringAsFixed(2),
              style: context.monoText(
                color: trade.rMultiple >= 0 ? colors.positive : colors.negative,
              ),
            ),
            end: true,
          ),
          cell(_statusBadge(trade.status)),
        ],
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: colors.sidebarHover.withValues(alpha: 0.5),
        child: content,
      ),
    );
  }

  String _formatPrice(double value) {
    if (value < 10) return value.toStringAsFixed(4);
    return value.toStringAsFixed(2);
  }

  Widget _statusBadge(TradeStatus status) {
    switch (status) {
      case TradeStatus.open:
        return const StatusBadge(
          label: 'Open',
          variant: StatusBadgeVariant.warning,
        );
      case TradeStatus.closed:
        return const StatusBadge(
          label: 'Closed',
          variant: StatusBadgeVariant.neutral,
        );
      case TradeStatus.cancelled:
        return const StatusBadge(
          label: 'Cancelled',
          variant: StatusBadgeVariant.danger,
        );
    }
  }
}
