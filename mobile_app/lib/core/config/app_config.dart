import 'dart:io' show Platform;

class AppConfig {
  final String apiUrl;
  final String apiKey;
  final String clientAppSecretKey;
  final bool isProduction;

  AppConfig({
    required this.apiUrl,
    required this.apiKey,
    required this.clientAppSecretKey,
    this.isProduction = false,
  });

  static AppConfig dev() {
    String baseUrl = 'localhost';
    try {
      if (Platform.isAndroid) {
        baseUrl = '10.0.2.2'; // Android emulator alias to host loopback
      }
    } catch (_) {
      // Ignore for web
    }

    return AppConfig(
      apiUrl: 'http://$baseUrl:5001/api/v1',
      apiKey: 'dev_api_key',
      clientAppSecretKey: 'dev_secret_key',
      isProduction: false,
    );
  }

  static AppConfig prod() {
    return AppConfig(
      apiUrl: 'https://api.examease.com/v1',
      apiKey: 'prod_api_key',
      clientAppSecretKey: 'prod_secret_key',
      isProduction: true,
    );
  }
}
