import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_response.dart';
import '../domain/module_model.dart';
import '../domain/get_modules_by_exam_usecase.dart';
import 'module_state.dart';

abstract class ModuleEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchModulesRequested extends ModuleEvent {
  final String examId;
  final PaginationModel? pagination;
  FetchModulesRequested(this.examId, {this.pagination});
  @override
  List<Object?> get props => [examId, pagination];
}

class SelectModuleRequested extends ModuleEvent {
  final ModuleModel module;
  SelectModuleRequested(this.module);

  @override
  List<Object?> get props => [module];
}

/// Reset the module state to initial (clears stale data immediately).
class ResetModuleRequested extends ModuleEvent {}

class ModuleBloc extends Bloc<ModuleEvent, ModuleState> {
  final GetModulesByExamUseCase getModulesByExamUseCase;

  ModuleBloc(this.getModulesByExamUseCase) : super(ModuleState.initial()) {
    on<FetchModulesRequested>((event, emit) async {
      // Clear old modules immediately to prevent stale data flash on re-entry
      emit(state.copyWith(
        isLoading: true,
        errorMessage: null,
        clearModules: true,
        pagination: null,
      ));
      try {
        final response = await getModulesByExamUseCase(
          event.examId,
          pagination: event.pagination,
        );
        if (response.status && response.data != null) {
          emit(
            state.copyWith(
              isLoading: false,
              modules: response.data!,
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

    on<SelectModuleRequested>((event, emit) {
      emit(state.copyWith(selectedModule: event.module));
    });

    on<ResetModuleRequested>((event, emit) {
      emit(ModuleState.initial());
    });
  }
}
