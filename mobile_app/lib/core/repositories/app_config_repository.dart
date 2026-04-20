import '../services/main_service.dart';
import '../models/app_config_model.dart';
import '../network/api_response.dart';

abstract class AppConfigRepository {
  Future<ApiResponse<AppConfigModel>> getAppConfig();
}

class AppConfigRepositoryImpl implements AppConfigRepository {
  final MainService mainService;

  AppConfigRepositoryImpl(this.mainService);

  @override
  Future<ApiResponse<AppConfigModel>> getAppConfig() async {
    return await mainService.get(
      '/app-config',
      fromJsonT: (json) =>
          AppConfigModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
