import '../domain/exam_repository.dart';
import '../domain/exam_model.dart';
import '../../../core/network/api_response.dart';

class GetExamsUseCase {
  final ExamRepository repository;

  GetExamsUseCase(this.repository);

  Future<ApiResponse<List<ExamModel>>> call() async {
    final response = await repository.getExams();
    if (response.status && response.data != null) {
      return ApiResponse(
        status: true,
        message: response.message,
        data: response.data,
      );
    }
    return ApiResponse(status: false, message: response.message);
  }
}
