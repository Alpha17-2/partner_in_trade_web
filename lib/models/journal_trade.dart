enum JournalTradeSide { long, short }

enum JournalTradeStatus { open, closed }

class JournalTrade {
  const JournalTrade({
    required this.id,
    required this.symbol,
    required this.side,
    required this.entryTime,
    this.exitTime,
    required this.entryPrice,
    this.exitPrice,
    required this.quantity,
    required this.averageEntryPrice,
    this.averageExitPrice,
    this.stopLoss,
    this.takeProfit,
    required this.grossPnl,
    required this.fees,
    required this.funding,
    required this.netPnl,
    this.duration,
    this.leverage,
    required this.orderIds,
    required this.fillIds,
    this.mae,
    this.mfe,
    this.rMultiple,
    this.strategy,
    this.tags = const [],
    this.notes,
    required this.status,
    this.source = 'delta',
    required this.productId,
  });

  final String id;
  final int productId;
  final String symbol;
  final JournalTradeSide side;
  final DateTime entryTime;
  final DateTime? exitTime;
  final double entryPrice;
  final double? exitPrice;
  final double quantity;
  final double averageEntryPrice;
  final double? averageExitPrice;
  final double? stopLoss;
  final double? takeProfit;
  final double grossPnl;
  final double fees;
  final double funding;
  final double netPnl;
  final Duration? duration;
  final double? leverage;
  final List<String> orderIds;
  final List<String> fillIds;
  final double? mae;
  final double? mfe;
  final double? rMultiple;
  final String? strategy;
  final List<String> tags;
  final String? notes;
  final JournalTradeStatus status;
  final String source;

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'symbol': symbol,
        'side': side.name,
        'entryTime': entryTime.toIso8601String(),
        'exitTime': exitTime?.toIso8601String(),
        'entryPrice': entryPrice,
        'exitPrice': exitPrice,
        'quantity': quantity,
        'averageEntryPrice': averageEntryPrice,
        'averageExitPrice': averageExitPrice,
        'stopLoss': stopLoss,
        'takeProfit': takeProfit,
        'grossPnl': grossPnl,
        'fees': fees,
        'funding': funding,
        'netPnl': netPnl,
        'durationSeconds': duration?.inSeconds,
        'leverage': leverage,
        'orderIds': orderIds,
        'fillIds': fillIds,
        'mae': mae,
        'mfe': mfe,
        'rMultiple': rMultiple,
        'strategy': strategy,
        'tags': tags,
        'notes': notes,
        'status': status.name,
        'source': source,
      };

  factory JournalTrade.fromJson(Map<String, dynamic> json) {
    return JournalTrade(
      id: json['id'] as String,
      productId: json['productId'] as int,
      symbol: json['symbol'] as String,
      side: JournalTradeSide.values.byName(json['side'] as String),
      entryTime: DateTime.parse(json['entryTime'] as String),
      exitTime: json['exitTime'] != null
          ? DateTime.parse(json['exitTime'] as String)
          : null,
      entryPrice: (json['entryPrice'] as num).toDouble(),
      exitPrice: (json['exitPrice'] as num?)?.toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
      averageEntryPrice: (json['averageEntryPrice'] as num).toDouble(),
      averageExitPrice: (json['averageExitPrice'] as num?)?.toDouble(),
      stopLoss: (json['stopLoss'] as num?)?.toDouble(),
      takeProfit: (json['takeProfit'] as num?)?.toDouble(),
      grossPnl: (json['grossPnl'] as num).toDouble(),
      fees: (json['fees'] as num).toDouble(),
      funding: (json['funding'] as num).toDouble(),
      netPnl: (json['netPnl'] as num).toDouble(),
      duration: json['durationSeconds'] != null
          ? Duration(seconds: json['durationSeconds'] as int)
          : null,
      leverage: (json['leverage'] as num?)?.toDouble(),
      orderIds: (json['orderIds'] as List).cast<String>(),
      fillIds: (json['fillIds'] as List).cast<String>(),
      mae: (json['mae'] as num?)?.toDouble(),
      mfe: (json['mfe'] as num?)?.toDouble(),
      rMultiple: (json['rMultiple'] as num?)?.toDouble(),
      strategy: json['strategy'] as String?,
      tags: (json['tags'] as List?)?.cast<String>() ?? const [],
      notes: json['notes'] as String?,
      status: JournalTradeStatus.values.byName(json['status'] as String),
      source: json['source'] as String? ?? 'delta',
    );
  }
}
