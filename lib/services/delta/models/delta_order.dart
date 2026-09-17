import 'delta_parse_utils.dart';

class DeltaOrder {
  const DeltaOrder({
    required this.id,
    this.productId,
    this.side,
    this.orderType,
    this.state,
    this.size,
    this.unfilledSize,
    this.limitPrice,
    this.averageFillPrice,
    this.updatedAt,
    this.extra = const {},
  });

  final int id;
  final int? productId;
  final DeltaSide? side;
  final String? orderType;
  final DeltaOrderState? state;
  final int? size;
  final int? unfilledSize;
  final String? limitPrice;
  final String? averageFillPrice;
  final String? updatedAt;
  final Map<String, dynamic> extra;

  factory DeltaOrder.fromJson(Map<String, dynamic> json) {
    final known = {
      'id',
      'product_id',
      'side',
      'order_type',
      'state',
      'size',
      'unfilled_size',
      'limit_price',
      'average_fill_price',
      'updated_at',
    };
    final extra = <String, dynamic>{};
    for (final e in json.entries) {
      if (!known.contains(e.key)) extra[e.key] = e.value;
    }
    return DeltaOrder(
      id: parseInt(json['id']) ?? 0,
      productId: parseInt(json['product_id']),
      side: parseDeltaSide(parseString(json['side'])),
      orderType: parseString(json['order_type']),
      state: parseDeltaOrderState(parseString(json['state'])),
      size: parseInt(json['size']),
      unfilledSize: parseInt(json['unfilled_size']),
      limitPrice: parseString(json['limit_price']),
      averageFillPrice: parseString(json['average_fill_price']),
      updatedAt: parseString(json['updated_at']),
      extra: extra,
    );
  }
}
