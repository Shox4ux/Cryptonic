import 'package:cryptonic/core/api_client/dio_client.dart';
import 'package:cryptonic/src/domain/models/request/compare_request.dart';
import 'package:cryptonic/src/domain/repositories/base_repositories/base_compare_crypto_repo.dart';
import 'package:cryptonic/src/utils/constants/api_urls.dart';
import 'package:dio/dio.dart';

class CompareCryptoRepository extends BaseCompareRepo {
  final _dio = DioClient.getDio(BaseUrlType.compareBase);
  CancelToken cancelToken = CancelToken();

  @override
  Future<Response> getComparison({required CompareRequest request}) async {
    Map<String, String> param = {
      "fsyms": "${request.fromSymbol},${request.toSymbol}",
      "tsyms": "${request.fromSymbol},${request.toSymbol},${request.toFiat}",
    };
    final response = _dio.get(
      ApiUrls.copmareCryptos,
      queryParameters: param,
      cancelToken: cancelToken,
    );
    return response;
  }
}
