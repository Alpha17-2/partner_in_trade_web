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
    this.profitCapture,
    this.entryEfficiency,
    this.exitEfficiency,
    this.strategy,
    this.setup,
    this.tags = const [],
    this.emotion,
    this.confidence,
    this.mistake,
    this.notes,
    this.slippage,
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
  final double? profitCapture;
  final double? entryEfficiency;
  final double? exitEfficiency;
  final String? strategy;
  final String? setup;
  final List<String> tags;
  final String? emotion;
  final int? confidence;
  final String? mistake;
  final String? notes;
  final double? slippage;
  final JournalTradeStatus status;
  final String source;

  JournalTrade copyWith({
    String? id,
    int? productId,
    String? symbol,
    JournalTradeSide? side,
    DateTime? entryTime,
    DateTime? exitTime,
    double? entryPrice,
    double? exitPrice,
    double? quantity,
    double? averageEntryPrice,
    double? averageExitPrice,
    double? stopLoss,
    double? takeProfit,
    double? grossPnl,
    double? fees,
    double? funding,
    double? netPnl,
    Duration? duration,
    double? leverage,
    List<String>? orderIds,
    List<String>? fillIds,
    double? mae,
    double? mfe,
    double? rMultiple,
    double? profitCapture,
    double? entryEfficiency,
    double? exitEfficiency,
    String? strategy,
    String? setup,
    List<String>? tags,
    String? emotion,
    int? confidence,
    String? mistake,
    String? notes,
    double? slippage,
    JournalTradeStatus? status,
    String? source,
  }) {
    return JournalTrade(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      symbol: symbol ?? this.symbol,
      side: side ?? this.side,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
      entryPrice: entryPrice ?? this.entryPrice,
      exitPrice: exitPrice ?? this.exitPrice,
      quantity: quantity ?? this.quantity,
      averageEntryPrice: averageEntryPrice ?? this.averageEntryPrice,
      averageExitPrice: averageExitPrice ?? this.averageExitPrice,
      stopLoss: stopLoss ?? this.stopLoss,
      takeProfit: takeProfit ?? this.takeProfit,
      grossPnl: grossPnl ?? this.grossPnl,
      fees: fees ?? this.fees,
      funding: funding ?? this.funding,
      netPnl: netPnl ?? this.netPnl,
      duration: duration ?? this.duration,
      leverage: leverage ?? this.leverage,
      orderIds: orderIds ?? this.orderIds,
      fillIds: fillIds ?? this.fillIds,
      mae: mae ?? this.mae,
      mfe: mfe ?? this.mfe,
      rMultiple: rMultiple ?? this.rMultiple,
      profitCapture: profitCapture ?? this.profitCapture,
      entryEfficiency: entryEfficiency ?? this.entryEfficiency,
      exitEfficiency: exitEfficiency ?? this.exitEfficiency,
      strategy: strategy ?? this.strategy,
      setup: setup ?? this.setup,
      tags: tags ?? this.tags,
      emotion: emotion ?? this.emotion,
      confidence: confidence ?? this.confidence,
      mistake: mistake ?? this.mistake,
      notes: notes ?? this.notes,
      slippage: slippage ?? this.slippage,
      status: status ?? this.status,
      source: source ?? this.source,
    );
  }

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
        'profitCapture': profitCapture,
        'entryEfficiency': entryEfficiency,
        'exitEfficiency': exitEfficiency,
        'strategy': strategy,
        'setup': setup,
        'tags': tags,
        'emotion': emotion,
        'confidence': confidence,
        'mistake': mistake,
        'notes': notes,
        'slippage': slippage,
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
      profitCapture: (json['profitCapture'] as num?)?.toDouble(),
      entryEfficiency: (json['entryEfficiency'] as num?)?.toDouble(),
      exitEfficiency: (json['exitEfficiency'] as num?)?.toDouble(),
      strategy: json['strategy'] as String?,
      setup: json['setup'] as String?,
      tags: (json['tags'] as List?)?.cast<String>() ?? const [],
      emotion: json['emotion'] as String?,
      confidence: (json['confidence'] as num?)?.toInt(),
      mistake: json['mistake'] as String?,
      notes: json['notes'] as String?,
      slippage: (json['slippage'] as num?)?.toDouble(),
      status: JournalTradeStatus.values.byName(json['status'] as String),
      source: json['source'] as String? ?? 'delta',
    );
  }
}
