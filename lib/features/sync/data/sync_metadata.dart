class SyncMetadata {
  const SyncMetadata({
    this.lastSyncAt,
    this.lastFillTimestampMicros,
    this.importedFillIds = const {},
    this.importedOrderIds = const {},
    this.initialLookbackDays = 90,
  });

  final DateTime? lastSyncAt;
  final int? lastFillTimestampMicros;
  final Set<String> importedFillIds;
  final Set<String> importedOrderIds;
  final int initialLookbackDays;

  Map<String, dynamic> toJson() => {
        'lastSyncAt': lastSyncAt?.toIso8601String(),
        'lastFillTimestampMicros': lastFillTimestampMicros,
        'importedFillIds': importedFillIds.toList(),
        'importedOrderIds': importedOrderIds.toList(),
        'initialLookbackDays': initialLookbackDays,
      };

  factory SyncMetadata.fromJson(Map<String, dynamic> json) => SyncMetadata(
        lastSyncAt: json['lastSyncAt'] != null
            ? DateTime.parse(json['lastSyncAt'] as String)
            : null,
        lastFillTimestampMicros: json['lastFillTimestampMicros'] as int?,
        importedFillIds:
            (json['importedFillIds'] as List?)?.cast<String>().toSet() ??
                const {},
        importedOrderIds:
            (json['importedOrderIds'] as List?)?.cast<String>().toSet() ??
                const {},
        initialLookbackDays: json['initialLookbackDays'] as int? ?? 90,
      );

  SyncMetadata copyWith({
    DateTime? lastSyncAt,
    int? lastFillTimestampMicros,
    Set<String>? importedFillIds,
    Set<String>? importedOrderIds,
    int? initialLookbackDays,
  }) {
    return SyncMetadata(
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      lastFillTimestampMicros:
          lastFillTimestampMicros ?? this.lastFillTimestampMicros,
      importedFillIds: importedFillIds ?? this.importedFillIds,
      importedOrderIds: importedOrderIds ?? this.importedOrderIds,
      initialLookbackDays: initialLookbackDays ?? this.initialLookbackDays,
    );
  }
}
