import 'dart:convert';

import 'package:http/http.dart' as http;

import 'delta_exceptions.dart';
import 'models/delta_page_meta.dart';

class DeltaResponseParser {
  Map<String, dynamic> parseJsonBody(http.Response response) {
    if (response.body.isEmpty) {
      throw const DeltaParseException('Empty response body.');
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const DeltaParseException();
      }
      return decoded;
    } catch (_) {
      throw const DeltaParseException();
    }
  }

  void throwForHttpStatus(http.Response response) {
    if (response.statusCode == 429) {
      final reset = response.headers['x-rate-limit-reset'];
      throw DeltaRateLimitException(
        resetAfterMs: reset != null ? int.tryParse(reset) : null,
      );
    }
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    Map<String, dynamic>? body;
    try {
      body = parseJsonBody(response);
    } catch (_) {
      throw DeltaHttpException(
        statusCode: response.statusCode,
        message: 'Request failed (${response.statusCode}).',
      );
    }

    _throwFromErrorBody(response.statusCode, body);
  }

  T unwrapResult<T>(
    Map<String, dynamic> body,
    T Function(dynamic result) map,
  ) {
    if (body['success'] == false) {
      _throwFromErrorBody(400, body);
    }
    return map(body['result']);
  }

  DeltaPagedResult<T> unwrapPagedList<T>(
    Map<String, dynamic> body,
    T Function(Map<String, dynamic> json) itemMapper,
  ) {
    if (body['success'] == false) {
      _throwFromErrorBody(400, body);
    }
    final result = body['result'];
    final items = result is List
        ? result
            .whereType<Map<String, dynamic>>()
            .map(itemMapper)
            .toList()
        : <T>[];
    final meta = DeltaPageMeta.fromJson(
      body['meta'] as Map<String, dynamic>?,
    );
    return DeltaPagedResult(items: items, meta: meta);
  }

  void _throwFromErrorBody(int statusCode, Map<String, dynamic> body) {
    final error = body['error'];
    String? code;
    String message = 'Request failed.';

    if (error is String) {
      code = error;
      message = _messageForLegacyError(error, body['message'] as String?);
    } else if (error is Map<String, dynamic>) {
      code = error['code']?.toString();
      message = code != null ? _messageForCode(code) : message;
    } else if (body['message'] is String) {
      message = body['message'] as String;
    }

    final canonical = _canonicalErrorCode(code);
    if (canonical != null) {
      message = _messageForCode(canonical);
    }

    if (_isAuthError(canonical ?? code, statusCode)) {
      throw DeltaAuthException(message: message, errorCode: code);
    }

    throw DeltaApiFailureException(message: message, errorCode: code);
  }

  bool _isAuthError(String? code, int statusCode) {
    if (statusCode == 401 || statusCode == 403) return true;
    final canonical = _canonicalErrorCode(code);
    return canonical != null && _knownAuthCodes.contains(canonical);
  }

  /// Maps API variants (e.g. `Invalid_api_key`) to canonical codes.
  String? _canonicalErrorCode(String? code) {
    if (code == null) return null;
    final normalized =
        code.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
    switch (normalized) {
      case 'invalid_api_key':
      case 'invalidapikey':
        return 'InvalidApiKey';
      case 'signatureexpired':
        return 'SignatureExpired';
      case 'unauthorizedapiaccess':
        return 'UnauthorizedApiAccess';
      case 'signature_mismatch':
        return 'Signature Mismatch';
      case 'ip_not_whitelisted_for_api_key':
        return 'ip_not_whitelisted_for_api_key';
      default:
        return _knownAuthCodes.contains(code) ? code : null;
    }
  }

  static const _knownAuthCodes = {
    'InvalidApiKey',
    'SignatureExpired',
    'UnauthorizedApiAccess',
    'ip_not_whitelisted_for_api_key',
    'Signature Mismatch',
  };

  String _messageForLegacyError(String error, String? apiMessage) {
    final canonical = _canonicalErrorCode(error);
    if (canonical == 'InvalidApiKey') {
      return _messageForCode('InvalidApiKey');
    }
    if (apiMessage != null && apiMessage.isNotEmpty) return apiMessage;
    return _messageForCode(canonical ?? error);
  }

  String _messageForCode(String code) {
    switch (code) {
      case 'InvalidApiKey':
        return 'Invalid API key. Use India keys on India Production, demo keys on '
            'India Testnet. Keys from global Delta or the wrong site will not work.';
      case 'SignatureExpired':
        return 'Signature expired. Sync your system clock and try again.';
      case 'UnauthorizedApiAccess':
        return 'API key lacks permission for this endpoint. Enable Read Data and Trading on the key.';
      case 'ip_not_whitelisted_for_api_key':
        return 'Your IP is not whitelisted for this API key.';
      case 'Signature Mismatch':
        return 'Signature mismatch. Check API secret and request format.';
      default:
        return 'Delta API error: $code';
    }
  }
}
