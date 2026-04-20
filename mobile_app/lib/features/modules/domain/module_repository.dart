import '../../../core/network/api_response.dart';
import '../domain/module_model.dart';

abstract class ModuleRepository {
  Future<ApiResponse<List<ModuleModel>>> getModulesByExam(
    String examId, {
    PaginationModel? pagination,
  });
}
