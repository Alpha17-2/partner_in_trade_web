import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../models/journal_trade.dart';

/// Entry/exit visualization stub — Plan 9 will add candles, partials, SL/TP, MFE/MAE.
class TradeChart extends StatelessWidget {
  const TradeChart({
    super.key,
    required this.trade,
  });

  final JournalTrade trade;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final exitPrice = trade.averageExitPrice ?? trade.entryPrice;
    final minY = [trade.averageEntryPrice, exitPrice].reduce((a, b) => a < b ? a : b);
    final maxY = [trade.averageEntryPrice, exitPrice].reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY).abs() * 0.15 + 1;

    final start = trade.entryTime.millisecondsSinceEpoch.toDouble();
    final end = (trade.exitTime ?? trade.entryTime).millisecondsSinceEpoch.toDouble();
    final mid = (start + end) / 2;

    return Container(
      height: 160,
      decoration: BoxDecoration(
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: LineChart(
        LineChartData(
          minX: start,
          maxX: end == start ? start + 1 : end,
          minY: minY - padding,
          maxY: maxY + padding,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: padding > 0 ? padding : 1,
            getDrawingHorizontalLine: (_) => FlLine(
              color: colors.borderSubtle,
              strokeWidth: 1,
            ),
          ),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(start, trade.averageEntryPrice),
                FlSpot(mid, trade.averageEntryPrice),
                FlSpot(end, exitPrice),
              ],
              isCurved: false,
              color: colors.textSecondary.withValues(alpha: 0.5),
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
          ],
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: trade.averageEntryPrice,
                color: colors.positive.withValues(alpha: 0.7),
                strokeWidth: 1.5,
                dashArray: [4, 4],
                label: HorizontalLineLabel(
                  show: true,
                  labelResolver: (_) => 'Entry',
                  style: TextStyle(fontSize: 10, color: colors.positive),
                ),
              ),
              if (trade.averageExitPrice != null)
                HorizontalLine(
                  y: trade.averageExitPrice!,
                  color: colors.negative.withValues(alpha: 0.7),
                  strokeWidth: 1.5,
                  dashArray: [4, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    labelResolver: (_) => 'Exit',
                    style: TextStyle(fontSize: 10, color: colors.negative),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
