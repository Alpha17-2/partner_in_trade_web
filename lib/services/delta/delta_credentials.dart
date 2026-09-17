import 'delta_config.dart';

class DeltaCredentials {
  const DeltaCredentials({
    required this.apiKey,
    required this.apiSecret,
    required this.environment,
  });

  final String apiKey;
  final String apiSecret;
  final DeltaEnvironment environment;

  Map<String, dynamic> toJson() => {
        'apiKey': apiKey,
        'apiSecret': apiSecret,
        'environment': environment.name,
      };

  factory DeltaCredentials.fromJson(Map<String, dynamic> json) {
    return DeltaCredentials(
      apiKey: json['apiKey'] as String,
      apiSecret: json['apiSecret'] as String,
      environment: DeltaEnvironment.values.byName(json['environment'] as String),
    );
  }
}

abstract class DeltaCredentialsStore {
  DeltaCredentials? read();
  void save(DeltaCredentials credentials);
  void clear();

  /// Persists draft fields without requiring Connect (autosave).
  void saveDraft({
    required String apiKey,
    required String apiSecret,
    required DeltaEnvironment environment,
  });

  Future<void> loadFromDisk();
}

class InMemoryCredentialsStore implements DeltaCredentialsStore {
  DeltaCredentials? _credentials;

  @override
  DeltaCredentials? read() => _credentials;

  @override
  void save(DeltaCredentials credentials) {
    _credentials = credentials;
  }

  @override
  void clear() {
    _credentials = null;
  }

  @override
  void saveDraft({
    required String apiKey,
    required String apiSecret,
    required DeltaEnvironment environment,
  }) {}

  @override
  Future<void> loadFromDisk() async {}
}
