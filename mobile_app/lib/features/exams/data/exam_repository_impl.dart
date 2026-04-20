import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_response.dart';
import '../../../core/services/main_service.dart';
import '../domain/exam_model.dart';
import '../domain/exam_repository.dart';

class ExamRepositoryImpl implements ExamRepository {
  final MainService mainService;

  ExamRepositoryImpl(this.mainService);

  @override
  Future<ApiResponse<List<ExamModel>>> getExams() async {
    return await mainService.get<List<ExamModel>>(
      ApiEndpoints.exams,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map((e) => ExamModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }
}
