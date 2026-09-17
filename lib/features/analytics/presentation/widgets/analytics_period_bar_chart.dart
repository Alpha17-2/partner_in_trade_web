import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../domain/performance_snapshot.dart';

class AnalyticsPeriodBarChart extends StatelessWidget {
  const AnalyticsPeriodBarChart({super.key, required this.rows});

  final List<PeriodPerformanceRow> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (rows.isEmpty) return const SizedBox.shrink();

    final slice = rows.length > 14 ? rows.sublist(rows.length - 14) : rows;
    final values = slice.map((r) => r.netPnl.value ?? 0).toList();
    final maxAbs = values
        .map((v) => v.abs())
        .fold<double>(0, (a, b) => a > b ? a : b);
    final maxY = maxAbs + (maxAbs * 0.1 + 1);
    final minY = -maxY;

    return SizedBox(
      height: 120,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          minY: minY,
          maxY: maxY,
          titlesData: const FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            slice.length,
            (i) {
              final v = values[i];
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    fromY: 0,
                    toY: v,
                    color: v >= 0
                        ? colors.positive.withValues(alpha: 0.75)
                        : colors.negative.withValues(alpha: 0.75),
                    width: 8,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
