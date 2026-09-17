import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:partner_in_trade_web/app/app.dart';
import 'package:partner_in_trade_web/features/trades/providers/trades_providers.dart';
import 'package:partner_in_trade_web/models/journal_trade.dart';

class _EmptyJournalTradesNotifier extends JournalTradesNotifier {
  @override
  Future<List<JournalTrade>> build() async => [];
}

void main() {
  testWidgets('Dashboard loads with Trade Analyzer title', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          journalTradesProvider.overrideWith(_EmptyJournalTradesNotifier.new),
        ],
        child: const PartnerInTradeApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Trade Analyzer'), findsOneWidget);
    expect(find.text('Net P&L'), findsWidgets);
    expect(find.text('Recent trades'), findsOneWidget);
  });
}
