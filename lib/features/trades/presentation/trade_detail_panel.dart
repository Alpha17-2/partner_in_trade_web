import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../models/journal_trade.dart';
import '../../../shared/widgets/pnl_text.dart';
import '../application/trade_timeline_builder.dart';
import '../application/trades_filter_sort.dart';
import '../domain/journal_presets.dart';
import '../providers/trades_providers.dart';
import 'widgets/trade_chart.dart';

class TradeDetailPanel extends ConsumerStatefulWidget {
  const TradeDetailPanel({super.key, required this.trade});

  final JournalTrade trade;

  @override
  ConsumerState<TradeDetailPanel> createState() => _TradeDetailPanelState();
}

class _TradeDetailPanelState extends ConsumerState<TradeDetailPanel> {
  late JournalTrade _draft;
  final _notesController = TextEditingController();
  final _rController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _draft = widget.trade;
    _notesController.text = widget.trade.notes ?? '';
    _rController.text = widget.trade.rMultiple?.toString() ?? '';
  }

  @override
  void didUpdateWidget(covariant TradeDetailPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trade.id != widget.trade.id) {
      _draft = widget.trade;
      _notesController.text = widget.trade.notes ?? '';
      _rController.text = widget.trade.rMultiple?.toString() ?? '';
    }
    // Same trade: keep local draft; exchange fields refresh only after sync.
  }

  @override
  void dispose() {
    _notesController.dispose();
    _rController.dispose();
    super.dispose();
  }

  void _patch(JournalTrade next) {
    setState(() => _draft = next);
    ref.read(journalEditControllerProvider.notifier).scheduleSave(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final saveState = ref.watch(journalEditControllerProvider);
    final fillsAsync = ref.watch(tradeFillsProvider(widget.trade.id));

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: colors.borderSubtle)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.trade.symbol,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                _saveIndicator(saveState),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.trade.side == JournalTradeSide.long ? 'LONG' : 'SHORT',
              style: TextStyle(
                color: widget.trade.side == JournalTradeSide.long
                    ? colors.positive
                    : colors.negative,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Text('Net P&L '),
                PnlText(value: widget.trade.netPnl),
                const SizedBox(width: AppSpacing.lg),
                Text(
                  'R: ${widget.trade.rMultiple?.toStringAsFixed(2) ?? '—'}',
                  style: context.monoText(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            TradeChart(trade: widget.trade),
            const SizedBox(height: AppSpacing.xl),
            _sectionTitle(context, 'Execution'),
            _statRow('Entry', widget.trade.averageEntryPrice.toStringAsFixed(2)),
            _statRow(
              'Exit',
              widget.trade.averageExitPrice?.toStringAsFixed(2) ?? '—',
            ),
            _statRow('Quantity', widget.trade.quantity.toStringAsFixed(4)),
            _statRow('Entry time', _fmt(widget.trade.entryTime)),
            _statRow(
              'Exit time',
              widget.trade.exitTime != null
                  ? _fmt(widget.trade.exitTime!)
                  : '—',
            ),
            _statRow(
              'Duration',
              formatTradeDuration(widget.trade.duration),
            ),
            _statRow(
              'Leverage',
              widget.trade.leverage?.toStringAsFixed(1) ?? '—',
            ),
            const SizedBox(height: AppSpacing.lg),
            _sectionTitle(context, 'Costs'),
            _statRow('Gross P&L', widget.trade.grossPnl.toStringAsFixed(2)),
            _statRow('Trading fees', widget.trade.fees.toStringAsFixed(2)),
            _statRow('Funding', widget.trade.funding.toStringAsFixed(2)),
            _statRow('Slippage', widget.trade.slippage?.toStringAsFixed(2) ?? '—'),
            _statRow('Net P&L', widget.trade.netPnl.toStringAsFixed(2)),
            const SizedBox(height: AppSpacing.lg),
            _sectionTitle(context, 'Timeline'),
            fillsAsync.when(
              data: (fills) {
                final events = buildTradeTimeline(
                  trade: widget.trade,
                  fills: fills,
                );
                if (events.isEmpty) {
                  return const Text('No fill data for this trade.');
                }
                return Column(
                  children: events.map(_timelineTile).toList(),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Failed to load fills: $e'),
            ),
            const SizedBox(height: AppSpacing.lg),
            _sectionTitle(context, 'Journal'),
            _dropdown(
              'Strategy',
              _draft.strategy,
              JournalPresets.strategies,
              (v) => _patch(_draft.copyWith(strategy: v)),
            ),
            _dropdown(
              'Setup',
              _draft.setup,
              JournalPresets.setups,
              (v) => _patch(_draft.copyWith(setup: v)),
            ),
            _dropdown(
              'Emotion',
              _draft.emotion,
              JournalPresets.emotions,
              (v) => _patch(_draft.copyWith(emotion: v)),
            ),
            _dropdown(
              'Mistake',
              _draft.mistake,
              JournalPresets.mistakes,
              (v) => _patch(_draft.copyWith(mistake: v)),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Confidence', style: Theme.of(context).textTheme.labelMedium),
            Slider(
              value: (_draft.confidence ?? 5).toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '${_draft.confidence ?? 5}',
              onChanged: (v) =>
                  _patch(_draft.copyWith(confidence: v.round())),
            ),
            TextField(
              controller: _rController,
              decoration: const InputDecoration(labelText: 'R Multiple'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) {
                final r = double.tryParse(v);
                _patch(_draft.copyWith(rMultiple: r));
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 4,
              onChanged: (v) => _patch(_draft.copyWith(notes: v)),
            ),
            const SizedBox(height: AppSpacing.lg),
            _sectionTitle(context, 'Identifiers'),
            _idRow(context, 'Trade ID', widget.trade.id),
            _idRow(context, 'Product ID', widget.trade.productId.toString()),
            _idRow(
              context,
              'Fill IDs',
              widget.trade.fillIds.join(', '),
            ),
            _idRow(
              context,
              'Order IDs',
              widget.trade.orderIds.join(', '),
            ),
          ],
        ),
      ),
    );
  }

  Widget _saveIndicator(JournalSaveState state) {
    switch (state.status) {
      case JournalSaveStatus.saving:
        return const Text('Saving…', style: TextStyle(fontSize: 12));
      case JournalSaveStatus.saved:
        return const Text('Saved', style: TextStyle(fontSize: 12));
      case JournalSaveStatus.error:
        return Text(
          state.message ?? 'Error',
          style: TextStyle(fontSize: 12, color: context.appColors.negative),
        );
      case JournalSaveStatus.idle:
        return const SizedBox.shrink();
    }
  }

  Widget _timelineTile(TradeTimelineEvent e) {
    final label = switch (e.type) {
      TradeTimelineEventType.entry => 'Entry',
      TradeTimelineEventType.scaleIn => 'Scale in',
      TradeTimelineEventType.partialExit => 'Partial exit',
      TradeTimelineEventType.finalExit => 'Final exit',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '$label · ${e.fill.isBuy ? 'buy' : 'sell'} ${e.quantity} @ ${e.fill.price}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: Text(value, style: context.monoText(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _dropdown(
    String label,
    String? value,
    List<String> options,
    void Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DropdownButtonFormField<String>(
        initialValue: value != null && options.contains(value) ? value : null,
        decoration: InputDecoration(labelText: label),
        items: [
          const DropdownMenuItem(value: null, child: Text('—')),
          ...options.map((o) => DropdownMenuItem(value: o, child: Text(o))),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _idRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(label, style: const TextStyle(fontSize: 11)),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: context.monoText(fontSize: 10),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 16),
            onPressed: () => Clipboard.setData(ClipboardData(text: value)),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
