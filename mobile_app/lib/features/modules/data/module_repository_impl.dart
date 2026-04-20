import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/main_service.dart';
import '../../../core/network/api_response.dart';
import '../domain/module_model.dart';
import '../domain/module_repository.dart';

class ModuleRepositoryImpl implements ModuleRepository {
  final MainService mainService;

  ModuleRepositoryImpl(this.mainService);

  @override
  Future<ApiResponse<List<ModuleModel>>> getModulesByExam(
    String examId, {
    PaginationModel? pagination,
  }) async {
    final Map<String, dynamic> query = {'examId': examId};
    if (pagination != null) {
      query['page'] = pagination.page;
      query['limit'] = pagination.perPage;
      if (pagination.search != null && pagination.search!.isNotEmpty) {
        query['search'] = pagination.search;
      }
      if (pagination.filter != null) {
        for (var f in pagination.filter!) {
          query.addAll(f);
        }
      }
    }

    return await mainService.get<List<ModuleModel>>(
      ApiEndpoints.allModules,
      queryParameters: query,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map((e) => ModuleModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }
}
