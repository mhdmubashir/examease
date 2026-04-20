import '../../../core/network/api_response.dart';
import '../domain/auth_repository.dart';
import '../domain/user_model.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<ApiResponse<UserModel>> call({
    required String email,
    required String otp,
  }) async {
    return await repository.verifyOtp(email, otp);
  }
}

class ResendOtpUseCase {
  final AuthRepository repository;

  ResendOtpUseCase(this.repository);

  Future<ApiResponse<void>> call(String email) async {
    return await repository.resendOtp(email);
  }
}
