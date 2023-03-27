import 'package:cryptonic/src/domain/models/request/grahp_data_request.dart';
import 'package:dio/dio.dart';

abstract class BaseCryptoRepo {
  Future<Response> getCoinMarket({required String currency});

  Future<Response> getGraphData({required GraphDataRequest request});
}
