class DeltaPageMeta {
  const DeltaPageMeta({this.after, this.before});

  final String? after;
  final String? before;

  factory DeltaPageMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DeltaPageMeta();
    return DeltaPageMeta(
      after: json['after'] as String?,
      before: json['before'] as String?,
    );
  }
}

class DeltaPagedResult<T> {
  const DeltaPagedResult({required this.items, this.meta});

  final List<T> items;
  final DeltaPageMeta? meta;
}
