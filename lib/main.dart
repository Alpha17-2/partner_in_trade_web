import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'services/delta/hive_delta_credentials_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>('app_global');
  await hiveDeltaCredentialsStore.loadFromDisk();

  runApp(
    const ProviderScope(
      child: PartnerInTradeApp(),
    ),
  );
}
