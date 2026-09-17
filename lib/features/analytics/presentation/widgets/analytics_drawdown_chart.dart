import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/performance_snapshot.dart';

/// Drawdown over time as negative percent from peak (0% at peak).
class AnalyticsDrawdownChart extends StatelessWidget {
  const AnalyticsDrawdownChart({super.key, required this.points});

  final List<EquityCurvePoint> points;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (points.isEmpty) return const SizedBox.shrink();

    final spots = List.generate(
      points.length,
      (i) => FlSpot(i.toDouble(), -points[i].drawdownPercent),
    );
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final padding = minY.abs() * 0.08 + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Drawdown %'),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minY: minY - padding,
              maxY: padding,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: false,
                  color: colors.negative,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: colors.negative.withValues(alpha: 0.12),
                  ),
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (v, _) => Text(
                      '${v.toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: minY.abs() > 0 ? minY.abs() / 4 : 1,
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }
}
