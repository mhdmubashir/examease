import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  RegisterRequested(this.name, this.email, this.phone, this.password);
  @override
  List<Object?> get props => [name, email, phone, password];
}

class VerifyOtpRequested extends AuthEvent {
  final String email;
  final String otp;
  VerifyOtpRequested(this.email, this.otp);
  @override
  List<Object?> get props => [email, otp];
}

class ResendOtpRequested extends AuthEvent {
  final String email;
  ResendOtpRequested(this.email);
  @override
  List<Object?> get props => [email];
}

class GoogleSignInRequested extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}
