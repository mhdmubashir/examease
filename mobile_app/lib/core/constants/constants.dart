import '../../../app_config.dart';

class AppConstants {
  static const String appName = 'ExamEase';
  static String get apiBaseUrl => appConfig.apiUrl;

  // Storage Keys
  static const String accessTokenKey = 'accessToken';
  static const String refreshTokenKey = 'refreshToken';
  static const String userKey = 'userData';
  static const String configKey = 'appConfig';
}
