import 'delta_data_sources.dart';
import 'delta_exceptions.dart';
import 'delta_public_client.dart';
import 'delta_response_parser.dart';
import 'models/delta_ohlc_candle.dart';
import 'models/delta_page_meta.dart';
import 'models/delta_product.dart';

class DeltaMarketService implements DeltaMarketDataSource {
  DeltaMarketService({
    required DeltaPublicClient publicClient,
    DeltaResponseParser? parser,
  })  : _public = publicClient,
        _parser = parser ?? DeltaResponseParser();

  final DeltaPublicClient _public;
  final DeltaResponseParser _parser;

  @override
  Future<DeltaPagedResult<DeltaProduct>> getProducts({
    Map<String, String>? queryParameters,
  }) async {
    final body = await _public.get('/products', queryParameters: queryParameters);
    return _parser.unwrapPagedList(body, DeltaProduct.fromJson);
  }

  @override
  Future<DeltaProduct> getProductBySymbol(String symbol) async {
    final body = await _public.get('/products/$symbol');
    return _parser.unwrapResult(body, (r) {
      if (r is Map<String, dynamic>) return DeltaProduct.fromJson(r);
      throw const DeltaParseException();
    });
  }

  @override
  Future<List<DeltaOhlcCandle>> getOhlcCandles({
    required String symbol,
    required String resolution,
    required int start,
    required int end,
  }) async {
    final body = await _public.get(
      '/history/candles',
      queryParameters: {
        'symbol': symbol,
        'resolution': resolution,
        'start': start.toString(),
        'end': end.toString(),
      },
    );
    return _parser.unwrapResult(body, (r) {
      if (r is! List) return <DeltaOhlcCandle>[];
      return r.map(DeltaOhlcCandle.fromRow).whereType<DeltaOhlcCandle>().toList();
    });
  }
}
