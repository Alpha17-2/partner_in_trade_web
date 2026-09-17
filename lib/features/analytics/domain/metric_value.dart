class MetricValue<T extends num> {
  const MetricValue._(this._value);

  final T? _value;

  bool get hasValue => _value != null;
  T? get value => _value;

  static MetricValue<double> of(double? v) {
    if (v == null || v.isNaN || v.isInfinite) return const MetricValue._(null);
    return MetricValue._(v);
  }

  static MetricValue<int> ofInt(int? v) {
    if (v == null) return const MetricValue._(null);
    return MetricValue._(v);
  }

  String formatDouble({int fractionDigits = 2, String na = 'N/A'}) {
    if (!hasValue) return na;
    return _value!.toStringAsFixed(fractionDigits);
  }

  String formatPercent({int fractionDigits = 1, String na = 'N/A'}) {
    if (!hasValue) return na;
    return '${_value!.toStringAsFixed(fractionDigits)}%';
  }

  String formatCurrency({String na = 'N/A'}) {
    if (!hasValue) return na;
    final v = _value!;
    final sign = v >= 0 ? '+' : '';
    return '$sign\$${v.toStringAsFixed(2)}';
  }
}
