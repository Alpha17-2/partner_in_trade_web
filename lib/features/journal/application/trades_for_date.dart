import '../../../models/journal_trade.dart';
import 'journal_date.dart';

List<JournalTrade> tradesForLocalDate(
  List<JournalTrade> trades,
  String dateKey,
) {
  return trades.where((t) {
    if (t.status == JournalTradeStatus.closed && t.exitTime != null) {
      return localDateKey(t.exitTime!) == dateKey;
    }
    return localDateKey(t.entryTime) == dateKey;
  }).toList()
    ..sort((a, b) {
      final at = a.exitTime ?? a.entryTime;
      final bt = b.exitTime ?? b.entryTime;
      return at.compareTo(bt);
    });
}
