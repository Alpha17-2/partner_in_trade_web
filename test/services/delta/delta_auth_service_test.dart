import 'package:flutter_test/flutter_test.dart';
import 'package:partner_in_trade_web/services/delta/delta_auth_service.dart';
import 'package:partner_in_trade_web/services/delta/delta_config.dart';
import 'package:partner_in_trade_web/services/delta/delta_credentials.dart';

void main() {
  test('HMAC signature matches Delta documentation sample', () {
    const credentials = DeltaCredentials(
      apiKey: 'a207900b7693435a8fa9230a38195d',
      apiSecret: '7b6f39dcf660ec1c7c664f612c60410a2bd0c258416b498bf0311f94228f',
      environment: DeltaEnvironment.indiaProduction,
    );
    const auth = DeltaAuthService();
    final signed = auth.sign(
      credentials: credentials,
      method: 'GET',
      requestPath: '/v2/orders',
      queryString: '?product_id=1&state=open',
      body: '',
      timestampSeconds: '1542110948',
    );
    expect(
      signed.signature,
      '4e38dda3e6477092f360ba70399266d8145630b22bcc34c0ec7f804d5746877a',
    );
  });
}
