import 'delta_parse_utils.dart';

class DeltaProduct {
  const DeltaProduct({
    required this.id,
    required this.symbol,
    this.contractType,
    this.state,
    this.tickSize,
    this.extra = const {},
  });

  final int id;
  final String symbol;
  final String? contractType;
  final String? state;
  final String? tickSize;
  final Map<String, dynamic> extra;

  factory DeltaProduct.fromJson(Map<String, dynamic> json) {
    final known = {'id', 'symbol', 'contract_type', 'state', 'tick_size'};
    final extra = <String, dynamic>{};
    for (final e in json.entries) {
      if (!known.contains(e.key)) extra[e.key] = e.value;
    }
    return DeltaProduct(
      id: parseInt(json['id']) ?? 0,
      symbol: parseString(json['symbol']) ?? '',
      contractType: parseString(json['contract_type']),
      state: parseString(json['state']),
      tickSize: parseString(json['tick_size']),
      extra: extra,
    );
  }
}
