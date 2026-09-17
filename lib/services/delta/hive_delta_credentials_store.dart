import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import 'delta_config.dart';
import 'delta_credentials.dart';

/// Persists API key/secret in Hive (browser IndexedDB). Not encrypted — local dev only.
class HiveDeltaCredentialsStore implements DeltaCredentialsStore {
  HiveDeltaCredentialsStore();

  static const boxName = 'delta_credentials';
  static const storageKey = 'saved';

  DeltaCredentials? _credentials;

  @override
  DeltaCredentials? read() => _credentials;

  @override
  void save(DeltaCredentials credentials) {
    _credentials = credentials;
    _write(credentials);
  }

  @override
  void saveDraft({
    required String apiKey,
    required String apiSecret,
    required DeltaEnvironment environment,
  }) {
    if (apiKey.isEmpty && apiSecret.isEmpty) return;
    final draft = DeltaCredentials(
      apiKey: apiKey,
      apiSecret: apiSecret,
      environment: environment,
    );
    _write(draft);
    if (apiKey.isNotEmpty && apiSecret.isNotEmpty) {
      _credentials = draft;
    }
  }

  @override
  void clear() {
    _credentials = null;
    _delete();
  }

  @override
  Future<void> loadFromDisk() async {
    final box = await Hive.openBox<String>(boxName);
    final raw = box.get(storageKey);
    if (raw == null) return;
    try {
      final creds = DeltaCredentials.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      if (creds.apiKey.isEmpty || creds.apiSecret.isEmpty) return;
      _credentials = creds;
    } catch (_) {
      await box.delete(storageKey);
    }
  }

  Future<void> _write(DeltaCredentials credentials) async {
    final box = await Hive.openBox<String>(boxName);
    await box.put(storageKey, jsonEncode(credentials.toJson()));
  }

  Future<void> _delete() async {
    final box = await Hive.openBox<String>(boxName);
    await box.delete(storageKey);
  }
}

final hiveDeltaCredentialsStore = HiveDeltaCredentialsStore();
