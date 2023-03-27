import 'package:cryptonic/src/utils/constants/api_urls.dart';
import 'package:dio/dio.dart';

enum BaseUrlType {
  coinBase,
  compareBase;
}

class DioClient {
  static Dio getDio(BaseUrlType baseUrlType) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl(baseUrlType),
      ),
    );

    return dio;
  }

  static String baseUrl(BaseUrlType baseUrlType) {
    if (baseUrlType == BaseUrlType.coinBase) return ApiUrls.geckoBaseUrl;
    if (baseUrlType == BaseUrlType.compareBase) {
      return ApiUrls.cryptoCompareBaseUrl;
    }

    return "";
  }
}
