import 'delta_parse_utils.dart';

class DeltaTradingPreferences {
  const DeltaTradingPreferences({
    this.userId,
    this.vipLevel,
    this.volume30d,
    this.extra = const {},
  });

  final int? userId;
  final int? vipLevel;
  final String? volume30d;
  final Map<String, dynamic> extra;

  factory DeltaTradingPreferences.fromJson(Map<String, dynamic> json) {
    final known = {'user_id', 'vip_level', 'volume_30d'};
    final extra = <String, dynamic>{};
    for (final e in json.entries) {
      if (!known.contains(e.key)) extra[e.key] = e.value;
    }
    return DeltaTradingPreferences(
      userId: parseInt(json['user_id']),
      vipLevel: parseInt(json['vip_level']),
      volume30d: parseString(json['volume_30d']),
      extra: extra,
    );
  }
}
