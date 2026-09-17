import 'package:flutter_test/flutter_test.dart';
import 'package:partner_in_trade_web/features/analytics/application/trade_analytics_service.dart';
import 'package:partner_in_trade_web/features/analytics/application/trade_insights_service.dart';
import 'package:partner_in_trade_web/features/analytics/domain/analytics_date_range.dart';
import 'package:partner_in_trade_web/features/analytics/domain/analytics_filter.dart';
import 'package:partner_in_trade_web/models/journal_trade.dart';

JournalTrade _t({
  required String id,
  required double netPnl,
  double fees = 2,
  double? mfe,
  double? mae,
  double? rMultiple,
  double? profitCapture,
}) {
  return JournalTrade(
    id: id,
    productId: 1,
    symbol: 'BTCUSD',
    side: JournalTradeSide.long,
    entryTime: DateTime(2026, 9, 18, 10),
    exitTime: DateTime(2026, 9, 18, 11),
    entryPrice: 100,
    quantity: 1,
    averageEntryPrice: 100,
    grossPnl: netPnl + fees,
    fees: fees,
    funding: 0,
    netPnl: netPnl,
    orderIds: const [],
    fillIds: [id],
    status: JournalTradeStatus.closed,
    mfe: mfe,
    mae: mae,
    rMultiple: rMultiple,
    profitCapture: profitCapture,
  );
}

void main() {
  test('insights are derived from actual trade numbers', () {
    final trades = [
      _t(id: '1', netPnl: 10, profitCapture: 0.5, mfe: 4, rMultiple: 0.8),
      _t(id: '2', netPnl: 8, profitCapture: 0.3, mfe: 3, rMultiple: 0.5),
      _t(
        id: '3',
        netPnl: -5,
        mae: -1.1,
        mfe: 0.2,
        rMultiple: -1,
        profitCapture: 0,
      ),
    ];
    final snap = TradeAnalyticsService().compute(
      trades,
      const AnalyticsFilter(
        dateRange: AnalyticsDateRange(preset: AnalyticsDatePreset.allTime),
      ),
      initialEquity: 0,
    );
    final lines = TradeInsightsService().observations(
      trades: trades,
      snapshot: snap,
    );
    expect(
      lines.any((l) => l.contains('3 trades') && l.contains('27%')),
      isTrue,
    );
    expect(
      lines.any((l) => l.contains('2 trades moved more than +2R')),
      isTrue,
    );
    expect(
      lines.any((l) => l.contains('Average MAE on losing trades was -1.1R')),
      isTrue,
    );
    expect(lines.any((l) => l.contains('Trading fees represented')), isTrue);
  });
}
