import 'delta_authenticated_client.dart';
import 'delta_data_sources.dart';
import 'delta_exceptions.dart';
import 'delta_response_parser.dart';
import 'models/delta_page_meta.dart';
import 'models/delta_trading_preferences.dart';
import 'models/delta_transaction.dart';
import 'models/delta_wallet.dart';

class DeltaAccountService implements DeltaAccountDataSource {
  DeltaAccountService({
    required DeltaAuthenticatedClient authClient,
    DeltaResponseParser? parser,
  })  : _auth = authClient,
        _parser = parser ?? DeltaResponseParser();

  final DeltaAuthenticatedClient _auth;
  final DeltaResponseParser _parser;

  @override
  Future<DeltaTradingPreferences> getTradingPreferences() async {
    final body = await _auth.get('/users/trading_preferences');
    return _parser.unwrapResult(body, (r) {
      if (r is Map<String, dynamic>) {
        return DeltaTradingPreferences.fromJson(r);
      }
      throw const DeltaParseException();
    });
  }

  @override
  Future<DeltaWalletBalancesResponse> getWalletBalances() async {
    final body = await _auth.get('/wallet/balances');
    return DeltaWalletBalancesResponse.fromJson(body);
  }

  @override
  Future<DeltaPagedResult<DeltaTransaction>> getWalletTransactions({
    Map<String, String>? queryParameters,
  }) async {
    final body = await _auth.get(
      '/wallet/transactions',
      queryParameters: queryParameters,
    );
    return _parser.unwrapPagedList(body, DeltaTransaction.fromJson);
  }
}
