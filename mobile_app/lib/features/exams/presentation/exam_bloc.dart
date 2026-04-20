import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/exam_repository.dart';
import '../domain/get_exams_usecase.dart';
import 'exam_event.dart';
import 'exam_state.dart';

export 'exam_event.dart';
export 'exam_state.dart';

class ExamBloc extends Bloc<ExamEvent, ExamState> {
  final ExamRepository repository;
  final GetExamsUseCase getExamsUseCase;

  ExamBloc(this.repository, this.getExamsUseCase) : super(ExamState.initial()) {
    on<GetExamsRequested>((event, emit) async {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      try {
        final response = await getExamsUseCase();
        if (response.status && response.data != null) {
          emit(state.copyWith(isLoading: false, exams: response.data!));
        } else {
          emit(
            state.copyWith(isLoading: false, errorMessage: response.message),
          );
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    on<ExamSelected>((event, emit) {
      emit(state.copyWith(selectedExam: event.exam));
    });
  }
}
