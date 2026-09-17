import '../../../services/delta/models/delta_fill.dart';
import '../../../services/delta/models/delta_parse_utils.dart';

class NormalizedFill {
  const NormalizedFill({
    required this.fillId,
    required this.productId,
    required this.symbol,
    required this.side,
    required this.size,
    required this.price,
    required this.commission,
    required this.timestampMicros,
    this.orderId,
    this.realizedPnl,
    this.realizedFunding,
    this.realizedCashflow,
    this.totalCommissionPaid,
    this.notional,
    this.positionSizeAfter,
  });

  final String fillId;
  final int productId;
  final String symbol;
  final DeltaSide side;
  final double size;
  final double price;
  final double commission;
  final int timestampMicros;
  final String? orderId;
  final double? realizedPnl;
  final double? realizedFunding;
  final double? realizedCashflow;
  final double? totalCommissionPaid;
  final double? notional;
  /// Signed position size after this fill (Delta `meta_data.new_position.size`).
  final int? positionSizeAfter;

  bool get isBuy => side == DeltaSide.buy;

  double get signedSizeDelta => isBuy ? size : -size;

  Map<String, dynamic> toJson() => {
        'fillId': fillId,
        'productId': productId,
        'symbol': symbol,
        'side': side == DeltaSide.buy ? 'buy' : 'sell',
        'size': size,
        'price': price,
        'commission': commission,
        'timestampMicros': timestampMicros,
        'orderId': orderId,
        'realizedPnl': realizedPnl,
        'realizedFunding': realizedFunding,
        'realizedCashflow': realizedCashflow,
        'totalCommissionPaid': totalCommissionPaid,
        'notional': notional,
        'positionSizeAfter': positionSizeAfter,
      };

  factory NormalizedFill.fromJson(Map<String, dynamic> json) {
    return NormalizedFill(
      fillId: json['fillId'] as String,
      productId: json['productId'] as int,
      symbol: json['symbol'] as String,
      side: parseDeltaSide(json['side'] as String?) ?? DeltaSide.buy,
      size: (json['size'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      commission: (json['commission'] as num).toDouble(),
      timestampMicros: json['timestampMicros'] as int,
      orderId: json['orderId'] as String?,
      realizedPnl: (json['realizedPnl'] as num?)?.toDouble(),
      realizedFunding: (json['realizedFunding'] as num?)?.toDouble(),
      realizedCashflow: (json['realizedCashflow'] as num?)?.toDouble(),
      totalCommissionPaid: (json['totalCommissionPaid'] as num?)?.toDouble(),
      notional: (json['notional'] as num?)?.toDouble(),
      positionSizeAfter: json['positionSizeAfter'] as int?,
    );
  }

  static NormalizedFill fromDeltaFill(DeltaFill fill) {
    final size = double.tryParse(fill.size ?? '') ?? 0;
    final price = double.tryParse(fill.price ?? '') ?? 0;
    final commission = double.tryParse(fill.commission ?? '') ?? 0;
    final ts = parseDeltaEpochMicros(fill.createdAt);
    final meta = fill.metaData;
    final pnl =
        meta?.realizedPnl != null ? double.tryParse(meta!.realizedPnl!) : null;
    final funding = meta?.realizedFunding != null
        ? double.tryParse(meta!.realizedFunding!)
        : null;
    final cashflow = meta?.realizedCashflow != null
        ? double.tryParse(meta!.realizedCashflow!)
        : null;
    final totalCommission = meta?.totalCommissionPaid != null
        ? double.tryParse(meta!.totalCommissionPaid!)
        : null;
    final notional = fill.notional != null
        ? double.tryParse(fill.notional!)
        : null;

    return NormalizedFill(
      fillId: fill.id,
      productId: fill.productId ?? fill.product?.id ?? 0,
      symbol: fill.productSymbol ?? fill.product?.symbol ?? 'UNKNOWN',
      side: fill.side ?? DeltaSide.buy,
      size: size,
      price: price,
      commission: commission,
      timestampMicros: ts,
      orderId: fill.orderId,
      realizedPnl: pnl,
      realizedFunding: funding,
      realizedCashflow: cashflow,
      totalCommissionPaid: totalCommission,
      notional: notional,
      positionSizeAfter: fill.metaData?.newPositionSize,
    );
  }
}

class FundingRecord {
  const FundingRecord({
    required this.symbol,
    required this.amount,
    required this.timestampMicros,
  });

  final String symbol;
  final double amount;
  final int timestampMicros;

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'amount': amount,
        'timestampMicros': timestampMicros,
      };

  factory FundingRecord.fromJson(Map<String, dynamic> json) => FundingRecord(
        symbol: json['symbol'] as String,
        amount: (json['amount'] as num).toDouble(),
        timestampMicros: json['timestampMicros'] as int,
      );
}

class OrderBracketInfo {
  const OrderBracketInfo({
    this.stopLoss,
    this.takeProfit,
    this.leverage,
  });

  final double? stopLoss;
  final double? takeProfit;
  final double? leverage;
}
