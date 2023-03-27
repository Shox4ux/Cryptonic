import 'package:cryptonic/src/domain/models/request/compare_request.dart';
import 'package:dio/dio.dart';

abstract class BaseCompareRepo {
  Future<Response> getComparison({required CompareRequest request});
}
