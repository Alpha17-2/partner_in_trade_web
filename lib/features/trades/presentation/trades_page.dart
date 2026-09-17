import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/page_container.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../../sync/presentation/sync_panel.dart';
import '../../sync/providers/sync_providers.dart';
import '../providers/trades_providers.dart';
import 'trade_detail_panel.dart';
import 'widgets/trades_data_table.dart';
import 'widgets/trades_filter_bar.dart';

class TradesPage extends ConsumerWidget {
  const TradesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tradesAsync = ref.watch(journalTradesProvider);
    final filteredAsync = ref.watch(filteredTradesProvider);
    final pageTradesAsync = ref.watch(paginatedTradesProvider);
    final selectedId = ref.watch(selectedTradeIdProvider);
    final selected = ref.watch(selectedTradeProvider);

    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            title: 'Trades',
            subtitle: 'Journal backed by your synced Delta round trips',
          ),
          const SizedBox(height: AppSpacing.lg),
          const SyncPanel(),
          const SizedBox(height: AppSpacing.xl),
          tradesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(
              'Could not load trades from local storage: $e',
            ),
            data: (allTrades) {
              if (allTrades.isEmpty) {
                return _emptyNoTrades(context, ref);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TradesFilterBar(allTrades: allTrades),
                  const SizedBox(height: AppSpacing.lg),
                  filteredAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Filter error: $e'),
                    data: (_) {
                      final pageTrades = pageTradesAsync.value ?? [];
                      final total = ref.watch(filteredTradesCountProvider);
                      final showDetail = selected != null;

                      return SizedBox(
                        height: MediaQuery.sizeOf(context).height - 280,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: showDetail ? 3 : 1,
                              child: TradesDataTable(
                                trades: pageTrades,
                                totalFiltered: total,
                                selectedId: selectedId,
                                onSelect: (t) => ref
                                    .read(selectedTradeIdProvider.notifier)
                                    .state = t.id,
                              ),
                            ),
                            if (showDetail)
                              Expanded(
                                flex: 2,
                                child: TradeDetailPanel(
                                  key: ValueKey(selected.id),
                                  trade: selected,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _emptyNoTrades(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Text(
            'No trades yet.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Connect Delta Exchange and synchronize your account to import your trades.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'Sync Now',
            onPressed: () =>
                ref.read(syncControllerProvider.notifier).syncNow(),
          ),
        ],
      ),
    );
  }
}
