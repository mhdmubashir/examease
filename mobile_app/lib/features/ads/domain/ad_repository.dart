import '../../../core/network/api_response.dart';
import '../domain/ad_model.dart';

abstract class AdRepository {
  Future<ApiResponse<List<AdModel>>> getActiveAds(String placement);
}
