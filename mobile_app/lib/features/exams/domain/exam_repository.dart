import '../../../core/network/api_response.dart';
import '../domain/exam_model.dart';

abstract class ExamRepository {
  Future<ApiResponse<List<ExamModel>>> getExams();
}
