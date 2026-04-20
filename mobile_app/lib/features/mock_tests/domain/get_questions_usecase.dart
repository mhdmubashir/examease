import '../../../core/network/api_response.dart';
import 'question_model.dart';
import 'mock_test_repository.dart';

class GetQuestionsUseCase {
  final MockTestRepository repository;

  GetQuestionsUseCase(this.repository);

  Future<ApiResponse<List<QuestionModel>>> call(String contentId) async {
    final response = await repository.getQuestionsByContent(contentId);
    if (response.status && response.data != null) {
      return ApiResponse(status: true, data: response.data);
    }
    return ApiResponse(status: false, message: response.message);
  }
}
