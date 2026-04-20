import 'package:equatable/equatable.dart';
import '../domain/user_model.dart';

class AuthState extends Equatable {
  final UserModel? user;
  final bool isAuthenticated;
  final bool isLoading;
  final bool isOtpSent;
  final String? email;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.isOtpSent = false,
    this.email,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState();

  AuthState copyWith({
    UserModel? user,
    bool? isAuthenticated,
    bool? isLoading,
    bool? isOtpSent,
    String? email,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      email: email ?? this.email,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        user,
        isAuthenticated,
        isLoading,
        isOtpSent,
        email,
        errorMessage,
      ];
}
