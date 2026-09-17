import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partner_in_trade_web/app/router.dart';
import 'package:partner_in_trade_web/app/theme/app_theme.dart';
import 'package:partner_in_trade_web/features/journal/domain/daily_journal.dart';
import 'package:partner_in_trade_web/features/journal/domain/daily_journal_image.dart';
import 'package:partner_in_trade_web/features/journal/providers/journal_providers.dart';
import 'package:partner_in_trade_web/features/trades/providers/trades_providers.dart';
import 'package:partner_in_trade_web/models/journal_trade.dart';

class _EmptyTrades extends JournalTradesNotifier {
  @override
  Future<List<JournalTrade>> build() async => [];
}

void main() {
  testWidgets('journal date route loads that day', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = createAppRouter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          journalTradesProvider.overrideWith(_EmptyTrades.new),
          dailyJournalIndexProvider.overrideWith((ref) async => []),
          dailyJournalProvider.overrideWith((ref, dateKey) async {
            return DailyJournal.blank(dateKey).copyWith(
              whatWentWell: 'note for $dateKey',
            );
          }),
          dailyJournalImagesProvider.overrideWith((ref, dateKey) async {
            return <DailyJournalImageMeta>[];
          }),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    router.go('/journal/2026-09-18');
    await tester.pumpAndSettle();

    expect(find.text('18 September 2026'), findsOneWidget);
    expect(find.text('Friday'), findsOneWidget);
    expect(find.text('Back to Journal'), findsOneWidget);
  });
}
