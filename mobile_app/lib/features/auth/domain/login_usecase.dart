import '../../../core/network/api_response.dart';
import '../domain/auth_repository.dart';
import '../domain/user_model.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<ApiResponse<UserModel>> call({
    required String email,
    required String password,
  }) async {
    final response = await repository.login(email, password);
    if (response.status && response.data != null) {
      return ApiResponse(
        status: true,
        message: response.message,
        data: response.data,
      );
    }
    return ApiResponse(status: false, message: response.message);
  }
}
