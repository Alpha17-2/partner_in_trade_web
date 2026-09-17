import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../providers/sync_providers.dart';

class SyncPanel extends ConsumerWidget {
  const SyncPanel({super.key});

  static String _relativeTime(DateTime? time) {
    if (time == null) return 'Never';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(syncControllerProvider);
    final lookback = ref.watch(syncLookbackDaysProvider);
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Trade sync',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Import fills from Delta and reconstruct round-trip trades (one row per '
          'open-to-flat round trip, not per order). Use 365-day lookback if '
          'trades look incomplete. Saved API keys restore automatically after refresh.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
        ),
        const SizedBox(height: AppSpacing.lg),
        DropdownButtonFormField<int>(
          initialValue: lookback,
          decoration: const InputDecoration(
            labelText: 'Initial lookback (first sync)',
          ),
          items: const [
            DropdownMenuItem(value: 90, child: Text('Last 90 days')),
            DropdownMenuItem(value: 365, child: Text('Last 365 days')),
          ],
          onChanged: sync.status == SyncStatus.syncing
              ? null
              : (v) {
                  if (v != null) {
                    ref.read(syncLookbackDaysProvider.notifier).state = v;
                  }
                },
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Text('Status', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(width: AppSpacing.md),
            _statusBadge(sync.status),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Last synchronized: ${_relativeTime(sync.lastSyncAt)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (sync.message != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            sync.message!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: sync.status == SyncStatus.error
                      ? colors.negative
                      : colors.textSecondary,
                ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: sync.status == SyncStatus.syncing ? 'Syncing…' : 'Sync Now',
          onPressed: sync.status == SyncStatus.syncing
              ? null
              : () => ref.read(syncControllerProvider.notifier).syncNow(),
        ),
      ],
    );
  }

  Widget _statusBadge(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return const StatusBadge(
          label: 'Syncing…',
          variant: StatusBadgeVariant.warning,
        );
      case SyncStatus.synced:
        return const StatusBadge(
          label: 'Synced',
          variant: StatusBadgeVariant.success,
        );
      case SyncStatus.error:
        return const StatusBadge(
          label: 'Error',
          variant: StatusBadgeVariant.danger,
        );
      case SyncStatus.idle:
        return const StatusBadge(
          label: 'Idle',
          variant: StatusBadgeVariant.neutral,
        );
    }
  }
}
