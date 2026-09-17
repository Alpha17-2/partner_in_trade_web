import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/navigation/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../models/journal_trade.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/page_container.dart';
import '../../../shared/widgets/pnl_text.dart';
import '../../../shared/widgets/section_header.dart';
import '../../analytics/domain/performance_snapshot.dart';
import '../../trades/application/trades_filter_sort.dart';
import '../../trades/providers/trades_providers.dart';
import '../application/journal_date.dart';
import '../domain/daily_journal.dart';
import '../providers/journal_providers.dart';
import 'widgets/journal_screenshot_gallery.dart';

class DailyJournalPage extends ConsumerStatefulWidget {
  const DailyJournalPage({super.key, required this.dateKey});

  final String dateKey;

  @override
  ConsumerState<DailyJournalPage> createState() => _DailyJournalPageState();
}

class _DailyJournalPageState extends ConsumerState<DailyJournalPage> {
  DailyJournal? _draft;
  final _controllers = <String, TextEditingController>{};
  bool _hydrated = false;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _ctrl(String key, String? value) {
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: value ?? ''),
    );
  }

  void _hydrate(DailyJournal journal) {
    if (_hydrated && _draft?.date == journal.date) return;
    _draft = journal;
    _hydrated = true;
    void set(String k, String? v) {
      final c = _ctrl(k, v);
      if (c.text != (v ?? '')) c.text = v ?? '';
    }

    set('marketOverview', journal.marketOverview);
    set('tradingPlan', journal.tradingPlan);
    set('setupsLookingFor', journal.setupsLookingFor);
    set('stayOutConditions', journal.stayOutConditions);
    set('keyLevels', journal.keyLevels);
    set('importantObservations', journal.importantObservations);
    set('plannedTrades', journal.plannedTrades?.toString());
    set('actualTrades', journal.actualTrades?.toString());
    set('whatWentWell', journal.whatWentWell);
    set('whatWentWrong', journal.whatWentWrong);
    set('lessons', journal.lessons);
    set('tomorrowPlan', journal.tomorrowPlan);
    set('generalNotes', journal.generalNotes);
  }

  void _patch(DailyJournal next) {
    setState(() => _draft = next);
    ref.read(dailyJournalEditControllerProvider.notifier).scheduleSave(next);
  }

  @override
  Widget build(BuildContext context) {
    final date = parseDateKey(widget.dateKey);
    final journalAsync = ref.watch(dailyJournalProvider(widget.dateKey));
    final snap = ref.watch(dayPerformanceProvider(widget.dateKey));
    final trades = ref.watch(tradesForDateProvider(widget.dateKey));
    final save = ref.watch(dailyJournalEditControllerProvider);
    final colors = context.appColors;

    if (date == null) {
      return PageContainer(
        child: Text('Invalid date: ${widget.dateKey}'),
      );
    }

    return journalAsync.when(
      loading: () => const PageContainer(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => PageContainer(child: Text('$e')),
      data: (journal) {
        _hydrate(journal);
        final draft = _draft ?? journal;
        return PageContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => context.go(AppRoutes.journal),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Journal'),
                  ),
                  const Spacer(),
                  _saveLabel(save),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _longDate(date),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                _weekday(date),
                style: TextStyle(color: colors.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Trading Day',
                style: TextStyle(
                  color: colors.textTertiary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _summaryRow(snap),
              const SizedBox(height: AppSpacing.xl),
              _sectionCard(
                context,
                title: 'Market Overview',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _chips<MarketBias>(
                      label: 'Market bias',
                      value: draft.marketBias,
                      options: MarketBias.values,
                      labels: const {
                        MarketBias.bullish: 'Bullish',
                        MarketBias.bearish: 'Bearish',
                        MarketBias.neutral: 'Neutral',
                      },
                      onSelected: (v) => _patch(draft.copyWith(marketBias: v)),
                    ),
                    _chips<MarketCondition>(
                      label: 'Market condition',
                      value: draft.marketCondition,
                      options: MarketCondition.values,
                      labels: const {
                        MarketCondition.trending: 'Trending',
                        MarketCondition.ranging: 'Ranging',
                        MarketCondition.volatile: 'Volatile',
                        MarketCondition.choppy: 'Choppy',
                      },
                      onSelected: (v) =>
                          _patch(draft.copyWith(marketCondition: v)),
                    ),
                    _chips<TradingSession>(
                      label: 'Session',
                      value: draft.sessions,
                      options: TradingSession.values,
                      labels: const {
                        TradingSession.asia: 'Asia',
                        TradingSession.london: 'London',
                        TradingSession.newYork: 'New York',
                        TradingSession.multiple: 'Multiple',
                      },
                      onSelected: (v) => _patch(draft.copyWith(sessions: v)),
                    ),
                    _multiline(
                      'Overall market notes',
                      _ctrl('marketOverview', draft.marketOverview),
                      (v) => _patch(draft.copyWith(marketOverview: v)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _sectionCard(
                context,
                title: 'Trading Plan',
                child: Column(
                  children: [
                    _multiline(
                      "Today's plan",
                      _ctrl('tradingPlan', draft.tradingPlan),
                      (v) => _patch(draft.copyWith(tradingPlan: v)),
                    ),
                    _multiline(
                      'What setups am I looking for?',
                      _ctrl('setupsLookingFor', draft.setupsLookingFor),
                      (v) => _patch(draft.copyWith(setupsLookingFor: v)),
                    ),
                    _multiline(
                      'What conditions should make me stay out?',
                      _ctrl('stayOutConditions', draft.stayOutConditions),
                      (v) => _patch(draft.copyWith(stayOutConditions: v)),
                    ),
                    _multiline(
                      'Key levels',
                      _ctrl('keyLevels', draft.keyLevels),
                      (v) => _patch(draft.copyWith(keyLevels: v)),
                      lines: 3,
                    ),
                    _multiline(
                      'Important observations',
                      _ctrl('importantObservations', draft.importantObservations),
                      (v) => _patch(draft.copyWith(importantObservations: v)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _sectionCard(
                context,
                title: 'Execution Review',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _chips<PlanFollowed>(
                      label: 'Did I follow my plan?',
                      value: draft.followedPlan,
                      options: PlanFollowed.values,
                      labels: const {
                        PlanFollowed.yes: 'Yes',
                        PlanFollowed.partially: 'Partially',
                        PlanFollowed.no: 'No',
                      },
                      onSelected: (v) =>
                          _patch(draft.copyWith(followedPlan: v)),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ctrl(
                              'plannedTrades',
                              draft.plannedTrades?.toString(),
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Number of planned trades',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (v) => _patch(
                              draft.copyWith(plannedTrades: int.tryParse(v)),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: TextField(
                            controller: _ctrl(
                              'actualTrades',
                              draft.actualTrades?.toString(),
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Number of actual trades',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (v) => _patch(
                              draft.copyWith(actualTrades: int.tryParse(v)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _yesNo('Overtraded?', draft.overtraded, (v) {
                      _patch(draft.copyWith(overtraded: v));
                    }),
                    _yesNo('Revenge traded?', draft.revengeTrade, (v) {
                      _patch(draft.copyWith(revengeTrade: v));
                    }),
                    _yesNo('FOMO?', draft.fomo, (v) {
                      _patch(draft.copyWith(fomo: v));
                    }),
                    _yesNo('Early exit?', draft.earlyExit, (v) {
                      _patch(draft.copyWith(earlyExit: v));
                    }),
                    _yesNo('Oversized position?', draft.oversizedPosition, (v) {
                      _patch(draft.copyWith(oversizedPosition: v));
                    }),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _sectionCard(
                context,
                title: 'End-of-Day Review',
                child: Column(
                  children: [
                    _multiline(
                      'What went well?',
                      _ctrl('whatWentWell', draft.whatWentWell),
                      (v) => _patch(draft.copyWith(whatWentWell: v)),
                      lines: 5,
                    ),
                    _multiline(
                      'What went wrong?',
                      _ctrl('whatWentWrong', draft.whatWentWrong),
                      (v) => _patch(draft.copyWith(whatWentWrong: v)),
                      lines: 5,
                    ),
                    _multiline(
                      'What did I learn?',
                      _ctrl('lessons', draft.lessons),
                      (v) => _patch(draft.copyWith(lessons: v)),
                      lines: 5,
                    ),
                    _multiline(
                      'What will I do differently tomorrow?',
                      _ctrl('tomorrowPlan', draft.tomorrowPlan),
                      (v) => _patch(draft.copyWith(tomorrowPlan: v)),
                      lines: 5,
                    ),
                    _multiline(
                      'General notes',
                      _ctrl('generalNotes', draft.generalNotes),
                      (v) => _patch(draft.copyWith(generalNotes: v)),
                      lines: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: JournalScreenshotGallery(dateKey: widget.dateKey),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionHeader(
                      title: 'Trades — ${_longDate(date).toUpperCase()}',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (trades.isEmpty)
                      Text(
                        'No trades on this date',
                        style: TextStyle(color: colors.textTertiary),
                      )
                    else
                      ...trades.map((t) => _tradeRow(context, t)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryRow(PerformanceSnapshot snap) {
    final s = snap.statistics;
    Widget cell(String label, Widget value) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11)),
            const SizedBox(height: 4),
            value,
          ],
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          cell(
            'Net P&L',
            s.netPnl.hasValue
                ? PnlText(value: s.netPnl.value!, fontSize: 16)
                : Text(s.netPnl.formatCurrency()),
          ),
          cell('Trades', Text('${s.totalTrades}')),
          cell('Win Rate', Text(s.winRate.formatPercent())),
          cell('Average R', Text(snap.averageR.formatDouble())),
          cell('Largest Win', Text(s.largestWinNet.formatCurrency())),
          cell('Largest Loss', Text(s.largestLossNet.formatCurrency())),
          cell('Profit Factor', Text(snap.profitFactor.formatDouble())),
        ],
      ),
    );
  }

  Widget _tradeRow(BuildContext context, JournalTrade trade) {
    return InkWell(
      onTap: () {
        ref.read(selectedTradeIdProvider.notifier).state = trade.id;
        context.go(AppRoutes.trades);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            SizedBox(
              width: 88,
              child: Text(
                trade.symbol,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(
              width: 64,
              child: Text(
                trade.side == JournalTradeSide.long ? 'LONG' : 'SHORT',
                style: TextStyle(
                  color: trade.side == JournalTradeSide.long
                      ? context.appColors.positive
                      : context.appColors.negative,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(
              width: 72,
              child: Text(
                trade.rMultiple != null
                    ? '${trade.rMultiple! >= 0 ? '+' : ''}${trade.rMultiple!.toStringAsFixed(1)}R'
                    : '—',
              ),
            ),
            PnlText(value: trade.netPnl),
            const Spacer(),
            Text(
              formatTradeDuration(trade.duration),
              style: TextStyle(
                fontSize: 12,
                color: context.appColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: title),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }

  Widget _chips<T>({
    required String label,
    required T? value,
    required List<T> options,
    required Map<T, String> labels,
    required void Function(T) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: options
                .map(
                  (o) => ChoiceChip(
                    label: Text(labels[o] ?? '$o'),
                    selected: value == o,
                    onSelected: (_) => onSelected(o),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _yesNo(
    String label,
    JournalYesNo? value,
    void Function(JournalYesNo) onSelected,
  ) {
    return _chips<JournalYesNo>(
      label: label,
      value: value,
      options: JournalYesNo.values,
      labels: const {
        JournalYesNo.yes: 'Yes',
        JournalYesNo.no: 'No',
      },
      onSelected: onSelected,
    );
  }

  Widget _multiline(
    String label,
    TextEditingController controller,
    void Function(String) onChanged, {
    int lines = 4,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextField(
        controller: controller,
        minLines: lines,
        maxLines: lines + 6,
        decoration: InputDecoration(labelText: label, alignLabelWithHint: true),
        onChanged: onChanged,
      ),
    );
  }

  Widget _saveLabel(DailyJournalSaveState state) {
    switch (state.status) {
      case DailyJournalSaveStatus.saving:
        return const Text('Saving…', style: TextStyle(fontSize: 12));
      case DailyJournalSaveStatus.saved:
        return const Text('Saved', style: TextStyle(fontSize: 12));
      case DailyJournalSaveStatus.error:
        return Text(
          state.message ?? 'Error',
          style: TextStyle(fontSize: 12, color: context.appColors.negative),
        );
      case DailyJournalSaveStatus.idle:
        return const SizedBox.shrink();
    }
  }

  String _longDate(DateTime d) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _weekday(DateTime d) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[d.weekday - 1];
  }
}
