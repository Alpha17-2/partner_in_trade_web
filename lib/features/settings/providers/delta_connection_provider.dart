import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_ui_providers.dart';
import '../../../services/delta/delta_api_service.dart';
import '../../../services/delta/delta_config.dart';
import '../../../services/delta/delta_credentials.dart';
import '../../../services/delta/delta_exceptions.dart';
import '../../../services/delta/hive_delta_credentials_store.dart';

final deltaCredentialsStoreProvider = Provider<DeltaCredentialsStore>((ref) {
  return hiveDeltaCredentialsStore;
});

final deltaEnvironmentProvider = StateProvider<DeltaEnvironment>(
  (ref) => DeltaEnvironment.indiaProduction,
);

final deltaApiServiceProvider = Provider<DeltaApiService?>((ref) {
  final store = ref.watch(deltaCredentialsStoreProvider);
  final credentials = store.read();
  if (credentials == null) return null;
  return DeltaApiService.fromCredentials(credentials: credentials);
});

class DeltaConnectionState {
  const DeltaConnectionState({
    required this.status,
    this.message,
  });

  final DeltaConnectionStatus status;
  final String? message;
}

class DeltaConnectionController extends Notifier<DeltaConnectionState> {
  @override
  DeltaConnectionState build() {
    final store = ref.read(deltaCredentialsStoreProvider);
    final creds = store.read();
    if (creds != null) {
      ref.read(deltaEnvironmentProvider.notifier).state = creds.environment;
      return const DeltaConnectionState(status: DeltaConnectionStatus.connected);
    }
    return const DeltaConnectionState(status: DeltaConnectionStatus.notConnected);
  }

  void disconnect() {
    ref.read(deltaCredentialsStoreProvider).clear();
    state = const DeltaConnectionState(status: DeltaConnectionStatus.notConnected);
  }

  Future<void> connect({
    required String apiKey,
    required String apiSecret,
    required DeltaEnvironment environment,
  }) async {
    final trimmedKey = apiKey.trim();
    final trimmedSecret = apiSecret.trim();
    if (trimmedKey.isEmpty || trimmedSecret.isEmpty) {
      state = const DeltaConnectionState(
        status: DeltaConnectionStatus.error,
        message: 'API key and secret are required.',
      );
      return;
    }

    final credentials = DeltaCredentials(
      apiKey: trimmedKey,
      apiSecret: trimmedSecret,
      environment: environment,
    );
    ref.read(deltaCredentialsStoreProvider).save(credentials);
    ref.read(deltaEnvironmentProvider.notifier).state = environment;
    state = const DeltaConnectionState(status: DeltaConnectionStatus.connected);
  }

  Future<void> testConnection({
    required String apiKey,
    required String apiSecret,
    required DeltaEnvironment environment,
  }) async {
    state = const DeltaConnectionState(
      status: DeltaConnectionStatus.notConnected,
      message: 'Testing connection…',
    );
    try {
      final credentials = DeltaCredentials(
        apiKey: apiKey.trim(),
        apiSecret: apiSecret.trim(),
        environment: environment,
      );
      final publicApi = DeltaApiService.public(environment: environment);
      await publicApi.getProducts(queryParameters: {'page_size': '1'});
      await DeltaApiService.fromCredentials(credentials: credentials)
          .getTradingPreferences();
      state = const DeltaConnectionState(
        status: DeltaConnectionStatus.connected,
        message: 'Connection successful.',
      );
    } on DeltaException catch (e) {
      state = DeltaConnectionState(
        status: DeltaConnectionStatus.error,
        message: e.message,
      );
    } catch (_) {
      state = const DeltaConnectionState(
        status: DeltaConnectionStatus.error,
        message: 'Connection test failed.',
      );
    }
  }
}

final deltaConnectionControllerProvider =
    NotifierProvider<DeltaConnectionController, DeltaConnectionState>(
  DeltaConnectionController.new,
);

final deltaConnectionProvider = Provider<DeltaConnectionStatus>((ref) {
  return ref.watch(deltaConnectionControllerProvider).status;
});
