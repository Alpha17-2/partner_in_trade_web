import 'delta_auth_service.dart';
import 'delta_config.dart';
import 'delta_credentials.dart';
import 'delta_http_executor.dart';

class DeltaAuthenticatedClient {
  DeltaAuthenticatedClient({
    required DeltaHttpExecutor executor,
    required DeltaAuthService authService,
    required DeltaCredentials credentials,
  })  : _executor = executor,
        _authService = authService,
        _credentials = credentials;

  final DeltaHttpExecutor _executor;
  final DeltaAuthService _authService;
  final DeltaCredentials _credentials;

  Future<Map<String, dynamic>> get(
    String pathUnderV2, {
    Map<String, String>? queryParameters,
  }) async {
    final requestPath = '${DeltaConfig.apiPrefix}$pathUnderV2';
    final queryString =
        DeltaHttpExecutor.queryStringForSign(queryParameters);
    final signed = _authService.sign(
      credentials: _credentials,
      method: 'GET',
      requestPath: requestPath,
      queryString: queryString,
    );
    return _executor.getJson(
      requestPath,
      queryParameters: queryParameters,
      headers: signed.toMap(),
    );
  }
}
