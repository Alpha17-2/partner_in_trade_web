import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'delta_credentials.dart';

class DeltaSignedHeaders {
  const DeltaSignedHeaders({
    required this.apiKey,
    required this.timestamp,
    required this.signature,
    required this.userAgent,
  });

  final String apiKey;
  final String timestamp;
  final String signature;
  final String userAgent;

  Map<String, String> toMap() => {
        'api-key': apiKey,
        'timestamp': timestamp,
        'signature': signature,
        'User-Agent': userAgent,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
}

class DeltaAuthService {
  const DeltaAuthService({this.userAgent = 'partner-in-trade-web'});

  final String userAgent;

  /// [requestPath] e.g. `/v2/orders`
  /// [queryString] includes leading `?` or empty string.
  DeltaSignedHeaders sign({
    required DeltaCredentials credentials,
    required String method,
    required String requestPath,
    required String queryString,
    String body = '',
    String? timestampSeconds,
  }) {
    final timestamp = timestampSeconds ?? _unixSeconds();
    final prehash = method + timestamp + requestPath + queryString + body;
    final signature = _hmacSha256Hex(credentials.apiSecret, prehash);
    return DeltaSignedHeaders(
      apiKey: credentials.apiKey,
      timestamp: timestamp,
      signature: signature,
      userAgent: userAgent,
    );
  }

  static String _unixSeconds() =>
      (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

  static String _hmacSha256Hex(String secret, String message) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(message);
    final digest = Hmac(sha256, key).convert(bytes);
    return digest.toString();
  }
}
