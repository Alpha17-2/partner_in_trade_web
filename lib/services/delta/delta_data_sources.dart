import 'models/delta_fill.dart';
import 'models/delta_ohlc_candle.dart';
import 'models/delta_order.dart';
import 'models/delta_page_meta.dart';
import 'models/delta_position.dart';
import 'models/delta_product.dart';
import 'models/delta_trading_preferences.dart';
import 'models/delta_transaction.dart';
import 'models/delta_wallet.dart';

abstract class DeltaMarketDataSource {
  Future<DeltaPagedResult<DeltaProduct>> getProducts({
    Map<String, String>? queryParameters,
  });

  Future<DeltaProduct> getProductBySymbol(String symbol);

  Future<List<DeltaOhlcCandle>> getOhlcCandles({
    required String symbol,
    required String resolution,
    required int start,
    required int end,
  });
}

abstract class DeltaAccountDataSource {
  Future<DeltaTradingPreferences> getTradingPreferences();

  Future<DeltaWalletBalancesResponse> getWalletBalances();

  Future<DeltaPagedResult<DeltaTransaction>> getWalletTransactions({
    Map<String, String>? queryParameters,
  });
}

abstract class DeltaTradeDataSource {
  Future<DeltaPagedResult<DeltaOrder>> getActiveOrders({
    Map<String, String>? queryParameters,
  });

  Future<DeltaPagedResult<DeltaOrder>> getOrderHistory({
    Map<String, String>? queryParameters,
  });

  Future<DeltaPagedResult<DeltaFill>> getFills({
    Map<String, String>? queryParameters,
  });

  Future<List<DeltaPosition>> getMarginedPositions({
    Map<String, String>? queryParameters,
  });

  Future<DeltaPosition> getPosition({required int productId});
}
