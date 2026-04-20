import 'package:equatable/equatable.dart';
import '../domain/exam_model.dart';

abstract class ExamEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetExamsRequested extends ExamEvent {}

class ExamSelected extends ExamEvent {
  final ExamModel exam;
  ExamSelected(this.exam);

  @override
  List<Object?> get props => [exam];
}
