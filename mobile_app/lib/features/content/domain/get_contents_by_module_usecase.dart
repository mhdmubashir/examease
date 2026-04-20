import '../../../core/network/api_response.dart';
import 'content_model.dart';
import 'content_repository.dart';

class GetContentsByModuleUseCase {
  final ContentRepository repository;

  GetContentsByModuleUseCase(this.repository);

  Future<ApiResponse<List<ContentModel>>> call(
    String moduleId, {
    PaginationModel? pagination,
  }) async {
    final response = await repository.getContentsByModule(
      moduleId,
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
