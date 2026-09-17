import '../../../models/journal_trade.dart';
import '../../sync/domain/normalized_fill.dart';

enum TradeTimelineEventType {
  entry,
  scaleIn,
  partialExit,
  finalExit,
}

class TradeTimelineEvent {
  const TradeTimelineEvent({
    required this.type,
    required this.fill,
    required this.quantity,
  });

  final TradeTimelineEventType type;
  final NormalizedFill fill;
  final double quantity;
}

List<TradeTimelineEvent> buildTradeTimeline({
  required JournalTrade trade,
  required List<NormalizedFill> fills,
}) {
  if (fills.isEmpty) return [];

  final events = <TradeTimelineEvent>[];
  var position = 0.0;
  var hadPosition = false;

  for (final fill in fills) {
    final delta = fill.signedSizeDelta;
    final before = fill.positionSizeAfter != null
        ? fill.positionSizeAfter!.toDouble() - delta
        : position;
    final after = fill.positionSizeAfter?.toDouble() ?? (before + delta);
    final qty = fill.size;

    final openingFromFlat = before.abs() < 1e-9 && after.abs() > 1e-9;
    final sameDirection = (before > 0 && delta > 0) || (before < 0 && delta < 0);
    final closingToFlat = after.abs() < 1e-9 && before.abs() > 1e-9;
    final reducing =
        before.abs() > 1e-9 && after.abs() > 1e-9 && after.abs() < before.abs();

    TradeTimelineEventType type;
    if (openingFromFlat) {
      type = TradeTimelineEventType.entry;
      hadPosition = true;
    } else if (closingToFlat) {
      type = TradeTimelineEventType.finalExit;
      hadPosition = false;
    } else if (reducing) {
      type = TradeTimelineEventType.partialExit;
    } else if (sameDirection && hadPosition) {
      type = TradeTimelineEventType.scaleIn;
    } else if (!hadPosition && after.abs() > 1e-9) {
      type = TradeTimelineEventType.entry;
      hadPosition = true;
    } else {
      type = sameDirection
          ? TradeTimelineEventType.scaleIn
          : TradeTimelineEventType.partialExit;
    }

    events.add(TradeTimelineEvent(type: type, fill: fill, quantity: qty));
    position = after;
    if (after.abs() > 1e-9) hadPosition = true;
  }

  return events;
}
