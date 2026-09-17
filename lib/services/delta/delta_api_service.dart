import 'package:http/http.dart' as http;

import 'delta_account_service.dart';
import 'delta_auth_service.dart';
import 'delta_authenticated_client.dart';
import 'delta_config.dart';
import 'delta_credentials.dart';
import 'delta_data_sources.dart';
import 'delta_http_executor.dart';
import 'delta_market_service.dart';
import 'delta_public_client.dart';
import 'delta_trade_service.dart';
import 'models/delta_fill.dart';
import 'models/delta_ohlc_candle.dart';
import 'models/delta_order.dart';
import 'models/delta_page_meta.dart';
import 'models/delta_position.dart';
import 'models/delta_product.dart';
import 'models/delta_trading_preferences.dart';
import 'models/delta_transaction.dart';
import 'models/delta_wallet.dart';

class DeltaApiService
    implements DeltaMarketDataSource, DeltaAccountDataSource, DeltaTradeDataSource {
  DeltaApiService({
    required this.config,
    required this.market,
    this.account,
    this.trade,
  });

  final DeltaConfig config;
  final DeltaMarketService market;
  final DeltaAccountService? account;
  final DeltaTradeService? trade;

  factory DeltaApiService.fromCredentials({
    required DeltaCredentials credentials,
    http.Client? httpClient,
  }) {
    final config = DeltaConfig(environment: credentials.environment);
    final client = httpClient ?? http.Client();
    final executor = DeltaHttpExecutor(config: config, client: client);
    final publicClient = DeltaPublicClient(config: config, executor: executor);
    final market = DeltaMarketService(publicClient: publicClient);
    final authService = DeltaAuthService(userAgent: config.userAgent);
    final authClient = DeltaAuthenticatedClient(
      executor: executor,
      authService: authService,
      credentials: credentials,
    );
    return DeltaApiService(
      config: config,
      market: market,
      account: DeltaAccountService(authClient: authClient),
      trade: DeltaTradeService(authClient: authClient),
    );
  }

  /// Public-only client (no credentials).
  factory DeltaApiService.public({
    required DeltaEnvironment environment,
    http.Client? httpClient,
  }) {
    final config = DeltaConfig(environment: environment);
    final client = httpClient ?? http.Client();
    final executor = DeltaHttpExecutor(config: config, client: client);
    final publicClient = DeltaPublicClient(config: config, executor: executor);
    return DeltaApiService(
      config: config,
      market: DeltaMarketService(publicClient: publicClient),
    );
  }

  DeltaAccountService get _account {
    final a = account;
    if (a == null) {
      throw StateError('Not connected. Provide API credentials first.');
    }
    return a;
  }

  DeltaTradeService get _trade {
    final t = trade;
    if (t == null) {
      throw StateError('Not connected. Provide API credentials first.');
    }
    return t;
  }

  @override
  Future<DeltaPagedResult<DeltaProduct>> getProducts({
    Map<String, String>? queryParameters,
  }) =>
      market.getProducts(queryParameters: queryParameters);

  @override
  Future<DeltaProduct> getProductBySymbol(String symbol) =>
      market.getProductBySymbol(symbol);

  @override
  Future<List<DeltaOhlcCandle>> getOhlcCandles({
    required String symbol,
    required String resolution,
    required int start,
    required int end,
  }) =>
      market.getOhlcCandles(
        symbol: symbol,
        resolution: resolution,
        start: start,
        end: end,
      );

  @override
  Future<DeltaTradingPreferences> getTradingPreferences() =>
      _account.getTradingPreferences();

  @override
  Future<DeltaWalletBalancesResponse> getWalletBalances() =>
      _account.getWalletBalances();

  @override
  Future<DeltaPagedResult<DeltaTransaction>> getWalletTransactions({
    Map<String, String>? queryParameters,
  }) =>
      _account.getWalletTransactions(queryParameters: queryParameters);

  @override
  Future<DeltaPagedResult<DeltaOrder>> getActiveOrders({
    Map<String, String>? queryParameters,
  }) =>
      _trade.getActiveOrders(queryParameters: queryParameters);

  @override
  Future<DeltaPagedResult<DeltaOrder>> getOrderHistory({
    Map<String, String>? queryParameters,
  }) =>
      _trade.getOrderHistory(queryParameters: queryParameters);

  @override
  Future<DeltaPagedResult<DeltaFill>> getFills({
    Map<String, String>? queryParameters,
  }) =>
      _trade.getFills(queryParameters: queryParameters);

  @override
  Future<List<DeltaPosition>> getMarginedPositions({
    Map<String, String>? queryParameters,
  }) =>
      _trade.getMarginedPositions(queryParameters: queryParameters);

  @override
  Future<DeltaPosition> getPosition({required int productId}) =>
      _trade.getPosition(productId: productId);

  /// Public ping + optional authenticated verification.
  Future<void> testConnection({DeltaCredentials? credentials}) async {
    await market.getProducts(queryParameters: {'page_size': '1'});
    if (credentials != null) {
      final authed = DeltaApiService.fromCredentials(credentials: credentials);
      await authed.getTradingPreferences();
    }
  }
}
