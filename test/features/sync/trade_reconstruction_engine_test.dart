import 'package:flutter_test/flutter_test.dart';
import 'package:partner_in_trade_web/features/sync/domain/normalized_fill.dart';
import 'package:partner_in_trade_web/features/sync/engine/trade_reconstruction_engine.dart';
import 'package:partner_in_trade_web/models/journal_trade.dart';
import 'package:partner_in_trade_web/services/delta/models/delta_parse_utils.dart';

void main() {
  final engine = TradeReconstructionEngine();

  NormalizedFill fill({
    required String id,
    required DeltaSide side,
    required double size,
    required double price,
    int ts = 1000,
    double? pnl,
    double? cashflow,
    double? funding,
    double? totalCommissionPaid,
    int? positionSizeAfter,
  }) {
    return NormalizedFill(
      fillId: id,
      productId: 1,
      symbol: 'BTCUSD',
      side: side,
      size: size,
      price: price,
      commission: 1,
      timestampMicros: ts,
      realizedPnl: pnl,
      realizedCashflow: cashflow,
      realizedFunding: funding,
      totalCommissionPaid: totalCommissionPaid,
      positionSizeAfter: positionSizeAfter,
    );
  }

  test('single entry and exit long', () {
    final trades = engine.reconstruct(
      fills: [
        fill(id: 'a', side: DeltaSide.buy, size: 2, price: 100, ts: 1),
        fill(
          id: 'b',
          side: DeltaSide.sell,
          size: 2,
          price: 110,
          ts: 2,
          pnl: 20,
          cashflow: 18,
          funding: -1,
          totalCommissionPaid: 2,
          positionSizeAfter: 0,
        ),
      ],
    );
    expect(trades.length, 1);
    expect(trades.first.status, JournalTradeStatus.closed);
    expect(trades.first.side, JournalTradeSide.long);
    expect(trades.first.quantity, 2);
    expect(trades.first.grossPnl, 20);
    expect(trades.first.netPnl, 18);
    expect(trades.first.funding, -1);
    expect(trades.first.fees, 2);
  });

  test('scale in and scale out', () {
    final trades = engine.reconstruct(
      fills: [
        fill(id: 'a', side: DeltaSide.buy, size: 1, price: 100, ts: 1),
        fill(id: 'b', side: DeltaSide.buy, size: 1, price: 102, ts: 2),
        fill(
          id: 'c',
          side: DeltaSide.sell,
          size: 2,
          price: 105,
          ts: 3,
          pnl: 8,
          cashflow: 5,
          positionSizeAfter: 0,
        ),
      ],
    );
    expect(trades.length, 1);
    expect(trades.first.averageEntryPrice, 101);
  });

  test('partial close leaves open trade', () {
    final trades = engine.reconstruct(
      fills: [
        fill(id: 'a', side: DeltaSide.buy, size: 3, price: 100, ts: 1),
        fill(id: 'b', side: DeltaSide.sell, size: 1, price: 105, ts: 2),
      ],
    );
    expect(trades.length, 1);
    expect(trades.first.status, JournalTradeStatus.open);
  });

  test('reversal closes long and opens short', () {
    final trades = engine.reconstruct(
      fills: [
        fill(id: 'a', side: DeltaSide.buy, size: 2, price: 100, ts: 1),
        fill(id: 'b', side: DeltaSide.sell, size: 4, price: 95, ts: 2),
      ],
    );
    expect(trades.length, 2);
    expect(trades[0].status, JournalTradeStatus.closed);
    expect(trades[0].side, JournalTradeSide.long);
    expect(trades[1].status, JournalTradeStatus.open);
    expect(trades[1].side, JournalTradeSide.short);
  });

  test('trims prefix when history starts mid-position', () {
    final trades = engine.reconstruct(
      fills: [
        NormalizedFill(
          fillId: 'skip1',
          productId: 1,
          symbol: 'BTCUSD',
          side: DeltaSide.sell,
          size: 1,
          price: 100,
          commission: 0,
          timestampMicros: 1,
          positionSizeAfter: 4,
        ),
        NormalizedFill(
          fillId: 'flat',
          productId: 1,
          symbol: 'BTCUSD',
          side: DeltaSide.sell,
          size: 4,
          price: 100,
          commission: 0,
          timestampMicros: 2,
          positionSizeAfter: 0,
        ),
        NormalizedFill(
          fillId: 'open',
          productId: 1,
          symbol: 'BTCUSD',
          side: DeltaSide.buy,
          size: 2,
          price: 100,
          commission: 1,
          timestampMicros: 3,
          positionSizeAfter: 2,
        ),
        NormalizedFill(
          fillId: 'close',
          productId: 1,
          symbol: 'BTCUSD',
          side: DeltaSide.sell,
          size: 2,
          price: 110,
          commission: 1,
          timestampMicros: 4,
          realizedPnl: 20,
          positionSizeAfter: 0,
        ),
      ],
    );
    expect(trades.length, 1);
    expect(trades.first.fillIds, ['open', 'close']);
  });

  test('short round trip', () {
    final trades = engine.reconstruct(
      fills: [
        fill(id: 'a', side: DeltaSide.sell, size: 1, price: 200, ts: 1),
        fill(
          id: 'b',
          side: DeltaSide.buy,
          size: 1,
          price: 190,
          ts: 2,
          pnl: 10,
          cashflow: 9,
          positionSizeAfter: 0,
        ),
      ],
    );
    expect(trades.length, 1);
    expect(trades.first.side, JournalTradeSide.short);
    expect(trades.first.status, JournalTradeStatus.closed);
  });
}
