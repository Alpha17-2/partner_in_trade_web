DeltaSide? parseDeltaSide(String? value) {
  switch (value) {
    case 'buy':
      return DeltaSide.buy;
    case 'sell':
      return DeltaSide.sell;
    default:
      return null;
  }
}

enum DeltaSide { buy, sell }

DeltaOrderState? parseDeltaOrderState(String? value) {
  switch (value) {
    case 'open':
      return DeltaOrderState.open;
    case 'pending':
      return DeltaOrderState.pending;
    case 'closed':
      return DeltaOrderState.closed;
    case 'cancelled':
      return DeltaOrderState.cancelled;
    default:
      return null;
  }
}

enum DeltaOrderState { open, pending, closed, cancelled }

enum DeltaTransactionType {
  funding,
  deposit,
  withdrawal,
  commission,
  transfer,
  subAccountTransfer,
  unknown,
}

DeltaTransactionType parseDeltaTransactionType(String? value) {
  switch (value) {
    case 'funding':
      return DeltaTransactionType.funding;
    case 'deposit':
      return DeltaTransactionType.deposit;
    case 'withdrawal':
      return DeltaTransactionType.withdrawal;
    case 'commission':
      return DeltaTransactionType.commission;
    case 'transfer':
      return DeltaTransactionType.transfer;
    case 'sub_account_transfer':
      return DeltaTransactionType.subAccountTransfer;
    default:
      return DeltaTransactionType.unknown;
  }
}

int? parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String? parseString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

/// Delta timestamps are usually microsecond epoch strings; some payloads use ISO-8601.
int parseDeltaEpochMicros(String? raw) {
  if (raw == null || raw.isEmpty) return 0;
  final trimmed = raw.trim();
  final asInt = int.tryParse(trimmed);
  if (asInt != null) {
    if (asInt >= 1000000000000000) return asInt;
    if (asInt >= 1000000000000) return asInt * 1000;
    if (asInt >= 1000000000) return asInt * 1000000;
    return asInt;
  }
  final dt = DateTime.tryParse(trimmed);
  if (dt != null) return dt.microsecondsSinceEpoch;
  return 0;
}
