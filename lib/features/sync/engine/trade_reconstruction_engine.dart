import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../../models/journal_trade.dart';
import '../domain/normalized_fill.dart';

class TradeReconstructionEngine {
  List<JournalTrade> reconstruct({
    required List<NormalizedFill> fills,
    Map<String, OrderBracketInfo> orderBrackets = const {},
  }) {
    final byProduct = <int, List<NormalizedFill>>{};
    for (final f in fills) {
      if (f.size <= 0) continue;
      byProduct.putIfAbsent(f.productId, () => []).add(f);
    }

    final trades = <JournalTrade>[];
    for (final entry in byProduct.entries) {
      final sorted = List<NormalizedFill>.from(entry.value)
        ..sort((a, b) {
          final c = a.timestampMicros.compareTo(b.timestampMicros);
          if (c != 0) return c;
          return a.fillId.compareTo(b.fillId);
        });
      trades.addAll(_reconstructProduct(sorted, orderBrackets));
    }
    return trades;
  }

  List<JournalTrade> _reconstructProduct(
    List<NormalizedFill> fills,
    Map<String, OrderBracketInfo> orderBrackets,
  ) {
    final activeFills = _trimIncompleteHistoryPrefix(fills);
    final trades = <JournalTrade>[];
    double position = 0;
    _RoundTripBuilder? builder;

    for (final fill in activeFills) {
      var remaining = fill.isBuy ? fill.size : -fill.size;

      while (remaining.abs() > 1e-12) {
        if (position == 0) {
          builder = _RoundTripBuilder(
            productId: fill.productId,
            symbol: fill.symbol,
            side: remaining > 0
                ? JournalTradeSide.long
                : JournalTradeSide.short,
          );
        }

        final sameDirection = (position > 0 && remaining > 0) ||
            (position < 0 && remaining < 0);

        if (position == 0 || sameDirection) {
          builder!.addEntryFill(fill, remaining.abs());
          position += remaining;
          remaining = 0;
        } else {
          final closeSize = remaining.abs() < position.abs()
              ? remaining.abs()
              : position.abs();
          builder!.addExitFill(fill, closeSize);
          if (position > 0) {
            position -= closeSize;
            remaining += closeSize;
          } else {
            position += closeSize;
            remaining -= closeSize;
          }
          if (position.abs() < 1e-12) {
            position = 0;
            trades.add(
              builder.build(
                orderBrackets: orderBrackets,
                status: JournalTradeStatus.closed,
              ),
            );
            builder = null;
          }
        }
      }
    }

    if (builder != null && position.abs() > 1e-12) {
      trades.add(
        builder.build(
          orderBrackets: orderBrackets,
          status: JournalTradeStatus.open,
        ),
      );
    }

    return trades;
  }

  /// Drops fills before the first observable flat position so a 90-day lookback
  /// does not invent a fake entry in the middle of an older position.
  List<NormalizedFill> _trimIncompleteHistoryPrefix(List<NormalizedFill> fills) {
    if (fills.isEmpty) return fills;
    final hasPositionMeta =
        fills.any((f) => f.positionSizeAfter != null);
    if (!hasPositionMeta) return fills;

    final trimmed = <NormalizedFill>[];
    var inPrefix = true;

    for (final fill in fills) {
      final after = fill.positionSizeAfter;
      if (after == null) {
        if (!inPrefix) trimmed.add(fill);
        continue;
      }

      final afterD = after.toDouble();
      final before = afterD - fill.signedSizeDelta;
      if (inPrefix) {
        if (!_nearZero(before) && !_nearZero(afterD)) {
          continue;
        }
        if (!_nearZero(before) && _nearZero(afterD)) {
          inPrefix = false;
          continue;
        }
        if (_nearZero(before) && !_nearZero(afterD)) {
          inPrefix = false;
          trimmed.add(fill);
          continue;
        }
        continue;
      }
      trimmed.add(fill);
    }

    return trimmed.isEmpty ? fills : trimmed;
  }

  static bool _nearZero(double v) => v.abs() < 1e-9;
}

class _RoundTripBuilder {
  _RoundTripBuilder({
    required this.productId,
    required this.symbol,
    required this.side,
  });

