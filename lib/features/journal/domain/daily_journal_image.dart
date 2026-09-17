enum JournalScreenshotType { entry, exit, setup, market, other }

class DailyJournalImageMeta {
  const DailyJournalImageMeta({
    required this.id,
    required this.journalDate,
    required this.createdAt,
    required this.fileName,
    required this.mimeType,
    required this.size,
    this.caption,
    this.type = JournalScreenshotType.other,
    this.width,
    this.height,
  });

  final String id;
  final String journalDate;
  final DateTime createdAt;
  final String fileName;
  final String mimeType;
  final int size;
  final String? caption;
  final JournalScreenshotType type;
  final int? width;
  final int? height;

  DailyJournalImageMeta copyWith({
    String? caption,
    JournalScreenshotType? type,
  }) {
    return DailyJournalImageMeta(
      id: id,
      journalDate: journalDate,
      createdAt: createdAt,
      fileName: fileName,
      mimeType: mimeType,
      size: size,
      caption: caption ?? this.caption,
      type: type ?? this.type,
      width: width,
      height: height,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'journalDate': journalDate,
        'createdAt': createdAt.toIso8601String(),
        'fileName': fileName,
        'mimeType': mimeType,
        'size': size,
        'caption': caption,
        'type': type.name,
        'width': width,
        'height': height,
      };

  factory DailyJournalImageMeta.fromJson(Map<String, dynamic> json) {
    return DailyJournalImageMeta(
      id: json['id'] as String,
      journalDate: json['journalDate'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      fileName: json['fileName'] as String,
      mimeType: json['mimeType'] as String,
      size: (json['size'] as num).toInt(),
      caption: json['caption'] as String?,
      type: JournalScreenshotType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => JournalScreenshotType.other,
      ),
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
    );
  }
}
