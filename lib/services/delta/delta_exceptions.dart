/// Delta API failures. Never attach secrets to [message] or fields.
sealed class DeltaException implements Exception {
  const DeltaException(this.message);
  final String message;

  @override
  String toString() => message;
}

class DeltaNetworkException extends DeltaException {
  const DeltaNetworkException([super.message = 'Network error. Check your connection.']);
}

class DeltaCorsBlockedException extends DeltaException {
  const DeltaCorsBlockedException([
    super.message =
        'Browser blocked the request (CORS). Authenticated Delta API calls may '
        'require a local proxy or desktop build. See Settings for details.',
  ]);
}

class DeltaTimeoutException extends DeltaException {
  const DeltaTimeoutException([super.message = 'Request timed out.']);
}

class DeltaHttpException extends DeltaException {
  const DeltaHttpException({
    required this.statusCode,
    required String message,
    this.errorCode,
  }) : super(message);

  final int statusCode;
  final String? errorCode;
}

class DeltaAuthException extends DeltaException {
  const DeltaAuthException({
    required String message,
    this.errorCode,
  }) : super(message);

  final String? errorCode;
}

class DeltaRateLimitException extends DeltaException {
  const DeltaRateLimitException({
    String message = 'Rate limit exceeded. Try again shortly.',
    this.resetAfterMs,
  }) : super(message);

  final int? resetAfterMs;
}

class DeltaParseException extends DeltaException {
  const DeltaParseException([super.message = 'Unexpected response from Delta Exchange.']);
}

class DeltaApiFailureException extends DeltaException {
  const DeltaApiFailureException({
    required String message,
    this.errorCode,
  }) : super(message);

  final String? errorCode;
}
