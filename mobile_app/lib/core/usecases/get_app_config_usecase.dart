import '../network/api_response.dart';
import '../repositories/app_config_repository.dart';
import '../models/app_config_model.dart';

class GetAppConfigUseCase {
  final AppConfigRepository repository;

  GetAppConfigUseCase(this.repository);

  Future<ApiResponse<AppConfigModel>> call() async {
    return await repository.getAppConfig();
  }
}

// Note: AppConfig doesn't have an Entity yet, keeping it simple as it's a global config.
