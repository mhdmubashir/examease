import '../../../core/network/api_response.dart';
import 'user_model.dart';

abstract class AuthRepository {
  Future<ApiResponse<UserModel>> login(String email, String password);
  Future<ApiResponse<void>> register(
    String name,
    String email,
    String phone,
    String password,
  );
  Future<ApiResponse<UserModel>> verifyOtp(String email, String otp);
  Future<ApiResponse<void>> resendOtp(String email);
  Future<ApiResponse<UserModel>> signInWithGoogle(String idToken);
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<ApiResponse<UserModel>> getProfile();
}

class RequiresOtpException implements Exception {
  final String email;
  RequiresOtpException(this.email);

  @override
  String toString() => 'OTP Required for $email';
}
