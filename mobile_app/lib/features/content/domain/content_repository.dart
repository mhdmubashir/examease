import '../../../core/services/main_service.dart';
import '../../../core/network/api_response.dart';
import '../domain/content_model.dart';

abstract class ContentRepository {
  Future<ApiResponse<List<ContentModel>>> getContentsByModule(
    String moduleId, {
    PaginationModel? pagination,
  });
  Future<ApiResponse<ContentModel>> getContentById(String contentId);

  /// Fetch an authenticated presigned URL for streaming an S3-hosted video.
  Future<ApiResponse<String>> getVideoStreamUrl(String contentId);
}

class ContentRepositoryImpl implements ContentRepository {
  final MainService mainService;
  ContentRepositoryImpl(this.mainService);

  @override
  Future<ApiResponse<List<ContentModel>>> getContentsByModule(
    String moduleId, {
    PaginationModel? pagination,
  }) async {
    final Map<String, dynamic> query = {'moduleId': moduleId};

    if (pagination != null) {
      query['page'] = pagination.page;
      query['limit'] = pagination.perPage;
      if (pagination.search != null && pagination.search!.isNotEmpty) {
        query['search'] = pagination.search;
      }
      if (pagination.filter != null) {
        for (var f in pagination.filter!) {
          query.addAll(f);
        }
      }
    }

    return await mainService.get<List<ContentModel>>(
      '/contents/all',
      queryParameters: query,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map((e) => ContentModel.fromBackend(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  @override
  Future<ApiResponse<ContentModel>> getContentById(String contentId) async {
    return await mainService.get<ContentModel>(
      '/contents/$contentId',
      fromJsonT: (json) =>
          ContentModel.fromBackend(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<String>> getVideoStreamUrl(String contentId) async {
    return await mainService.get<String>(
      '/videos/stream/$contentId',
      fromJsonT: (json) {
        final data = json as Map<String, dynamic>;
        return data['streamUrl'] as String? ?? '';
      },
    );
  }
}
