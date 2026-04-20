import '../../../core/network/api_response.dart';
import 'module_model.dart';
import 'module_repository.dart';

class GetModulesByExamUseCase {
  final ModuleRepository repository;

  GetModulesByExamUseCase(this.repository);

  Future<ApiResponse<List<ModuleModel>>> call(
    String examId, {
    PaginationModel? pagination,
  }) async {
    final response = await repository.getModulesByExam(
      examId,
      pagination: pagination,
    );
    if (response.status && response.data != null) {
      return ApiResponse(
        status: true,
        data: response.data,
        pagination: response.pagination,
      );
    }
    return ApiResponse(status: false, message: response.message);
  }
}
