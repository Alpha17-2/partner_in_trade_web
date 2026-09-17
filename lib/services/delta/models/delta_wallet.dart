import 'delta_parse_utils.dart';

class DeltaWalletBalance {
  const DeltaWalletBalance({
    this.id,
    this.assetId,
    this.assetSymbol,
    this.balance,
    this.availableBalance,
    this.blockedMargin,
    this.userId,
    this.extra = const {},
  });

  final int? id;
  final int? assetId;
  final String? assetSymbol;
  final String? balance;
  final String? availableBalance;
  final String? blockedMargin;
  final int? userId;
  final Map<String, dynamic> extra;

  factory DeltaWalletBalance.fromJson(Map<String, dynamic> json) {
    final known = {
      'id',
      'asset_id',
      'asset_symbol',
      'balance',
      'available_balance',
      'blocked_margin',
      'user_id',
    };
    final extra = <String, dynamic>{};
    for (final e in json.entries) {
      if (!known.contains(e.key)) extra[e.key] = e.value;
    }
    return DeltaWalletBalance(
      id: parseInt(json['id']),
      assetId: parseInt(json['asset_id']),
      assetSymbol: parseString(json['asset_symbol']),
      balance: parseString(json['balance']),
      availableBalance: parseString(json['available_balance']),
      blockedMargin: parseString(json['blocked_margin']),
      userId: parseInt(json['user_id']),
      extra: extra,
    );
  }
}

class DeltaWalletBalancesResponse {
  const DeltaWalletBalancesResponse({
    required this.balances,
    this.netEquity,
    this.roboTradingEquity,
  });

  final List<DeltaWalletBalance> balances;
  final String? netEquity;
  final String? roboTradingEquity;

  factory DeltaWalletBalancesResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>?;
    final result = json['result'];
    final list = result is List
        ? result
            .whereType<Map<String, dynamic>>()
            .map(DeltaWalletBalance.fromJson)
            .toList()
        : <DeltaWalletBalance>[];
    return DeltaWalletBalancesResponse(
      balances: list,
      netEquity: parseString(meta?['net_equity']),
      roboTradingEquity: parseString(meta?['robo_trading_equity']),
    );
  }
}
