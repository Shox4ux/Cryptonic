import 'package:cryptonic/core/api_client/dio_client.dart';
import 'package:cryptonic/ui/res/constants/api_urls.dart';
import 'package:dio/dio.dart';

class CryptoRepository {
  final _dio = DioClient.getDio(BaseUrlType.coinBase);

  Future<Response> getCoinMarket({required String currency}) async {
    Map<String, dynamic> param = {"vs_currency": currency};
    final response =
        await _dio.get(ApiUrls.coinMarketUrl, queryParameters: param);
    return response;
  }

  Future<Response> getCoinGraphDataById({
    required String coinId,
    required String days,
    required String currency,
    required String interval,
  }) async {
    Map<String, dynamic> param = {
      "vs_currency": currency,
      "days": days,
      "interval": interval,
    };

    final response = await _dio.get(
      ApiUrls.coinGraphDataUrl(coinId: coinId),
      queryParameters: param,
    );

    return response;
  }
}
