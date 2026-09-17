final _dateKeyPattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

String localDateKey(DateTime dateTime) {
  final local = dateTime.toLocal();
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

DateTime? parseDateKey(String key) {
  final match = _dateKeyPattern.firstMatch(key);
  if (match == null) return null;
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    return null;
  }
  return date;
}

DateTime dateOnly(DateTime dateTime) {
  final local = dateTime.toLocal();
  return DateTime(local.year, local.month, local.day);
}
