import 'package:cryptonic/core/api_client/dio_client.dart';
import 'package:cryptonic/ui/res/constants/api_urls.dart';
import 'package:dio/dio.dart';

class CompareCryptoRepository {
  final _dio = DioClient.getDio(BaseUrlType.compareBase);
  CancelToken cancelToken = CancelToken();

  Future<Response> getCopmarison({
    required String fromSym,
    required String toSym,
    required String toFiat,
  }) async {
    Map<String, String> param = {
      "fsyms": "$fromSym,$toSym",
      "tsyms": "$fromSym,$toSym,$toFiat",
    };
    final response = _dio.get(
      ApiUrls.copmareCryptos,
      queryParameters: param,
      cancelToken: cancelToken,
    );
    return response;
  }
}
