import 'delta_authenticated_client.dart';
import 'delta_data_sources.dart';
import 'delta_exceptions.dart';
import 'delta_response_parser.dart';
import 'models/delta_fill.dart';
import 'models/delta_order.dart';
import 'models/delta_page_meta.dart';
import 'models/delta_position.dart';

class DeltaTradeService implements DeltaTradeDataSource {
  DeltaTradeService({
    required DeltaAuthenticatedClient authClient,
    DeltaResponseParser? parser,
  })  : _auth = authClient,
        _parser = parser ?? DeltaResponseParser();

  final DeltaAuthenticatedClient _auth;
  final DeltaResponseParser _parser;

  @override
  Future<DeltaPagedResult<DeltaOrder>> getActiveOrders({
    Map<String, String>? queryParameters,
  }) async {
    final body = await _auth.get('/orders', queryParameters: queryParameters);
    return _parser.unwrapPagedList(body, DeltaOrder.fromJson);
  }

  @override
  Future<DeltaPagedResult<DeltaOrder>> getOrderHistory({
    Map<String, String>? queryParameters,
  }) async {
    final body = await _auth.get(
      '/orders/history',
      queryParameters: queryParameters,
    );
    return _parser.unwrapPagedList(body, DeltaOrder.fromJson);
  }

  @override
  Future<DeltaPagedResult<DeltaFill>> getFills({
    Map<String, String>? queryParameters,
  }) async {
    final body = await _auth.get('/fills', queryParameters: queryParameters);
    return _parser.unwrapPagedList(body, DeltaFill.fromJson);
  }

  @override
  Future<List<DeltaPosition>> getMarginedPositions({
    Map<String, String>? queryParameters,
  }) async {
    final body = await _auth.get(
      '/positions/margined',
      queryParameters: queryParameters,
    );
    return _parser.unwrapResult(body, (r) {
      if (r is! List) return <DeltaPosition>[];
      return r
          .whereType<Map<String, dynamic>>()
          .map(DeltaPosition.fromJson)
          .toList();
    });
  }

  @override
  Future<DeltaPosition> getPosition({required int productId}) async {
    final body = await _auth.get(
      '/positions',
      queryParameters: {'product_id': productId.toString()},
    );
    return _parser.unwrapResult(body, (r) {
      if (r is Map<String, dynamic>) return DeltaPosition.fromJson(r);
      throw const DeltaParseException();
    });
  }
}
