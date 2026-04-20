class ApiResponse<T> {
  final bool status;
  final T? data;
  final String? message;
  final String? title;
  final String? error;
  final PaginationModel? pagination;

  ApiResponse({
    required this.status,
    this.data,
    this.message,
    this.title,
    this.error,
    this.pagination,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) {
    final status = json['status'] as bool? ?? false;
    final message = json['message'] as String?;
    final title = json['title'] as String?;
    final error = json['error'] as String?;

    // The data field in the new structure can be either the payload directly
    // or a container object having both 'data' and pagination fields.
    Object? payload;
    PaginationModel? pagination;

    final rawData = json['data'];
    if (rawData is Map<String, dynamic> && rawData.containsKey('data')) {
      payload = rawData['data'];
      // Extract pagination from the same 'data' container
      pagination = PaginationModel.fromJson(rawData);
    } else {
      payload = rawData;
    }

    return ApiResponse<T>(
      status: status,
      data: payload != null ? fromJsonT(payload) : null,
      message: message,
      title: title,
      error: error,
      pagination: pagination,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return {
      'status': status,
      'data': data != null ? toJsonT(data as T) : null,
      'message': message,
      'title': title,
      'error': error,
    };
  }
}

class PaginationModel {
  final int page;
  final int perPage;
  final int pageSize; // maps to totalPages
  final int totalSize;
  final String? search;
  final List<Map<String, dynamic>>? filter;

  PaginationModel({
    required this.page,
    required this.perPage,
    required this.pageSize,
    required this.totalSize,
    this.search,
    this.filter,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'] as int? ?? 1,
      perPage: json['perPage'] as int? ?? (json['limit'] as int? ?? 10),
      pageSize: json['pageSize'] as int? ?? (json['totalPages'] as int? ?? 0),
      totalSize: json['totalSize'] as int? ?? (json['total'] as int? ?? 0),
      search: json['search'] as String?,
      filter: json['filter'] is List
          ? (json['filter'] as List)
                .map((e) => e as Map<String, dynamic>)
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'perPage': perPage,
      'pageSize': pageSize,
      'totalSize': totalSize,
      'search': search,
      'filter': filter,
    };
  }

  PaginationModel copyWith({
    int? page,
    int? perPage,
    int? pageSize,
    int? totalSize,
    String? search,
    List<Map<String, dynamic>>? filter,
  }) {
    return PaginationModel(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      pageSize: pageSize ?? this.pageSize,
      totalSize: totalSize ?? this.totalSize,
      search: search ?? this.search,
      filter: filter ?? this.filter,
    );
  }

  factory PaginationModel.empty() {
    return PaginationModel(page: 1, perPage: 10, pageSize: 0, totalSize: 0);
  }
}
