import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:partner_in_trade_web/services/delta/delta_exceptions.dart';
import 'package:partner_in_trade_web/services/delta/delta_response_parser.dart';

void main() {
  final parser = DeltaResponseParser();

  test('unwrapResult returns mapped result on success', () {
    final body = parser.unwrapResult<int>(
      {'success': true, 'result': 42},
      (r) => r as int,
    );
    expect(body, 42);
  });

  test('throwForHttpStatus maps 429 to rate limit', () {
    expect(
      () => parser.throwForHttpStatus(
        http.Response('{}', 429, headers: {'x-rate-limit-reset': '5000'}),
      ),
      throwsA(isA<DeltaRateLimitException>()),
    );
  });

  test('throws DeltaAuthException for Invalid_api_key variant', () {
    expect(
      () => parser.throwForHttpStatus(
        http.Response(
          '{"success":false,"error":{"code":"Invalid_api_key"}}',
          401,
        ),
      ),
      throwsA(
        predicate<DeltaAuthException>(
          (e) => e.message.contains('Invalid API key'),
        ),
      ),
    );
  });

  test('throws DeltaAuthException for InvalidApiKey', () {
    expect(
      () => parser.throwForHttpStatus(
        http.Response(
          '{"success":false,"error":"InvalidApiKey","message":"Api Key not found"}',
          401,
        ),
      ),
      throwsA(isA<DeltaAuthException>()),
    );
  });
}
