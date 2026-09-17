import '../../../models/journal_trade.dart';
import '../../dashboard/mock/dashboard_mock_models.dart';
import '../domain/performance_snapshot.dart';

MockTrade journalTradeToMockTrade(JournalTrade t) {
  return MockTrade(
    id: t.id,
    date: t.exitTime ?? t.entryTime,
    symbol: t.symbol,
    side: t.side == JournalTradeSide.long ? TradeSide.long : TradeSide.short,
    strategy: t.strategy ?? '—',
    entry: t.averageEntryPrice,
    exit: t.averageExitPrice,
    pnl: t.netPnl,
    rMultiple: t.rMultiple ?? 0,
    status: t.status == JournalTradeStatus.closed
        ? TradeStatus.closed
        : TradeStatus.open,
  );
}

WinLossDistribution winLossFromSnapshot(PerformanceSnapshot snap) {
  if (!snap.hasCompletedTrades) {
    return const WinLossDistribution(wins: 0, losses: 0);
  }
  final s = snap.statistics;
  return WinLossDistribution(
    wins: s.winningTrades,
    losses: s.losingTrades,
    breakeven: s.breakevenTrades,
  );
}
