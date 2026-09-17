import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/navigation/app_routes.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/page_container.dart';
import '../../../shared/widgets/pnl_text.dart';
import '../../../shared/widgets/section_header.dart';
import '../application/journal_date.dart';
import '../providers/journal_providers.dart';

class JournalCalendarPage extends ConsumerWidget {
  const JournalCalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthState = ref.watch(journalCalendarMonthProvider);
    final month = monthState.visibleMonth;
    final summaries = ref.watch(journalMonthSummariesProvider);
    final search = ref.watch(journalSearchQueryProvider);
    final searchResults = ref.watch(journalSearchResultsProvider);
    final colors = context.appColors;

    final first = DateTime(month.year, month.month, 1);
    final daysToMonday = (first.weekday - DateTime.monday) % 7;
    final gridStart = first.subtract(Duration(days: daysToMonday));
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const cells = 42;

    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            title: 'Journal',
            subtitle: 'One daily journal per calendar date',
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search journal notes',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) =>
                ref.read(journalSearchQueryProvider.notifier).state = v,
          ),
          if (search.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            searchResults.when(
              data: (rows) {
                if (rows.isEmpty) {
                  return Text(
                    'No matching notes',
                    style: TextStyle(color: colors.textSecondary),
                  );
                }
                return Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: rows
                      .map(
                        (j) => ActionChip(
                          label: Text(j.date),
                          onPressed: () =>
                              context.go(AppRoutes.journalDate(j.date)),
                        ),
                      )
                      .toList(),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('$e'),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              IconButton(
                tooltip: 'Previous month',
                onPressed: () {
                  ref.read(journalCalendarMonthProvider.notifier).state =
                      CalendarMonthState(
                    visibleMonth: DateTime(month.year, month.month - 1),
                  );
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  _monthTitle(month),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                ),
              ),
              IconButton(
                tooltip: 'Next month',
                onPressed: () {
                  ref.read(journalCalendarMonthProvider.notifier).state =
                      CalendarMonthState(
                    visibleMonth: DateTime(month.year, month.month + 1),
                  );
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              for (final label in labels)
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, i) {
              final date = gridStart.add(Duration(days: i));
              final inMonth = date.month == month.month;
              final key = localDateKey(date);
              return _DayCell(
                date: date,
                inMonth: inMonth,
                summary: summaries[key],
                onTap: () => context.go(AppRoutes.journalDate(key)),
              );
            },
          ),
        ],
      ),
    );
  }

  String _monthTitle(DateTime month) {
    const names = [
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
    return '${names[month.month - 1].toUpperCase()} ${month.year}';
  }
}

class _DayCell extends StatefulWidget {
  const _DayCell({
    required this.date,
    required this.inMonth,
    required this.summary,
    required this.onTap,
  });

  final DateTime date;
  final bool inMonth;
  final JournalDaySummary? summary;
  final VoidCallback onTap;

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final today = dateOnly(DateTime.now());
    final isToday = dateOnly(widget.date) == today;
    final hasTrades = (widget.summary?.tradeCount ?? 0) > 0;
    final hasJournal = widget.summary?.hasJournal ?? false;
    final shots = widget.summary?.screenshotCount ?? 0;
    final showNoJournal =
        widget.inMonth && !hasJournal && !hasTrades && (_hovered || isToday);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isToday ? colors.borderStrong : colors.borderSubtle,
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Opacity(
              opacity: widget.inMonth ? 1 : 0.35,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${widget.date.day}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (hasJournal)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: colors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  if (hasTrades) ...[
                    PnlText(
                      value: widget.summary!.netPnl,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    Text(
                      '${widget.summary!.tradeCount} trades',
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.textSecondary,
                      ),
                    ),
                  ] else if (showNoJournal)
                    Text(
                      'No journal',
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.textTertiary,
                      ),
                    ),
                  if (shots > 0)
                    Text(
                      '📷 $shots',
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
