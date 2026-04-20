import '../../../core/network/api_response.dart';
import '../domain/auth_repository.dart';
import '../domain/user_model.dart';

class GetProfileUseCase {
  final AuthRepository repository;

  GetProfileUseCase(this.repository);

  Future<ApiResponse<UserModel>> call() async {
    final response = await repository.getProfile();
    if (response.status && response.data != null) {
      return ApiResponse(
        status: true,
        message: response.message,
        data: response.data,
      );
    }
    return ApiResponse(
      status: false,
      message: response.message ?? 'Failed to fetch profile',
    );
  }
}
