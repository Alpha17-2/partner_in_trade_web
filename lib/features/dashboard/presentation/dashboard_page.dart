import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/widgets.dart';
import '../mock/dashboard_mock_models.dart';
import '../providers/dashboard_providers.dart';
import 'widgets/equity_curve_chart.dart';
import 'widgets/win_loss_chart.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final equity = ref.watch(equityCurveProvider);
    final bySymbol = ref.watch(symbolPerformanceProvider);
    final byStrategy = ref.watch(strategyPerformanceProvider);
    final winLoss = ref.watch(winLossProvider);
    final recentTrades = ref.watch(recentTradesProvider);
    final colors = context.appColors;

    return PageContainer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final metricsRow = w >= 1280;

          Widget metric(String title, Widget value, MetricComparison comparison, IconData icon) {
            return MetricCard(
              title: title,
              icon: icon,
              comparison: comparison,
              valueWidget: value,
            );
          }

          final metricChildren = [
            metric(
              'Net P&L',
              PnlText(
                value: summary.netPnl,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              summary.netPnlComparison,
              Icons.account_balance_wallet_outlined,
            ),
            metric(
              'Win Rate',
              Text(
                '${summary.winRate.toStringAsFixed(1)}%',
                style: AppTextStyles.metricValue(colors),
              ),
              summary.winRateComparison,
              Icons.percent,
            ),
            metric(
              'Profit Factor',
              Text(
                summary.profitFactor.toStringAsFixed(2),
                style: AppTextStyles.metricValue(colors),
              ),
              summary.profitFactorComparison,
              Icons.trending_up,
            ),
            metric(
              'Average R',
              Text(
                summary.averageR.toStringAsFixed(2),
                style: AppTextStyles.metricValue(colors),
              ),
              summary.averageRComparison,
              Icons.show_chart,
            ),
            metric(
              'Max Drawdown',
              PnlText(
                value: summary.maxDrawdown,
                format: PnlFormat.currency,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              summary.maxDrawdownComparison,
              Icons.trending_down,
            ),
            metric(
              'Trades',
              Text(
                summary.tradeCount.toString(),
                style: AppTextStyles.metricValue(colors),
              ),
              summary.tradeCountComparison,
              Icons.numbers,
            ),
          ];

          Widget metricsSection;
          if (metricsRow) {
            metricsSection = Row(
              children: [
                for (var i = 0; i < metricChildren.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.lg),
                  Expanded(child: metricChildren[i]),
                ],
              ],
            );
          } else if (w >= 768) {
            metricsSection = Column(
              children: [
                Row(
                  children: [
                    for (var i = 0; i < 3; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.lg),
                      Expanded(child: metricChildren[i]),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    for (var i = 3; i < 6; i++) ...[
                      if (i > 3) const SizedBox(width: AppSpacing.lg),
                      Expanded(child: metricChildren[i]),
                    ],
                  ],
                ),
              ],
            );
          } else {
            metricsSection = Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.lg,
              children: metricChildren
                  .map((m) => SizedBox(width: w, child: m))
                  .toList(),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              metricsSection,
              const SizedBox(height: AppSpacing.xl),
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: EquityCurveChart(points: equity),
              ),
              const SizedBox(height: AppSpacing.xl),
              _performanceTables(context, colors, bySymbol, byStrategy, w),
              const SizedBox(height: AppSpacing.xl),
              LayoutBuilder(
                builder: (context, c) {
                  final sideBySide = c.maxWidth >= 900;
                  if (sideBySide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppCard(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: WinLossChart(distribution: winLoss),
                          ),
                        ),
                      ],
                    );
                  }
                  return AppCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: WinLossChart(distribution: winLoss),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Recent trades'),
              const SizedBox(height: AppSpacing.lg),
              TradesTable(
                trades: recentTrades,
                onTradeTap: (_) {},
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _performanceTables(
    BuildContext context,
    AppColors colors,
    List<SymbolPerformance> bySymbol,
    List<StrategyPerformance> byStrategy,
    double width,
  ) {
    final sideBySide = width >= 900;

    Widget tableSection(String title, Widget table) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(title: title),
            const SizedBox(height: AppSpacing.lg),
            table,
          ],
        ),
      );
    }

    final symbolTable = DataTableContainer(
      columns: const [
        DataTableColumn(label: 'Symbol', flex: 2),
        DataTableColumn(label: 'Trades', align: TextAlign.end),
        DataTableColumn(label: 'Win %', align: TextAlign.end),
        DataTableColumn(label: 'Net P&L', align: TextAlign.end, flex: 2),
      ],
      rows: bySymbol
          .map(
            (row) => DataTableRow(
              cells: [
                Text(
                  row.symbol,
                  style: AppTextStyles.mono(colors, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${row.trades}',
                  style: context.monoText(),
                ),
                Text(
                  '${row.winRate.toStringAsFixed(1)}%',
                  style: context.monoText(),
                ),
                PnlText(value: row.netPnl),
              ],
            ),
          )
          .toList(),
    );

    final strategyTable = DataTableContainer(
      columns: const [
        DataTableColumn(label: 'Strategy', flex: 2),
        DataTableColumn(label: 'Trades', align: TextAlign.end),
        DataTableColumn(label: 'Win %', align: TextAlign.end),
        DataTableColumn(label: 'Net P&L', align: TextAlign.end, flex: 2),
      ],
      rows: byStrategy
          .map(
            (row) => DataTableRow(
              cells: [
                Text(row.strategy),
                Text(
                  '${row.trades}',
                  style: context.monoText(),
                ),
                Text(
                  '${row.winRate.toStringAsFixed(1)}%',
                  style: context.monoText(),
                ),
                PnlText(value: row.netPnl),
              ],
            ),
          )
          .toList(),
    );

    if (sideBySide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tableSection('Performance by Symbol', symbolTable),
          const SizedBox(width: AppSpacing.xl),
          tableSection('Performance by Strategy', strategyTable),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: 'Performance by Symbol'),
        const SizedBox(height: AppSpacing.lg),
        symbolTable,
        const SizedBox(height: AppSpacing.xxl),
        SectionHeader(title: 'Performance by Strategy'),
        const SizedBox(height: AppSpacing.lg),
        strategyTable,
      ],
    );
  }
}
