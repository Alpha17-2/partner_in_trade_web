import 'package:http/http.dart' as http;

import 'delta_config.dart';
import 'delta_exceptions.dart';
import 'delta_response_parser.dart';

class DeltaHttpExecutor {
  DeltaHttpExecutor({
    required this.config,
    required this.client,
    DeltaResponseParser? parser,
  }) : _parser = parser ?? DeltaResponseParser();

  final DeltaConfig config;
  final http.Client client;
  final DeltaResponseParser _parser;

  Future<http.Response> get(
    String pathWithPrefix, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(pathWithPrefix, queryParameters);
    try {
      final response = await client
          .get(uri, headers: _baseHeaders(headers))
          .timeout(config.receiveTimeout);
      return response;
    } on DeltaException {
      rethrow;
    } on http.ClientException catch (e) {
      if (_looksLikeCors(e.message)) {
        throw const DeltaCorsBlockedException();
      }
      throw DeltaNetworkException(e.message);
    } catch (_) {
      throw const DeltaTimeoutException();
    }
  }

  Future<Map<String, dynamic>> getJson(
    String pathWithPrefix, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final response = await get(
      pathWithPrefix,
      queryParameters: queryParameters,
      headers: headers,
    );
    _parser.throwForHttpStatus(response);
    return _parser.parseJsonBody(response);
  }

  Uri _buildUri(String pathWithPrefix, Map<String, String>? queryParameters) {
    final base = config.baseUrl;
    final path = pathWithPrefix.startsWith('/')
        ? pathWithPrefix
        : '${DeltaConfig.apiPrefix}/$pathWithPrefix';
    return Uri.parse('$base$path').replace(
      queryParameters: queryParameters?.isEmpty ?? true ? null : queryParameters,
    );
  }

  Map<String, String> _baseHeaders(Map<String, String>? extra) {
    return {
      'Accept': 'application/json',
      'User-Agent': config.userAgent,
      if (extra != null) ...extra,
    };
  }

  bool _looksLikeCors(String message) {
    final lower = message.toLowerCase();
    return lower.contains('xmlhttprequest') ||
        lower.contains('cors') ||
        lower.contains('failed to fetch');
  }

  /// Builds query string with leading `?` for signing.
  static String queryStringForSign(Map<String, String>? queryParameters) {
    if (queryParameters == null || queryParameters.isEmpty) return '';
    final uri = Uri(queryParameters: queryParameters);
    return '?${uri.query}';
  }
}
