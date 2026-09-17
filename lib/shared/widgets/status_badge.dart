import 'package:flutter/material.dart';

import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';

enum StatusBadgeVariant { success, danger, warning, neutral }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.variant = StatusBadgeVariant.neutral,
  });

  final String label;
  final StatusBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final (bg, fg) = switch (variant) {
      StatusBadgeVariant.success => (
          colors.positive.withValues(alpha: 0.15),
          colors.positive,
        ),
      StatusBadgeVariant.danger => (
          colors.negative.withValues(alpha: 0.15),
          colors.negative,
        ),
      StatusBadgeVariant.warning => (
          colors.warning.withValues(alpha: 0.15),
          colors.warning,
        ),
      StatusBadgeVariant.neutral => (
          colors.borderSubtle,
          colors.textSecondary,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.badge),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
