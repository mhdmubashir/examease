import '../../../core/services/main_service.dart';
import '../../../core/network/api_response.dart';
import '../domain/ad_model.dart';
import '../domain/ad_repository.dart';

class AdRepositoryImpl implements AdRepository {
  final MainService mainService;

  AdRepositoryImpl(this.mainService);

  @override
  Future<ApiResponse<List<AdModel>>> getActiveAds(String placement) async {
    return await mainService.get(
      '/ads/active/$placement',
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map((e) => AdModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }
}
