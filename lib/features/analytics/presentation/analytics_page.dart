import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/page_container.dart';
import '../../../shared/widgets/pnl_text.dart';
import '../../../shared/widgets/section_header.dart';
import '../../dashboard/mock/dashboard_mock_models.dart';
import '../domain/performance_snapshot.dart';
import '../providers/analytics_providers.dart';
import 'widgets/analytics_distribution_chart.dart';
import 'widgets/analytics_drawdown_chart.dart';
import 'widgets/analytics_equity_curve_chart.dart';
import 'widgets/analytics_filter_bar.dart';
import 'widgets/analytics_period_bar_chart.dart';
import 'widgets/analytics_symbol_table.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(performanceSnapshotProvider);

    return PageContainer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(
              title: 'Analytics',
              subtitle: 'Performance from synced closed trades',
            ),
            const SizedBox(height: AppSpacing.lg),
            const AnalyticsFilterBar(),
            const SizedBox(height: AppSpacing.xl),
            _overviewMetrics(context, snap),
            if (!snap.hasCompletedTrades) ...[
              const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                child: Text(
                  'No completed trades for this period.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ] else ...[
              const SizedBox(height: AppSpacing.xl),
              ..._contentAfterOverview(context, snap),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _contentAfterOverview(BuildContext context, PerformanceSnapshot snap) {
    final s = snap.statistics;
    return [
      AppCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: AnalyticsEquityCurveChart(points: snap.equityCurve),
      ),
      const SizedBox(height: AppSpacing.xl),
      _tradeStatsGrid(context, s),
      const SizedBox(height: AppSpacing.xl),
      AppCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: AnalyticsSymbolTable(rows: snap.bySymbol),
      ),
      const SizedBox(height: AppSpacing.xl),
      _longShort(context, snap),
      const SizedBox(height: AppSpacing.xl),
      AppCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: AnalyticsDistributionChart(
          bins: snap.distribution,
          kind: snap.distributionKind,
        ),
      ),
      const SizedBox(height: AppSpacing.xl),
      _periodSection(context, 'Daily P&L', snap.dailyPerformance),
      const SizedBox(height: AppSpacing.lg),
      _periodSection(context, 'Weekly P&L', snap.weeklyPerformance),
      const SizedBox(height: AppSpacing.xl),
      _drawdownSection(context, snap),
      const SizedBox(height: AppSpacing.xl),
      _streaks(context, snap.streaks),
    ];
  }

  Widget _overviewMetrics(BuildContext context, PerformanceSnapshot snap) {
    final s = snap.statistics;
    Widget metric(String title, Widget value, IconData icon) {
      return Expanded(
        child: MetricCard(
          title: title,
          icon: icon,
          valueWidget: value,
          comparison: const MetricComparison(label: '—'),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final children = [
          metric(
            'Net P&L',
            s.netPnl.hasValue
                ? PnlText(value: s.netPnl.value!, fontSize: 20)
                : Text(s.netPnl.formatCurrency()),
            Icons.account_balance_wallet_outlined,
          ),
          metric(
            'Win Rate',
            Text(s.winRate.formatPercent()),
            Icons.percent,
          ),
          metric(
            'Profit Factor',
            Text(snap.profitFactor.formatDouble()),
            Icons.trending_up,
          ),
          metric(
            'Expectancy',
            Text(snap.expectancy.formatCurrency()),
            Icons.calculate_outlined,
          ),
          metric(
            'Average R',
            Text(snap.averageR.formatDouble()),
            Icons.show_chart,
          ),
          metric(
            'Max Drawdown',
            Text(snap.drawdown.maxDrawdown.formatCurrency()),
            Icons.trending_down,
          ),
        ];
        if (w >= 1200) {
          return Row(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.md),
                children[i],
              ],
            ],
          );
        }
        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: children
              .map((c) => SizedBox(width: (w - AppSpacing.md) / 2, child: c))
              .toList(),
        );
      },
    );
  }

  Widget _tradeStatsGrid(BuildContext context, TradeStatistics s) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Trade statistics'),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.xl,
            runSpacing: AppSpacing.md,
            children: [
              _stat('Total trades', '${s.totalTrades}'),
              _stat('Wins', '${s.winningTrades}'),
              _stat('Losses', '${s.losingTrades}'),
              _stat('Breakeven', '${s.breakevenTrades}'),
              _stat('Avg win', s.averageWinNet.formatCurrency()),
              _stat('Avg loss', s.averageLossNet.formatCurrency()),
              _stat('Largest win', s.largestWinNet.formatCurrency()),
              _stat('Largest loss', s.largestLossNet.formatCurrency()),
              _stat('Total fees', s.totalFees.formatCurrency()),
              _stat('Total funding', s.totalFunding.formatCurrency()),
              _stat('Gross P&L (ex fees)', s.totalGrossPnl.formatCurrency()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _longShort(BuildContext context, PerformanceSnapshot snap) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _sideCard('LONG', snap.longStats)),
        const SizedBox(width: AppSpacing.lg),
        Expanded(child: _sideCard('SHORT', snap.shortStats)),
      ],
    );
  }

  Widget _sideCard(String title, SidePerformanceRow row) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          Text('Trades: ${row.trades}'),
          Text('Win rate: ${row.winRate.formatPercent()}'),
          Text('Net P&L: ${row.netPnl.formatCurrency()}'),
          Text('Profit factor: ${row.profitFactor.formatDouble()}'),
          Text('Average R: ${row.averageR.formatDouble()}'),
        ],
      ),
    );
  }

  Widget _periodSection(
    BuildContext context,
    String title,
    List<PeriodPerformanceRow> rows,
  ) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title),
          const SizedBox(height: AppSpacing.md),
          AnalyticsPeriodBarChart(rows: rows),
          const SizedBox(height: AppSpacing.lg),
          ...rows.take(14).map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      SizedBox(width: 100, child: Text(r.label)),
                      Text('${r.trades} trades'),
                      const SizedBox(width: 16),
                      Text(r.netPnl.formatCurrency()),
                      const SizedBox(width: 16),
                      Text(r.winRate.formatPercent()),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _drawdownSection(BuildContext context, PerformanceSnapshot snap) {
    final d = snap.drawdown;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Drawdown'),
          const SizedBox(height: AppSpacing.md),
          Text('Max drawdown: ${d.maxDrawdown.formatCurrency()}'),
          Text('Max drawdown %: ${d.maxDrawdownPercent.formatPercent()}'),
          Text('Current drawdown: ${d.currentDrawdown.formatCurrency()}'),
          Text('Average drawdown: ${d.averageDrawdown.formatCurrency()}'),
          Text(
            'Longest drawdown period: '
            '${d.longestDrawdownPeriod?.inDays ?? 0} days',
          ),
          const SizedBox(height: AppSpacing.lg),
          AnalyticsDrawdownChart(points: snap.equityCurve),
        ],
      ),
    );
  }

  Widget _streaks(BuildContext context, StreakStats streaks) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Wrap(
        spacing: AppSpacing.xl,
        children: [
          _stat('Current win streak', '${streaks.currentWinStreak}'),
          _stat('Current loss streak', '${streaks.currentLossStreak}'),
          _stat('Longest win streak', '${streaks.longestWinStreak}'),
          _stat('Longest loss streak', '${streaks.longestLossStreak}'),
        ],
      ),
    );
  }
}
