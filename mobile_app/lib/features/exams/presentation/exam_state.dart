import 'package:equatable/equatable.dart';
import '../domain/exam_model.dart';

class ExamState extends Equatable {
  final List<ExamModel> exams;
  final ExamModel? selectedExam;
  final bool isLoading;
  final String? errorMessage;

  const ExamState({
    this.exams = const [],
    this.selectedExam,
    this.isLoading = false,
    this.errorMessage,
  });

  factory ExamState.initial() => const ExamState();

  ExamState copyWith({
    List<ExamModel>? exams,
    ExamModel? selectedExam,
    bool? isLoading,
    Object? errorMessage = _sentinel,
  }) {
    return ExamState(
      exams: exams ?? this.exams,
      selectedExam: selectedExam ?? this.selectedExam,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const _sentinel = Object();

  @override
  List<Object?> get props => [exams, selectedExam, isLoading, errorMessage];
}
