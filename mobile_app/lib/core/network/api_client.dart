import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/constants.dart';

class ApiClient {
  late Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            final refreshToken = await _storage.read(key: 'refreshToken');
            if (refreshToken != null) {
              try {
                // Attempt to refresh token
                final refreshResponse = await Dio().post(
                  '${AppConstants.apiBaseUrl}/auth/refresh',
                  data: {'refreshToken': refreshToken},
                );

                if (refreshResponse.statusCode == 200) {
                  final newToken = refreshResponse.data['data']['accessToken'];
                  await _storage.write(key: 'accessToken', value: newToken);

                  // Retry the original request
                  final options = e.requestOptions;
                  options.headers['Authorization'] = 'Bearer $newToken';
                  final retryResponse = await Dio().fetch(options);
                  return handler.resolve(retryResponse);
                }
              } catch (refreshError) {
                // Refresh failed, logout user or handle accordingly
                await _storage.deleteAll();
              }
            }
          }
          return handler.next(e);
        },
      ),
    );

    // Log for debugging (only in debug mode)
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(responseBody: true, requestBody: true),
      );
    }
  }
}
