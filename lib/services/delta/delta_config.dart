enum DeltaEnvironment {
  indiaProduction,
  indiaTestnet,
}

extension DeltaEnvironmentLabel on DeltaEnvironment {
  String get label {
    switch (this) {
      case DeltaEnvironment.indiaProduction:
        return 'India Production';
      case DeltaEnvironment.indiaTestnet:
        return 'India Testnet';
    }
  }
}

class DeltaConfig {
  const DeltaConfig({
    required this.environment,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 30),
    this.userAgent = 'partner-in-trade-web',
    this.maxHistoryPageSize = 50,
  });

  final DeltaEnvironment environment;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final String userAgent;
  final int maxHistoryPageSize;

  String get baseUrl {
    switch (environment) {
      case DeltaEnvironment.indiaProduction:
        return 'https://api.india.delta.exchange';
      case DeltaEnvironment.indiaTestnet:
        return 'https://cdn-ind.testnet.deltaex.org';
    }
  }

  static const apiPrefix = '/v2';
}
