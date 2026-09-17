import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/app_ui_providers.dart';
import '../../features/settings/providers/delta_connection_provider.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';

enum DeltaConnectionDisplay { compact, verbose }

class DeltaConnectionChip extends ConsumerWidget {
  const DeltaConnectionChip({
    super.key,
    this.display = DeltaConnectionDisplay.compact,
  });

  final DeltaConnectionDisplay display;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(deltaConnectionProvider);
    final colors = context.appColors;

    final (label, dotColor) = switch (status) {
      DeltaConnectionStatus.notConnected =>
        ('Not Connected', colors.textTertiary),
      DeltaConnectionStatus.connected => ('Connected', colors.positive),
      DeltaConnectionStatus.error => ('Error', colors.negative),
    };

    if (display == DeltaConnectionDisplay.verbose) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delta Exchange',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Connection status',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              _StatusDot(color: dotColor),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.badge),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusDot(color: dotColor),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
