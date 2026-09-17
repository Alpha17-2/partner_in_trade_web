import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/journal_trades_table.dart';
import '../../../shared/widgets/page_container.dart';
import '../../../shared/widgets/section_header.dart';
import '../../sync/presentation/sync_panel.dart';
import '../../sync/providers/sync_providers.dart';

class TradesPage extends ConsumerWidget {
  const TradesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tradesAsync = ref.watch(journalTradesProvider);

    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            title: 'Trades',
            subtitle:
                'P&L uses Delta realized cashflow on close; fees/funding from fill snapshots',
          ),
          const SizedBox(height: AppSpacing.xl),
          const SyncPanel(),
          const SizedBox(height: AppSpacing.xxl),
          tradesAsync.when(
            data: (trades) {
              final sorted = List.of(trades)
                ..sort((a, b) => b.entryTime.compareTo(a.entryTime));
              return JournalTradesTable(
                trades: sorted,
                onTradeTap: (_) {},
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Failed to load trades: $e'),
          ),
        ],
      ),
    );
  }
}
