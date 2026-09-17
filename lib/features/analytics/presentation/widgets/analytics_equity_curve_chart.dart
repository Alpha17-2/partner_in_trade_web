import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/performance_snapshot.dart';

class AnalyticsEquityCurveChart extends StatelessWidget {
  const AnalyticsEquityCurveChart({super.key, required this.points});

  final List<EquityCurvePoint> points;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = List.generate(
      points.length,
      (i) => FlSpot(i.toDouble(), points[i].equity),
    );
    final minY = points.map((p) => p.equity).reduce((a, b) => a < b ? a : b);
    final maxY = points.map((p) => p.equity).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY).abs() * 0.08 + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Equity curve'),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 280,
          child: LineChart(
            LineChartData(
              minY: minY - padding,
              maxY: maxY + padding,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touched) {
                    return touched.map((spot) {
                      final i = spot.x.toInt().clamp(0, points.length - 1);
                      final p = points[i];
                      return LineTooltipItem(
                        '${p.exitTime.month}/${p.exitTime.day}\n'
                        'Equity: ${p.equity.toStringAsFixed(2)}\n'
                        'Trade: ${p.tradeNetPnl.toStringAsFixed(2)}\n'
                        'DD: ${p.drawdown.toStringAsFixed(2)}',
                        TextStyle(color: colors.textPrimary, fontSize: 11),
                      );
                    }).toList();
                  },
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: colors.chartGrid, strokeWidth: 1),
              ),
              titlesData: const FlTitlesData(
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: colors.positive,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
