import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:partner_in_trade_web/app/app.dart';

void main() {
  testWidgets('Dashboard loads with Trade Analyzer title', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: PartnerInTradeApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Trade Analyzer'), findsOneWidget);
    expect(find.text('Net P&L'), findsWidgets);
    expect(find.text('Recent trades'), findsOneWidget);
  });
}
