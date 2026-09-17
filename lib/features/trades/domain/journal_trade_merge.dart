import '../../../models/journal_trade.dart';

/// Applies exchange fields from [synced] while preserving manual journal metadata.
JournalTrade mergeExchangeData({
  required JournalTrade previous,
  required JournalTrade synced,
}) {
  return synced.copyWith(
    strategy: previous.strategy,
    setup: previous.setup,
    tags: previous.tags,
    emotion: previous.emotion,
    confidence: previous.confidence,
    mistake: previous.mistake,
    notes: previous.notes,
    slippage: previous.slippage,
    rMultiple: previous.rMultiple ?? synced.rMultiple,
    mae: previous.mae ?? synced.mae,
    mfe: previous.mfe ?? synced.mfe,
  );
}

JournalTrade? findPreviousTrade(
  JournalTrade synced,
  Map<String, JournalTrade> byId,
  List<JournalTrade> allPrevious,
) {
  final exact = byId[synced.id];
  if (exact != null) return exact;

  JournalTrade? best;
  var bestOverlap = 0;
  final syncedFills = synced.fillIds.toSet();

  for (final prev in allPrevious) {
    if (prev.productId != synced.productId) continue;
    final overlap =
        prev.fillIds.where((id) => syncedFills.contains(id)).length;
    if (overlap > bestOverlap) {
      bestOverlap = overlap;
      best = prev;
    }
  }
  if (bestOverlap > 0) return best;
  return null;
}

List<JournalTrade> mergeAllTradesAfterSync({
  required List<JournalTrade> previous,
  required List<JournalTrade> reconstructed,
}) {
  final byId = {for (final t in previous) t.id: t};
  final merged = <JournalTrade>[];

  for (final synced in reconstructed) {
    final prev = findPreviousTrade(synced, byId, previous);
    if (prev != null) {
      merged.add(mergeExchangeData(previous: prev, synced: synced));
    } else {
      merged.add(synced);
    }
  }

  return merged;
}
