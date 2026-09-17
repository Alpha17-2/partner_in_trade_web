import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../mock/dashboard_mock_models.dart';
import '../../../../shared/widgets/section_header.dart';

class EquityCurveChart extends StatelessWidget {
  const EquityCurveChart({super.key, required this.points});

  final List<EquityPoint> points;

  static String _formatAxisDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = points
        .map((p) => FlSpot(p.index.toDouble(), p.equity))
        .toList();

    final minY = points.map((p) => p.equity).reduce((a, b) => a < b ? a : b);
    final maxY = points.map((p) => p.equity).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.08;

    final lineColor = points.last.equity >= points.first.equity
        ? colors.positive
        : colors.negative;

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartHeight = (constraints.maxWidth * 0.28).clamp(220.0, 360.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(title: 'Equity curve'),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: chartHeight,
              child: LineChart(
                LineChartData(
                  minY: minY - padding,
                  maxY: maxY + padding,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxY - minY) / 4,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: colors.chartGrid,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 56,
                        getTitlesWidget: (value, meta) => Text(
                          '\$${(value / 1000).toStringAsFixed(1)}k',
                          style: AppTextStyles.mono(
                            colors,
                            fontSize: 10,
                            color: colors.chartAxis,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: (points.length / 5).ceilToDouble().clamp(1, 999),
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= points.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _formatAxisDate(points[i].date),
                              style: AppTextStyles.mono(
                                colors,
                                fontSize: 10,
                                color: colors.chartAxis,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      left: BorderSide(color: colors.borderSubtle),
                      bottom: BorderSide(color: colors.borderSubtle),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => colors.surfaceElevated,
                      tooltipBorder: BorderSide(color: colors.borderSubtle),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final i = spot.x.toInt();
                          if (i < 0 || i >= points.length) {
                            return null;
                          }
                          final point = points[i];
                          final prevEquity =
                              i > 0 ? points[i - 1].equity : point.equity;
                          final sessionPnl = point.equity - prevEquity;
                          final pnlSign = sessionPnl >= 0 ? '+' : '';
                          return LineTooltipItem(
                            '${_formatAxisDate(point.date)}\n'
                            'Equity: \$${point.equity.toStringAsFixed(2)}\n'
                            'P&L: $pnlSign\$${sessionPnl.toStringAsFixed(2)}',
                            AppTextStyles.mono(
                              colors,
                              fontSize: 11,
                              color: colors.textPrimary,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.25,
                      color: lineColor,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: lineColor.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
