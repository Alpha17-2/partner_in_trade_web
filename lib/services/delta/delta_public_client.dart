import 'delta_config.dart';
import 'delta_http_executor.dart';

class DeltaPublicClient {
  DeltaPublicClient({
    required DeltaConfig config,
    required DeltaHttpExecutor executor,
  })  : _config = config,
        _executor = executor;

  final DeltaConfig _config;
  final DeltaHttpExecutor _executor;

  DeltaConfig get config => _config;

  Future<Map<String, dynamic>> get(
    String pathUnderV2, {
    Map<String, String>? queryParameters,
  }) {
    final path = '${DeltaConfig.apiPrefix}$pathUnderV2';
    return _executor.getJson(path, queryParameters: queryParameters);
  }
}
