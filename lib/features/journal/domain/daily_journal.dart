enum MarketBias { bullish, bearish, neutral }

enum MarketCondition { trending, ranging, volatile, choppy }

enum TradingSession { asia, london, newYork, multiple }

enum PlanFollowed { yes, partially, no }

enum JournalYesNo { yes, no }

class DailyJournal {
  const DailyJournal({
    required this.id,
    required this.date,
    this.marketBias,
    this.marketCondition,
    this.sessions,
    this.marketOverview,
    this.tradingPlan,
    this.setupsLookingFor,
    this.stayOutConditions,
    this.keyLevels,
    this.importantObservations,
    this.plannedTrades,
    this.actualTrades,
    this.followedPlan,
    this.overtraded,
    this.revengeTrade,
    this.fomo,
    this.earlyExit,
    this.oversizedPosition,
    this.whatWentWell,
    this.whatWentWrong,
    this.lessons,
    this.tomorrowPlan,
    this.generalNotes,
    this.screenshotIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Same as [date] (`YYYY-MM-DD`).
  final String id;
  final String date;
  final MarketBias? marketBias;
  final MarketCondition? marketCondition;
  final TradingSession? sessions;
  final String? marketOverview;
  final String? tradingPlan;
  final String? setupsLookingFor;
  final String? stayOutConditions;
  final String? keyLevels;
  final String? importantObservations;
  final int? plannedTrades;
  final int? actualTrades;
  final PlanFollowed? followedPlan;
  final JournalYesNo? overtraded;
  final JournalYesNo? revengeTrade;
  final JournalYesNo? fomo;
  final JournalYesNo? earlyExit;
  final JournalYesNo? oversizedPosition;
  final String? whatWentWell;
  final String? whatWentWrong;
  final String? lessons;
  final String? tomorrowPlan;
  final String? generalNotes;
  final List<String> screenshotIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory DailyJournal.blank(String dateKey, {DateTime? now}) {
    final t = now ?? DateTime.now();
    return DailyJournal(
      id: dateKey,
      date: dateKey,
      createdAt: t,
      updatedAt: t,
    );
  }

  bool get hasUserContent {
    bool nonempty(String? s) => s != null && s.trim().isNotEmpty;
    return marketBias != null ||
        marketCondition != null ||
        sessions != null ||
        nonempty(marketOverview) ||
        nonempty(tradingPlan) ||
        nonempty(setupsLookingFor) ||
        nonempty(stayOutConditions) ||
        nonempty(keyLevels) ||
        nonempty(importantObservations) ||
        plannedTrades != null ||
        actualTrades != null ||
        followedPlan != null ||
        overtraded != null ||
        revengeTrade != null ||
        fomo != null ||
        earlyExit != null ||
        oversizedPosition != null ||
        nonempty(whatWentWell) ||
        nonempty(whatWentWrong) ||
        nonempty(lessons) ||
        nonempty(tomorrowPlan) ||
        nonempty(generalNotes) ||
        screenshotIds.isNotEmpty;
  }

  String get searchableText {
    return [
      marketOverview,
      tradingPlan,
      setupsLookingFor,
      stayOutConditions,
      keyLevels,
      importantObservations,
      whatWentWell,
      whatWentWrong,
      lessons,
      tomorrowPlan,
      generalNotes,
    ].whereType<String>().join(' ');
  }

  DailyJournal copyWith({
    MarketBias? marketBias,
    MarketCondition? marketCondition,
    TradingSession? sessions,
    String? marketOverview,
    String? tradingPlan,
    String? setupsLookingFor,
    String? stayOutConditions,
    String? keyLevels,
    String? importantObservations,
    int? plannedTrades,
    int? actualTrades,
    PlanFollowed? followedPlan,
    JournalYesNo? overtraded,
    JournalYesNo? revengeTrade,
    JournalYesNo? fomo,
    JournalYesNo? earlyExit,
    JournalYesNo? oversizedPosition,
    String? whatWentWell,
    String? whatWentWrong,
    String? lessons,
    String? tomorrowPlan,
    String? generalNotes,
    List<String>? screenshotIds,
    DateTime? updatedAt,
    bool clearMarketBias = false,
    bool clearMarketCondition = false,
    bool clearSessions = false,
    bool clearFollowedPlan = false,
    bool clearOvertraded = false,
    bool clearRevengeTrade = false,
    bool clearFomo = false,
    bool clearEarlyExit = false,
    bool clearOversized = false,
  }) {
    return DailyJournal(
      id: id,
      date: date,
      marketBias: clearMarketBias ? null : (marketBias ?? this.marketBias),
      marketCondition: clearMarketCondition
          ? null
          : (marketCondition ?? this.marketCondition),
      sessions: clearSessions ? null : (sessions ?? this.sessions),
      marketOverview: marketOverview ?? this.marketOverview,
      tradingPlan: tradingPlan ?? this.tradingPlan,
      setupsLookingFor: setupsLookingFor ?? this.setupsLookingFor,
      stayOutConditions: stayOutConditions ?? this.stayOutConditions,
      keyLevels: keyLevels ?? this.keyLevels,
      importantObservations:
          importantObservations ?? this.importantObservations,
      plannedTrades: plannedTrades ?? this.plannedTrades,
      actualTrades: actualTrades ?? this.actualTrades,
      followedPlan:
          clearFollowedPlan ? null : (followedPlan ?? this.followedPlan),
      overtraded: clearOvertraded ? null : (overtraded ?? this.overtraded),
      revengeTrade:
          clearRevengeTrade ? null : (revengeTrade ?? this.revengeTrade),
      fomo: clearFomo ? null : (fomo ?? this.fomo),
      earlyExit: clearEarlyExit ? null : (earlyExit ?? this.earlyExit),
      oversizedPosition:
          clearOversized ? null : (oversizedPosition ?? this.oversizedPosition),
      whatWentWell: whatWentWell ?? this.whatWentWell,
      whatWentWrong: whatWentWrong ?? this.whatWentWrong,
      lessons: lessons ?? this.lessons,
      tomorrowPlan: tomorrowPlan ?? this.tomorrowPlan,
      generalNotes: generalNotes ?? this.generalNotes,
      screenshotIds: screenshotIds ?? this.screenshotIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'marketBias': marketBias?.name,
        'marketCondition': marketCondition?.name,
        'sessions': sessions?.name,
        'marketOverview': marketOverview,
        'tradingPlan': tradingPlan,
        'setupsLookingFor': setupsLookingFor,
        'stayOutConditions': stayOutConditions,
        'keyLevels': keyLevels,
        'importantObservations': importantObservations,
        'plannedTrades': plannedTrades,
        'actualTrades': actualTrades,
        'followedPlan': followedPlan?.name,
        'overtraded': overtraded?.name,
        'revengeTrade': revengeTrade?.name,
        'fomo': fomo?.name,
        'earlyExit': earlyExit?.name,
        'oversizedPosition': oversizedPosition?.name,
        'whatWentWell': whatWentWell,
        'whatWentWrong': whatWentWrong,
        'lessons': lessons,
        'tomorrowPlan': tomorrowPlan,
        'generalNotes': generalNotes,
        'screenshotIds': screenshotIds,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory DailyJournal.fromJson(Map<String, dynamic> json) {
    T? enumOrNull<T extends Enum>(List<T> values, String? name) {
      if (name == null) return null;
      for (final v in values) {
        if (v.name == name) return v;
      }
      return null;
    }

    return DailyJournal(
      id: json['id'] as String? ?? json['date'] as String,
      date: json['date'] as String,
      marketBias: enumOrNull(MarketBias.values, json['marketBias'] as String?),
      marketCondition: enumOrNull(
        MarketCondition.values,
        json['marketCondition'] as String?,
      ),
      sessions: enumOrNull(TradingSession.values, json['sessions'] as String?),
      marketOverview: json['marketOverview'] as String?,
      tradingPlan: json['tradingPlan'] as String?,
      setupsLookingFor: json['setupsLookingFor'] as String?,
      stayOutConditions: json['stayOutConditions'] as String?,
      keyLevels: json['keyLevels'] as String?,
      importantObservations: json['importantObservations'] as String?,
      plannedTrades: (json['plannedTrades'] as num?)?.toInt(),
      actualTrades: (json['actualTrades'] as num?)?.toInt(),
      followedPlan:
          enumOrNull(PlanFollowed.values, json['followedPlan'] as String?),
      overtraded: enumOrNull(JournalYesNo.values, json['overtraded'] as String?),
      revengeTrade:
          enumOrNull(JournalYesNo.values, json['revengeTrade'] as String?),
      fomo: enumOrNull(JournalYesNo.values, json['fomo'] as String?),
      earlyExit: enumOrNull(JournalYesNo.values, json['earlyExit'] as String?),
      oversizedPosition:
          enumOrNull(JournalYesNo.values, json['oversizedPosition'] as String?),
      whatWentWell: json['whatWentWell'] as String?,
      whatWentWrong: json['whatWentWrong'] as String?,
      lessons: json['lessons'] as String?,
      tomorrowPlan: json['tomorrowPlan'] as String?,
      generalNotes: json['generalNotes'] as String?,
      screenshotIds:
          (json['screenshotIds'] as List?)?.cast<String>() ?? const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class DailyJournalIndexEntry {
  const DailyJournalIndexEntry({
    required this.date,
    required this.screenshotCount,
    required this.hasContent,
  });

  final String date;
  final int screenshotCount;
  final bool hasContent;
}
