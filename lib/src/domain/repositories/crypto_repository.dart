import 'package:cryptonic/core/api_client/dio_client.dart';
import 'package:cryptonic/src/domain/models/request/grahp_data_request.dart';
import 'package:cryptonic/src/domain/repositories/base_repositories/base_crypto_repo.dart';
import 'package:cryptonic/src/utils/constants/api_urls.dart';
import 'package:dio/dio.dart';

class CryptoRepository extends BaseCryptoRepo {
  final _dio = DioClient.getDio(BaseUrlType.coinBase);

  @override
  Future<Response> getCoinMarket({required String currency}) async {
    Map<String, dynamic> param = {"vs_currency": currency};
    final response =
        await _dio.get(ApiUrls.coinMarketUrl, queryParameters: param);
    return response;
  }

  @override
  Future<Response> getGraphData({required GraphDataRequest request}) async {
    Map<String, dynamic> param = {
      "vs_currency": request.currency,
      "days": request.days,
      "interval": request.interval,
    };

    final response = await _dio.get(
      ApiUrls.coinGraphDataUrl(coinId: request.coinId),
      queryParameters: param,
    );

    return response;
  }
}
