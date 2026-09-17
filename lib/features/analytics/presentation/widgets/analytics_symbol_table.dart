import 'package:flutter/material.dart';

import '../../../../shared/widgets/section_header.dart';
import '../../domain/performance_snapshot.dart';

enum _SymbolSort { symbol, trades, winRate, netPnl, averageR }

class AnalyticsSymbolTable extends StatefulWidget {
  const AnalyticsSymbolTable({super.key, required this.rows});

  final List<SymbolPerformanceRow> rows;

  @override
  State<AnalyticsSymbolTable> createState() => _AnalyticsSymbolTableState();
}

class _AnalyticsSymbolTableState extends State<AnalyticsSymbolTable> {
  _SymbolSort _sort = _SymbolSort.netPnl;
  bool _ascending = false;

  List<SymbolPerformanceRow> get _sorted {
    final list = List<SymbolPerformanceRow>.from(widget.rows);
    list.sort((a, b) {
      int cmp;
      switch (_sort) {
        case _SymbolSort.symbol:
          cmp = a.symbol.compareTo(b.symbol);
        case _SymbolSort.trades:
          cmp = a.trades.compareTo(b.trades);
        case _SymbolSort.winRate:
          cmp = (a.winRate.value ?? 0).compareTo(b.winRate.value ?? 0);
        case _SymbolSort.netPnl:
          cmp = (a.netPnl.value ?? 0).compareTo(b.netPnl.value ?? 0);
        case _SymbolSort.averageR:
          cmp = (a.averageR.value ?? 0).compareTo(b.averageR.value ?? 0);
      }
      return _ascending ? cmp : -cmp;
    });
    return list;
  }

  void _onSort(_SymbolSort column) {
    setState(() {
      if (_sort == column) {
        _ascending = !_ascending;
      } else {
        _sort = column;
        _ascending = column == _SymbolSort.symbol;
      }
    });
  }

  DataColumn _col(String label, _SymbolSort key) {
    final active = _sort == key;
    return DataColumn(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (active)
            Icon(
              _ascending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
            ),
        ],
      ),
      onSort: (_, _) => _onSort(key),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Performance by symbol'),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              _col('Symbol', _SymbolSort.symbol),
              _col('Trades', _SymbolSort.trades),
              _col('Win %', _SymbolSort.winRate),
              _col('Net P&L', _SymbolSort.netPnl),
              _col('Avg R', _SymbolSort.averageR),
            ],
            rows: _sorted
                .map(
                  (r) => DataRow(
                    cells: [
                      DataCell(Text(r.symbol)),
                      DataCell(Text('${r.trades}')),
                      DataCell(Text(r.winRate.formatPercent())),
                      DataCell(Text(r.netPnl.formatCurrency())),
                      DataCell(Text(r.averageR.formatDouble())),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
