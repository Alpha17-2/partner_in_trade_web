import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/app_ui_providers.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';
import 'delta_connection_chip.dart';
import 'secondary_button.dart';

class AppHeader extends ConsumerWidget {
  const AppHeader({
    super.key,
    this.title,
    this.trailing,
    this.onMenuPressed,
    this.onRefresh,
  });

  final String? title;
  final Widget? trailing;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final dateRange = ref.watch(dashboardDateRangeProvider);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(bottom: BorderSide(color: colors.borderSubtle)),
      ),
      child: Row(
        children: [
          if (onMenuPressed != null)
            IconButton(
              onPressed: onMenuPressed,
              icon: const Icon(Icons.menu),
              tooltip: 'Menu',
            ),
          if (title != null)
            Text(
              title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          const Spacer(),
          PopupMenuButton<DashboardDateRangePreset>(
            tooltip: 'Date range',
            offset: const Offset(0, 40),
            onSelected: (preset) {
              ref.read(dashboardDateRangeProvider.notifier).state = preset;
            },
            itemBuilder: (context) => DashboardDateRangePreset.values
                .map(
                  (p) => PopupMenuItem(
                    value: p,
                    child: Text(p.label),
                  ),
                )
                .toList(),
            child: IgnorePointer(
              child: SecondaryButton(
                label: dateRange.label,
                onPressed: () {},
                icon: Icons.calendar_today_outlined,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Refresh',
            color: colors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.md),
          const DeltaConnectionChip(),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}
