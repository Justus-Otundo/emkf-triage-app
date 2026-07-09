import 'package:dio/dio.dart';
import 'package:emkf_triage_app/core/constants/app_constants.dart';
import 'package:emkf_triage_app/core/errors/exceptions.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({Dio? dio}) {
    _dio = dio ??
        Dio(
          BaseOptions(
            baseUrl: AppConstants.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );
  }

  Future<Response> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response;
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Something went wrong',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Response> get(String endpoint, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: params);
      return response;
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Something went wrong',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
