import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/auth_repository.dart';
import '../domain/login_usecase.dart';
import '../domain/get_profile_usecase.dart';
import '../domain/register_usecase.dart';
import '../domain/verify_otp_usecase.dart';
import '../domain/google_sign_in_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  final LoginUseCase loginUseCase;
  final GetProfileUseCase getProfileUseCase;
  final RegisterUseCase registerUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final ResendOtpUseCase resendOtpUseCase;
  final GoogleSignInUseCase googleSignInUseCase;

  AuthBloc({
    required this.repository,
    required this.loginUseCase,
    required this.getProfileUseCase,
    required this.registerUseCase,
    required this.verifyOtpUseCase,
    required this.resendOtpUseCase,
    required this.googleSignInUseCase,
  }) : super(AuthState.initial()) {
    on<AuthCheckRequested>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final authenticated = await repository.isAuthenticated();
        if (authenticated) {
          final response = await getProfileUseCase();
          if (response.status && response.data != null) {
            emit(
              state.copyWith(
                isLoading: false,
                isAuthenticated: true,
                user: response.data,
              ),
            );
          } else {
            await repository.logout();
            emit(state.copyWith(isLoading: false, isAuthenticated: false));
          }
        } else {
          emit(state.copyWith(isLoading: false, isAuthenticated: false));
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false, isAuthenticated: false));
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      try {
        final response = await loginUseCase(
          email: event.email,
          password: event.password,
        );
        if (response.status && response.data != null) {
          emit(
            state.copyWith(
              isLoading: false,
              isAuthenticated: true,
              user: response.data,
            ),
          );
        } else {
          emit(
            state.copyWith(isLoading: false, errorMessage: response.message),
          );
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      try {
        final response = await registerUseCase(
          name: event.name,
          email: event.email,
          phone: event.phone,
          password: event.password,
        );
        if (response.status) {
          emit(
            state.copyWith(
              isLoading: false,
              isOtpSent: true,
              email: event.email,
            ),
          );
        } else {
          emit(
            state.copyWith(isLoading: false, errorMessage: response.message),
          );
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    on<VerifyOtpRequested>((event, emit) async {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      try {
        final response = await verifyOtpUseCase(
          email: event.email,
          otp: event.otp,
        );
        if (response.status && response.data != null) {
          emit(
            state.copyWith(
              isLoading: false,
              isAuthenticated: true,
              isOtpSent: false,
              user: response.data,
            ),
          );
        } else {
          emit(
            state.copyWith(isLoading: false, errorMessage: response.message),
          );
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    on<ResendOtpRequested>((event, emit) async {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      try {
        final response = await resendOtpUseCase(event.email);
        if (response.status) {
          emit(state.copyWith(isLoading: false, isOtpSent: true));
        } else {
          emit(
            state.copyWith(isLoading: false, errorMessage: response.message),
          );
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    on<GoogleSignInRequested>((event, emit) async {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      try {
        final response = await googleSignInUseCase();
        if (response.status && response.data != null) {
          emit(
            state.copyWith(
              isLoading: false,
              isAuthenticated: true,
              user: response.data,
            ),
          );
        } else {
          emit(
            state.copyWith(isLoading: false, errorMessage: response.message),
          );
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await repository.logout();
      emit(AuthState.initial());
    });
  }
}