  final int productId;
  final String symbol;
  final JournalTradeSide side;
  final List<String> fillIds = [];
  final List<String> orderIds = [];
  double _entryQty = 0;
  double _entryNotional = 0;
  double _exitQty = 0;
  double _exitNotional = 0;
  double _commissionSum = 0;
  DateTime? _entryTime;
  DateTime? _exitTime;
  NormalizedFill? _firstFill;
  NormalizedFill? _latestFill;
  NormalizedFill? _flatFill;

  void addEntryFill(NormalizedFill fill, double qty) {
    _firstFill ??= fill;
    fillIds.add(fill.fillId);
    if (fill.orderId != null) orderIds.add(fill.orderId!);
    _entryQty += qty;
    _entryNotional += qty * fill.price;
    _commissionSum += fill.commission;
    _entryTime ??= _microsToDate(fill.timestampMicros);
    _trackFill(fill);
  }

  void addExitFill(NormalizedFill fill, double qty) {
    fillIds.add(fill.fillId);
    if (fill.orderId != null) orderIds.add(fill.orderId!);
    _exitQty += qty;
    _exitNotional += qty * fill.price;
    _commissionSum += fill.commission * (qty / fill.size);
    _exitTime = _microsToDate(fill.timestampMicros);
    _trackFill(fill);
  }

  void _trackFill(NormalizedFill fill) {
    _latestFill = fill;
    if (fill.positionSizeAfter == 0) {
      _flatFill = fill;
    }
  }

  JournalTrade build({
    required Map<String, OrderBracketInfo> orderBrackets,
    required JournalTradeStatus status,
  }) {
    final avgEntry =
        _entryQty > 0 ? (_entryNotional / _entryQty).toDouble() : 0.0;
    final avgExit =
        _exitQty > 0 ? (_exitNotional / _exitQty).toDouble() : null;
    final entryTime = _entryTime ?? DateTime.now();
    final exitTime = status == JournalTradeStatus.closed ? _exitTime : null;

    final pnlFill = status == JournalTradeStatus.closed
        ? (_flatFill ?? _latestFill)
        : _latestFill;

    final grossPnl = pnlFill?.realizedPnl ?? 0.0;
    final fundingTotal = pnlFill?.realizedFunding ?? 0.0;
    final netPnl = pnlFill?.realizedCashflow ??
        pnlFill?.realizedPnl ??
        0.0;
    final fees = pnlFill?.totalCommissionPaid ?? _commissionSum;

    double? stopLoss;
    double? takeProfit;
    double? leverage;
    for (final oid in orderIds) {
      final info = orderBrackets[oid];
      if (info == null) continue;
      stopLoss ??= info.stopLoss;
      takeProfit ??= info.takeProfit;
      leverage ??= info.leverage;
    }

    final duration = exitTime != null ? exitTime.difference(entryTime) : null;
    final id = _stableId(productId, fillIds);

    return JournalTrade(
      id: id,
      productId: productId,
      symbol: symbol,
      side: side,
      entryTime: entryTime,
      exitTime: exitTime,
      entryPrice: _firstFill?.price ?? avgEntry,
      exitPrice: avgExit,
      quantity: _entryQty,
      averageEntryPrice: avgEntry,
      averageExitPrice: avgExit,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
      grossPnl: grossPnl,
      fees: fees,
      funding: fundingTotal,
      netPnl: netPnl,
      duration: duration,
      leverage: leverage,
      orderIds: orderIds.toSet().toList(),
      fillIds: fillIds,
      status: status,
    );
  }

  static DateTime _microsToDate(int micros) {
    if (micros > 1e15) {
      return DateTime.fromMicrosecondsSinceEpoch(micros);
    }
    if (micros > 1e12) {
      return DateTime.fromMillisecondsSinceEpoch(micros ~/ 1000);
    }
    return DateTime.fromMillisecondsSinceEpoch(micros);
  }

  static String _stableId(int productId, List<String> fillIds) {
    final payload = '$productId:${fillIds.join(',')}';
    return sha256.convert(utf8.encode(payload)).toString().substring(0, 24);
  }
}
