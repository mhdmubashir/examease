import '../../../core/services/main_service.dart';
import '../../../core/network/api_response.dart';
import '../domain/question_model.dart';

abstract class MockTestRepository {
  Future<ApiResponse<List<QuestionModel>>> getQuestionsByContent(
    String contentId,
  );
  Future<ApiResponse<String>> startTestSession(String mockTestId);
  Future<ApiResponse<void>> submitTestSession(
    String sessionId,
    List<Map<String, dynamic>> answers,
  );
}

class MockTestRepositoryImpl implements MockTestRepository {
  final MainService mainService;
  MockTestRepositoryImpl(this.mainService);

  @override
  Future<ApiResponse<List<QuestionModel>>> getQuestionsByContent(
    String contentId,
  ) async {
    return await mainService.get<List<QuestionModel>>(
      '/questions/test/$contentId',
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map((e) => QuestionModel.fromBackend(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  @override
  Future<ApiResponse<String>> startTestSession(String mockTestId) async {
    return await mainService.post<String>(
      '/test-sessions/start',
      data: {'mockTestId': mockTestId},
      fromJsonT: (json) {
        // payload is now the session object: { _id, ... }
        return (json as Map<String, dynamic>)['_id'] as String;
      },
    );
  }

  @override
  Future<ApiResponse<void>> submitTestSession(
    String sessionId,
    List<Map<String, dynamic>> answers,
  ) async {
    return await mainService.post<void>(
      '/test-sessions/$sessionId/submit',
      data: {'answers': answers},
      fromJsonT: (json) {},
    );
  }
}
