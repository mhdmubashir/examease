import '../domain/content_model.dart';
import '../../../core/network/api_response.dart';
import 'package:equatable/equatable.dart';

class ContentState extends Equatable {
  final List<ContentModel> contents;
  final ContentModel? selectedContent;
  final bool isLoading;
  final String? errorMessage;
  final PaginationModel? pagination;

  const ContentState({
    this.contents = const [],
    this.selectedContent,
    this.isLoading = false,
    this.errorMessage,
    this.pagination,
  });

  factory ContentState.initial() => const ContentState();

  /// Uses a sentinel pattern so nullable fields can be explicitly set to null.
  ContentState copyWith({
    List<ContentModel>? contents,
    ContentModel? selectedContent,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    Object? pagination = _sentinel,
    bool clearContents = false,
  }) {
    return ContentState(
      contents: clearContents ? const [] : (contents ?? this.contents),
      selectedContent: selectedContent ?? this.selectedContent,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      pagination: identical(pagination, _sentinel)
          ? this.pagination
          : pagination as PaginationModel?,
    );
  }

  static const _sentinel = Object();

  @override
  List<Object?> get props => [
    contents,
    selectedContent,
    isLoading,
    errorMessage,
    pagination,
  ];
}
