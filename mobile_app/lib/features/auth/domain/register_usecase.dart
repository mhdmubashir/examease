import '../../../core/network/api_response.dart';
import '../domain/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<ApiResponse<void>> call({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    return await repository.register(name, email, phone, password);
  }
}
