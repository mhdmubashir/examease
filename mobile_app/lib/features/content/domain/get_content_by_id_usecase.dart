import '../../../core/network/api_response.dart';
import 'content_model.dart';
import 'content_repository.dart';

class GetContentByIdUseCase {
  final ContentRepository repository;

  GetContentByIdUseCase(this.repository);

  Future<ApiResponse<ContentModel>> call(String contentId) async {
    final response = await repository.getContentById(contentId);
    if (response.status && response.data != null) {
      return ApiResponse(status: true, data: response.data);
    }
    return ApiResponse(status: false, message: response.message);
  }
}
