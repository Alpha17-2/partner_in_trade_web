import 'delta_parse_utils.dart';

class DeltaPosition {
  const DeltaPosition({
    this.userId,
    this.productId,
    this.productSymbol,
    this.size,
    this.entryPrice,
    this.margin,
    this.markPrice,
    this.realizedFunding,
    this.liquidationPrice,
    this.extra = const {},
  });

  final int? userId;
  final int? productId;
  final String? productSymbol;
  final int? size;
  final String? entryPrice;
  final String? margin;
  final String? markPrice;
  final String? realizedFunding;
  final String? liquidationPrice;
  final Map<String, dynamic> extra;

  factory DeltaPosition.fromJson(Map<String, dynamic> json) {
    final known = {
      'user_id',
      'product_id',
      'product_symbol',
      'size',
      'entry_price',
      'margin',
      'mark_price',
      'realized_funding',
      'liquidation_price',
    };
    final extra = <String, dynamic>{};
    for (final e in json.entries) {
      if (!known.contains(e.key)) extra[e.key] = e.value;
    }
    return DeltaPosition(
      userId: parseInt(json['user_id']),
      productId: parseInt(json['product_id']),
      productSymbol: parseString(json['product_symbol']),
      size: parseInt(json['size']),
      entryPrice: parseString(json['entry_price']),
      margin: parseString(json['margin']),
      markPrice: parseString(json['mark_price']),
      realizedFunding: parseString(json['realized_funding']),
      liquidationPrice: parseString(json['liquidation_price']),
      extra: extra,
    );
  }
}
