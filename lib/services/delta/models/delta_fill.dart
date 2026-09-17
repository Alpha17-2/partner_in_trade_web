import 'delta_parse_utils.dart';
import 'delta_product.dart';

class DeltaFillMetaData {
  const DeltaFillMetaData({
    this.realizedPnl,
    this.realizedFunding,
    this.realizedCashflow,
    this.totalCommissionPaid,
    this.newPositionSize,
  });

  final String? realizedPnl;
  final String? realizedFunding;
  final String? realizedCashflow;
  final String? totalCommissionPaid;
  final int? newPositionSize;

  factory DeltaFillMetaData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DeltaFillMetaData();
    final newPos = json['new_position'];
    int? size;
    String? realizedPnl = parseString(json['realized_pnl']);
    String? realizedFunding = parseString(json['realized_funding']);
    String? realizedCashflow = parseString(json['realized_cashflow']);
    String? totalCommissionPaid = parseString(json['total_commission_paid']);
    if (newPos is Map<String, dynamic>) {
      size = parseInt(newPos['size']);
      realizedPnl ??= parseString(newPos['realized_pnl']);
      realizedFunding ??= parseString(newPos['realized_funding']);
      realizedCashflow ??= parseString(newPos['realized_cashflow']);
      totalCommissionPaid ??= parseString(newPos['total_commission_paid']);
    }
    return DeltaFillMetaData(
      realizedPnl: realizedPnl,
      realizedFunding: realizedFunding,
      realizedCashflow: realizedCashflow,
      totalCommissionPaid: totalCommissionPaid,
      newPositionSize: size,
    );
  }
}

class DeltaFill {
  const DeltaFill({
    required this.id,
    this.size,
    this.notional,
    this.side,
    this.orderId,
    this.product,
    this.createdAt,
    this.price,
    this.commission,
    this.productId,
    this.productSymbol,
    this.fillType,
    this.role,
    this.metaData,
    this.extra = const {},
  });

  final String id;
  final String? size;
  final String? notional;
  final DeltaSide? side;
  final String? orderId;
  final DeltaProduct? product;
  final String? createdAt;
  final String? price;
  final String? commission;
  final int? productId;
  final String? productSymbol;
  final String? fillType;
  final String? role;
  final DeltaFillMetaData? metaData;
  final Map<String, dynamic> extra;

  factory DeltaFill.fromJson(Map<String, dynamic> json) {
    const known = {
      'id',
      'size',
      'notional',
      'side',
      'order_id',
      'product',
      'created_at',
      'price',
      'commission',
      'product_id',
      'product_symbol',
      'fill_type',
      'role',
      'meta_data',
    };
    final extra = <String, dynamic>{};
    for (final e in json.entries) {
      if (!known.contains(e.key)) extra[e.key] = e.value;
    }
    final productJson = json['product'];
    final metaJson = json['meta_data'];
    final orderRaw = json['order_id'];
    final orderId = orderRaw != null ? orderRaw.toString() : null;
    final product = productJson is Map<String, dynamic>
        ? DeltaProduct.fromJson(productJson)
        : null;

    return DeltaFill(
      id: parseString(json['id']) ?? '',
      size: parseString(json['size']),
      notional: parseString(json['notional']),
      side: parseDeltaSide(parseString(json['side'])),
      orderId: orderId,
      product: product,
      createdAt: parseString(json['created_at']),
      price: parseString(json['price']),
      commission: parseString(json['commission']),
      productId: _resolveProductId(json['product_id'], product),
      productSymbol: parseString(json['product_symbol']) ??
          (productJson is Map<String, dynamic>
              ? parseString(productJson['symbol'])
              : null),
      fillType: parseString(json['fill_type']),
      role: parseString(json['role']),
      metaData: metaJson is Map<String, dynamic>
          ? DeltaFillMetaData.fromJson(metaJson)
          : null,
      extra: extra,
    );
  }

  static int? _resolveProductId(dynamic rawId, DeltaProduct? product) {
    final fromField = parseInt(rawId);
    if (fromField != null && fromField != 0) return fromField;
    if (product != null && product.id != 0) return product.id;
    return fromField;
  }
}
