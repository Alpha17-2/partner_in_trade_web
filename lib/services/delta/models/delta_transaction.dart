import 'delta_parse_utils.dart';

class DeltaTransaction {
  const DeltaTransaction({
    this.id,
    this.assetSymbol,
    this.amount,
    this.transactionType = DeltaTransactionType.unknown,
    this.createdAt,
    this.extra = const {},
  });

  final int? id;
  final String? assetSymbol;
  final String? amount;
  final DeltaTransactionType transactionType;
  final String? createdAt;
  final Map<String, dynamic> extra;

  factory DeltaTransaction.fromJson(Map<String, dynamic> json) {
    final known = {
      'id',
      'asset_symbol',
      'amount',
      'transaction_type',
      'created_at',
    };
    final extra = <String, dynamic>{};
    for (final e in json.entries) {
      if (!known.contains(e.key)) extra[e.key] = e.value;
    }
    return DeltaTransaction(
      id: parseInt(json['id']),
      assetSymbol: parseString(json['asset_symbol']),
      amount: parseString(json['amount']),
      transactionType:
          parseDeltaTransactionType(parseString(json['transaction_type'])),
      createdAt: parseString(json['created_at']),
      extra: extra,
    );
  }
}
