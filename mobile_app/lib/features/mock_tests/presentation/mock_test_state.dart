import 'package:equatable/equatable.dart';
import '../domain/question_model.dart';

enum MockTestStatus { idle, inProgress, completed }

class MockTestState extends Equatable {
  final String? contentId;
  final String? sessionId;
  final List<QuestionModel> questions;
  final int currentQuestionIndex;
  final Map<int, int> selectedAnswers;
  final int score;
  final int total;
  final int remainingSeconds;
  final bool hasCache;
  final bool isLoading;
  final String? errorMessage;
  final MockTestStatus status;

  const MockTestState({
    this.contentId,
    this.sessionId,
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.selectedAnswers = const {},
    this.score = 0,
    this.total = 0,
    this.remainingSeconds = 3600,
    this.hasCache = false,
    this.isLoading = false,
    this.errorMessage,
    this.status = MockTestStatus.idle,
  });

  factory MockTestState.initial() => const MockTestState();

  MockTestState copyWith({
    String? contentId,
    String? sessionId,
    List<QuestionModel>? questions,
    int? currentQuestionIndex,
    Map<int, int>? selectedAnswers,
    int? score,
    int? total,
    int? remainingSeconds,
    bool? hasCache,
    bool? isLoading,
    String? errorMessage,
    MockTestStatus? status,
  }) {
    return MockTestState(
      contentId: contentId ?? this.contentId,
      sessionId: sessionId ?? this.sessionId,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      score: score ?? this.score,
      total: total ?? this.total,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      hasCache: hasCache ?? this.hasCache,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    contentId,
    sessionId,
    questions,
    currentQuestionIndex,
    selectedAnswers,
    score,
    total,
    remainingSeconds,
    hasCache,
    isLoading,
    errorMessage,
    status,
  ];
}
