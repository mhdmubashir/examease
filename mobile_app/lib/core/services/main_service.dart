import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_response.dart';

class MainService {
  final ApiClient apiClient;
  final String apiKey;

  MainService({required this.apiClient, required this.apiKey});

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    required T Function(Object?) fromJsonT,
  }) async {
    try {
      final response = await apiClient.dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: {'x-api-key': apiKey}),
      );
      return ApiResponse.fromJson(response.data, fromJsonT);
    } on DioException catch (e) {
      return _handleError(e, fromJsonT);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    required T Function(Object?) fromJsonT,
  }) async {
    try {
      final response = await apiClient.dio.post(
        endpoint,
        data: data,
        options: Options(headers: {'x-api-key': apiKey}),
      );
      return ApiResponse.fromJson(response.data, fromJsonT);
    } on DioException catch (e) {
      return _handleError(e, fromJsonT);
    }
  }

  ApiResponse<T> _handleError<T>(
    DioException e,
    T Function(Object?) fromJsonT,
  ) {
    if (e.response != null && e.response!.data is Map) {
      return ApiResponse.fromJson(
        e.response!.data as Map<String, dynamic>,
        fromJsonT,
      );
    }
    return ApiResponse(
      status: false,
      message: e.message ?? 'An unexpected error occurred',
    );
  }
}
