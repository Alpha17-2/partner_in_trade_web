import 'package:flutter/material.dart';

import '../../app/theme/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';
import '../../features/dashboard/mock/dashboard_mock_models.dart';
import 'app_card.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    this.value,
    this.subtitle,
    this.comparison,
    this.icon,
    this.valueWidget,
  }) : assert(value != null || valueWidget != null);

  final String title;
  final String? value;
  final Widget? valueWidget;
  final String? subtitle;
  final MetricComparison? comparison;
  final IconData? icon;

  Color _comparisonColor(BuildContext context, MetricComparison c) {
    final colors = context.appColors;
    switch (c.trend) {
      case MetricTrend.up:
        return colors.positive;
      case MetricTrend.down:
        return colors.negative;
      case MetricTrend.neutral:
        return colors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final comparisonLabel = comparison?.label ?? subtitle;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              if (icon != null)
                Icon(icon, size: 18, color: colors.textTertiary),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          valueWidget ??
              Text(
                value ?? '—',
                style: AppTextStyles.metricValue(colors),
              ),
          if (comparisonLabel != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              comparisonLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: comparison != null
                        ? _comparisonColor(context, comparison!)
                        : colors.textTertiary,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
