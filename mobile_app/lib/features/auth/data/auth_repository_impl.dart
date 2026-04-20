import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/main_service.dart';
import '../../../core/network/api_response.dart';
import '../domain/auth_repository.dart';
import '../domain/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final MainService mainService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthRepositoryImpl(this.mainService);

  @override
  Future<ApiResponse<UserModel>> login(String email, String password) async {
    final response = await mainService.post<dynamic>(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
      fromJsonT: (json) => json,
    );

    return _handleAuthResponse(response);
  }

  @override
  Future<ApiResponse<UserModel>> verifyOtp(String email, String otp) async {
    final response = await mainService.post<dynamic>(
      ApiEndpoints.verifyOtp,
      data: {'email': email, 'otp': otp},
      fromJsonT: (json) => json,
    );

    return _handleAuthResponse(response);
  }

  @override
  Future<ApiResponse<void>> resendOtp(String email) async {
    return await mainService.post<void>(
      ApiEndpoints.resendOtp,
      data: {'email': email},
      fromJsonT: (json) {},
    );
  }

  @override
  Future<ApiResponse<UserModel>> signInWithGoogle(String idToken) async {
    final response = await mainService.post<dynamic>(
      ApiEndpoints.googleAuth,
      data: {'idToken': idToken},
      fromJsonT: (json) => json,
    );

    return _handleAuthResponse(response);
  }

  Future<ApiResponse<UserModel>> _handleAuthResponse(
    ApiResponse<dynamic> response,
  ) async {
    if (response.status && response.data != null) {
      final dataMap = response.data as Map<String, dynamic>;
      final userMap = dataMap['user'] as Map<String, dynamic>;
      final accessToken = dataMap['accessToken'] as String?;
      final refreshToken = dataMap['refreshToken'] as String?;

      if (accessToken != null) {
        await _storage.write(key: 'accessToken', value: accessToken);
      }
      if (refreshToken != null) {
        await _storage.write(key: 'refreshToken', value: refreshToken);
      }

      return ApiResponse<UserModel>(
        status: response.status,
        message: response.message,
        data: UserModel.fromJson(userMap),
        pagination: response.pagination,
      );
    }

    return ApiResponse<UserModel>(
      status: response.status,
      message: response.message,
      data: null,
      pagination: response.pagination,
    );
  }

  @override
  Future<ApiResponse<void>> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    return await mainService.post<void>(
      ApiEndpoints.register,
      data: {'name': name, 'email': email, 'phone': phone, 'password': password},
      fromJsonT: (json) {},
    );
  }

  @override
  Future<void> logout() async {
    await _storage.deleteAll();
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: 'accessToken');
    return token != null;
  }

  @override
  Future<ApiResponse<UserModel>> getProfile() async {
    return await mainService.get<UserModel>(
      ApiEndpoints.profile,
      fromJsonT: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
