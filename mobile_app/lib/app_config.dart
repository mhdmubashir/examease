import 'dart:io' show Platform;

class AppConfig {
  // Toggle this for development/production builds
  final bool isProduction = false;

  static String get _apiBaseURLDev {
    try {
      if (Platform.isAndroid) {
        // return "http://10.0.2.2:5050/api/v1";
        return "https://api.examease.in/api/v1";
      }
    } catch (_) {}
    // return "http://localhost:5050/api/v1";
    return "https://api.examease.in/api/v1";
  }

  final String _apiBaseURLProd = "https://api.examease.com/v1";

  final String appDevAppSecretKey = "dev_sec";
  final String appSecretKey = "prod_sec";

  final String appDevApiKey = "dev_api_key";
  final String apiKeyProd = "prod_api_key";

  final String appVersion = "1.0.0";
  final String apiVersion = "v1";

  String get apiUrl => isProduction ? _apiBaseURLProd : _apiBaseURLDev;

  String get apiKey => isProduction ? apiKeyProd : appDevApiKey;

  String get clientAppSecretKey =>
      isProduction ? appSecretKey : appDevAppSecretKey;
}

// Singleton instance to be used across the app
final appConfig = AppConfig();
