import '../../../core/network/api_response.dart';
import 'ad_model.dart';
import 'ad_repository.dart';

class GetAdsUseCase {
  final AdRepository repository;

  GetAdsUseCase(this.repository);

  Future<ApiResponse<List<AdModel>>> call(String placement) async {
    final response = await repository.getActiveAds(placement);
    if (response.status && response.data != null) {
      return ApiResponse(status: true, data: response.data);
    }
    return ApiResponse(status: false, message: response.message);
  }
}
