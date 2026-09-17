import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../mock/dashboard_mock_models.dart';
import '../../../../shared/widgets/section_header.dart';

class WinLossChart extends StatelessWidget {
  const WinLossChart({super.key, required this.distribution});

  final WinLossDistribution distribution;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final total = distribution.total.toDouble();
    if (total == 0) {
      return const SizedBox.shrink();
    }

    final winPct = distribution.winRate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Win/Loss distribution'),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 12,
          child: Row(
            children: [
              if (distribution.wins > 0)
                Expanded(
                  flex: distribution.wins,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.positive.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.horizontal(
                        left: const Radius.circular(4),
                        right: distribution.losses == 0 && distribution.breakeven == 0
                            ? const Radius.circular(4)
                            : Radius.zero,
                      ),
                    ),
                  ),
                ),
              if (distribution.breakeven > 0)
                Expanded(
                  flex: distribution.breakeven,
                  child: Container(color: colors.textTertiary.withValues(alpha: 0.4)),
                ),
              if (distribution.losses > 0)
                Expanded(
                  flex: distribution.losses,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.negative.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.horizontal(
                        left: distribution.wins == 0 && distribution.breakeven == 0
                            ? const Radius.circular(4)
                            : Radius.zero,
                        right: const Radius.circular(4),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            _LegendItem(
              color: colors.positive,
              label: 'Wins',
              value: '${distribution.wins}',
            ),
            const SizedBox(width: AppSpacing.xl),
            _LegendItem(
              color: colors.negative,
              label: 'Losses',
              value: '${distribution.losses}',
            ),
            if (distribution.breakeven > 0) ...[
              const SizedBox(width: AppSpacing.xl),
              _LegendItem(
                color: colors.textTertiary,
                label: 'Breakeven',
                value: '${distribution.breakeven}',
              ),
            ],
            const Spacer(),
            Text(
              '${winPct.toStringAsFixed(1)}% win rate',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label · $value',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
