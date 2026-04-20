import 'package:get_it/get_it.dart';
import 'api_client.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/domain/login_usecase.dart';
import '../../features/auth/domain/get_profile_usecase.dart';
import '../../features/auth/domain/register_usecase.dart';
import '../../features/auth/domain/verify_otp_usecase.dart';
import '../../features/auth/domain/google_sign_in_usecase.dart';
import '../../features/auth/presentation/auth_bloc.dart';
import '../../features/exams/domain/exam_repository.dart';
import '../../features/exams/domain/get_exams_usecase.dart';
import '../usecases/get_app_config_usecase.dart';
import '../../features/exams/data/exam_repository_impl.dart';
import '../../features/exams/presentation/exam_bloc.dart';
import '../../features/modules/domain/module_repository.dart';
import '../../features/modules/domain/get_modules_by_exam_usecase.dart';
import '../../features/modules/data/module_repository_impl.dart';
import '../../features/modules/presentation/module_bloc.dart';
import '../../features/content/domain/content_repository.dart';
import '../../features/content/domain/get_contents_by_module_usecase.dart';
import '../../features/content/domain/get_content_by_id_usecase.dart';
import '../../features/content/presentation/content_bloc.dart';
import '../../features/mock_tests/domain/mock_test_repository.dart';
import '../../features/mock_tests/domain/get_questions_usecase.dart';
import '../../features/mock_tests/presentation/mock_test_bloc.dart';
import '../config/app_config.dart';
import '../services/main_service.dart';
import '../repositories/app_config_repository.dart';
import '../blocs/app_config_bloc.dart';
import '../blocs/network_bloc.dart';
import '../../features/payments/domain/payment_repository.dart';
import '../../features/payments/data/payment_repository_impl.dart';
import '../../features/payments/presentation/payment_bloc.dart';
import '../../features/payments/domain/create_order_usecase.dart';
import '../../features/payments/domain/verify_payment_usecase.dart';
import '../../features/ads/domain/ad_repository.dart';
import '../../features/ads/data/ad_repository_impl.dart';
import '../../features/ads/presentation/ad_bloc.dart';
import '../../features/ads/domain/get_ads_usecase.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Config
  final config = AppConfig.dev();
  sl.registerLazySingleton(() => config);

  // Core
  sl.registerLazySingleton(() => ApiClient());
  sl.registerLazySingleton(
    () =>
        MainService(apiClient: sl<ApiClient>(), apiKey: sl<AppConfig>().apiKey),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  sl.registerLazySingleton<AppConfigRepository>(
    () => AppConfigRepositoryImpl(sl<MainService>()),
  );

  sl.registerLazySingleton<ExamRepository>(() => ExamRepositoryImpl(sl()));

  sl.registerLazySingleton<ModuleRepository>(
    () => ModuleRepositoryImpl(sl<MainService>()),
  );

  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(sl<MainService>()),
  );

  sl.registerLazySingleton<AdRepository>(
    () => AdRepositoryImpl(sl<MainService>()),
  );

  sl.registerLazySingleton<ContentRepository>(
    () => ContentRepositoryImpl(sl<MainService>()),
  );

  sl.registerLazySingleton<MockTestRepository>(
    () => MockTestRepositoryImpl(sl<MainService>()),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));
  sl.registerLazySingleton(() => ResendOtpUseCase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));
  sl.registerLazySingleton(() => GetExamsUseCase(sl()));
  sl.registerLazySingleton(() => GetAppConfigUseCase(sl()));
  sl.registerLazySingleton(() => GetQuestionsUseCase(sl()));
  sl.registerLazySingleton(() => GetModulesByExamUseCase(sl()));
  sl.registerLazySingleton(() => GetContentsByModuleUseCase(sl()));
  sl.registerLazySingleton(() => GetContentByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetAdsUseCase(sl()));
  sl.registerLazySingleton(() => CreateOrderUseCase(sl()));
  sl.registerLazySingleton(() => VerifyPaymentUseCase(sl()));

  // Blocs
  sl.registerFactory(
    () => AuthBloc(
      repository: sl(),
      loginUseCase: sl(),
      getProfileUseCase: sl(),
      registerUseCase: sl(),
      verifyOtpUseCase: sl(),
      resendOtpUseCase: sl(),
      googleSignInUseCase: sl(),
    ),
  );
  sl.registerFactory(() => AppConfigBloc(sl<AppConfigRepository>()));
  sl.registerFactory(() => NetworkBloc());
  sl.registerFactory(() => ExamBloc(sl(), sl()));
  sl.registerFactory(() => ModuleBloc(sl()));
  sl.registerFactory(() => PaymentBloc(sl(), sl()));
  sl.registerFactory(() => AdBloc(sl()));
  sl.registerFactory(() => ContentBloc(sl(), sl()));
  sl.registerFactory(() => MockTestBloc(sl(), sl()));
}
