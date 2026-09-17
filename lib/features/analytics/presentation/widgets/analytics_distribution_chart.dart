import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/performance_snapshot.dart';

class AnalyticsDistributionChart extends StatelessWidget {
  const AnalyticsDistributionChart({
    super.key,
    required this.bins,
    required this.kind,
  });

  final List<DistributionBin> bins;
  final DistributionKind kind;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (bins.isEmpty) return const SizedBox.shrink();

    final title = kind == DistributionKind.rMultiple
        ? 'R-multiple distribution'
        : 'P&L distribution';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: title),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: bins.map((b) => b.count).reduce((a, b) => a > b ? a : b).toDouble() + 1,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, meta) {
                      final i = v.toInt();
                      if (i < 0 || i >= bins.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          bins[i].label,
                          style: const TextStyle(fontSize: 8),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(
                bins.length,
                (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: bins[i].count.toDouble(),
                      color: bins[i].midValue >= 0
                          ? colors.positive.withValues(alpha: 0.7)
                          : colors.negative.withValues(alpha: 0.7),
                      width: 12,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
