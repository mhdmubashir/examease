import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/network/api_response.dart';
import '../domain/auth_repository.dart';
import '../domain/user_model.dart';

class GoogleSignInUseCase {
  final AuthRepository repository;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  GoogleSignInUseCase(this.repository);

  Future<ApiResponse<UserModel>> call() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return ApiResponse(status: false, message: 'Google Sign-In cancelled');
      }

      final authentication = await googleUser.authentication;
      final idToken = authentication.idToken;

      if (idToken == null) {
        return ApiResponse(status: false, message: 'Failed to get ID Token from Google');
      }

      return await repository.signInWithGoogle(idToken);
    } catch (e) {
      return ApiResponse(status: false, message: 'Google Sign-In failed: ${e.toString()}');
    }
  }
}
