import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_response.dart';
import '../domain/content_model.dart';
import '../domain/get_contents_by_module_usecase.dart';
import '../domain/get_content_by_id_usecase.dart';
import 'content_state.dart';

abstract class ContentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchContentsRequested extends ContentEvent {
  final String moduleId;
  final PaginationModel? pagination;
  FetchContentsRequested(this.moduleId, {this.pagination});
  @override
  List<Object?> get props => [moduleId, pagination];
}

class SelectContentRequested extends ContentEvent {
  final ContentModel content;
  SelectContentRequested(this.content);

  @override
  List<Object?> get props => [content];
}

/// Reset the content state to initial (clears stale data immediately).
class ResetContentRequested extends ContentEvent {}

class ContentBloc extends Bloc<ContentEvent, ContentState> {
  final GetContentsByModuleUseCase getContentsByModuleUseCase;
  final GetContentByIdUseCase getContentByIdUseCase;

  ContentBloc(this.getContentsByModuleUseCase, this.getContentByIdUseCase)
    : super(ContentState.initial()) {
    on<FetchContentsRequested>((event, emit) async {
      // Clear old contents immediately to avoid stale data flash on tab switch
      emit(state.copyWith(
        isLoading: true,
        errorMessage: null,
        clearContents: true,
        pagination: null,
      ));
      try {
        final response = await getContentsByModuleUseCase(
          event.moduleId,
          pagination: event.pagination,
        );
        if (response.status && response.data != null) {
          emit(
            state.copyWith(
              isLoading: false,
              contents: response.data!,
              pagination: response.pagination,
            ),
          );
        } else {
          emit(
            state.copyWith(isLoading: false, errorMessage: response.message),
          );
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    on<SelectContentRequested>((event, emit) {
      emit(state.copyWith(selectedContent: event.content));
    });

    on<ResetContentRequested>((event, emit) {
      emit(ContentState.initial());
    });
  }
}
