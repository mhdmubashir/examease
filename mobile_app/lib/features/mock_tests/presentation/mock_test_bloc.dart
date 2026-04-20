import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/mock_test_repository.dart';
import '../domain/get_questions_usecase.dart';
import 'mock_test_state.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class MockEvent {}

class ResetMockTestRequested extends MockEvent {}

class StartMockTestRequested extends MockEvent {
  final String contentId;
  final bool forceRestart;
  StartMockTestRequested(this.contentId, {this.forceRestart = false});
}

class ResumeMockTestRequested extends MockEvent {}

class ClearMockTestCacheRequested extends MockEvent {
  final String contentId;
  ClearMockTestCacheRequested(this.contentId);
}

class AnswerQuestionRequested extends MockEvent {
  final int questionIndex;
  final int answerIndex;
  AnswerQuestionRequested(this.questionIndex, this.answerIndex);
}

class SubmitMockTestRequested extends MockEvent {}

class MockTestTimerTicked extends MockEvent {
  final int remainingSeconds;
  MockTestTimerTicked(this.remainingSeconds);
}

class PreviousQuestionRequested extends MockEvent {}

class NextQuestionRequested extends MockEvent {}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class MockTestBloc extends Bloc<MockEvent, MockTestState> {
  final MockTestRepository repository;
  final GetQuestionsUseCase getQuestionsUseCase;
  Timer? _timer;

  MockTestBloc(this.repository, this.getQuestionsUseCase)
    : super(MockTestState.initial()) {
    // Reset to clean state
    on<ResetMockTestRequested>((event, emit) {
      _timer?.cancel();
      emit(MockTestState.initial());
    });

    // Start a new test or detect cached progress
    on<StartMockTestRequested>((event, emit) async {
      // Don't re-fetch if we're already in progress for this content
      if (state.status == MockTestStatus.inProgress &&
          state.contentId == event.contentId &&
          !event.forceRestart) {
        return;
      }

      emit(
        MockTestState.initial().copyWith(
          isLoading: true,
          contentId: event.contentId,
        ),
      );

      try {
        // Check for cached progress
        if (!event.forceRestart) {
          final prefs = await SharedPreferences.getInstance();
          final cacheKey = 'mock_test_cache_${event.contentId}';
          if (prefs.containsKey(cacheKey)) {
            emit(state.copyWith(isLoading: false, hasCache: true));
            return;
          }
        }

        // Clear any old cache on force restart
        if (event.forceRestart) {
          await _clearCacheForContent(event.contentId);
        }

        await _fetchAndStartTest(event.contentId, emit);
      } catch (e) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    // Resume from cached progress
    on<ResumeMockTestRequested>((event, emit) async {
      final contentId = state.contentId;
      if (contentId == null) return;

      emit(
        state.copyWith(isLoading: true, hasCache: false, errorMessage: null),
      );

      try {
        final prefs = await SharedPreferences.getInstance();
        final cacheKey = 'mock_test_cache_$contentId';
        final cacheData = prefs.getString(cacheKey);

        if (cacheData == null) {
          // Cache was cleared, start fresh
          await _fetchAndStartTest(contentId, emit);
          return;
        }

        final data = jsonDecode(cacheData) as Map<String, dynamic>;
        final questionsResponse = await getQuestionsUseCase(contentId);

        if (questionsResponse.status && questionsResponse.data != null) {
          final answersRaw = data['selectedAnswers'] as Map<String, dynamic>;
          final Map<int, int> selectedAnswers = {};
          answersRaw.forEach(
            (k, v) => selectedAnswers[int.parse(k)] = v as int,
          );

          final sessionResponse = await repository.startTestSession(contentId);

          emit(
            state.copyWith(
              isLoading: false,
              hasCache: false,
              status: MockTestStatus.inProgress,
              sessionId: sessionResponse.data,
              questions: questionsResponse.data!,
              total: questionsResponse.data!.length,
              selectedAnswers: selectedAnswers,
              currentQuestionIndex: data['currentQuestionIndex'] as int? ?? 0,
              remainingSeconds: data['remainingSeconds'] as int? ?? 3600,
            ),
          );
          _startTimer();
        } else {
          emit(
            state.copyWith(
              isLoading: false,
              errorMessage: questionsResponse.message,
            ),
          );
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    on<ClearMockTestCacheRequested>((event, emit) async {
      await _clearCacheForContent(event.contentId);
      emit(state.copyWith(hasCache: false));
    });

    on<MockTestTimerTicked>((event, emit) {
      if (event.remainingSeconds <= 0) {
        add(SubmitMockTestRequested());
        return;
      }
      emit(state.copyWith(remainingSeconds: event.remainingSeconds));
      if (event.remainingSeconds % 30 == 0) {
        _saveToCache();
      }
    });

    on<PreviousQuestionRequested>((event, emit) {
      if (state.currentQuestionIndex > 0) {
        emit(
          state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1),
        );
      }
    });

    on<NextQuestionRequested>((event, emit) {
      if (state.currentQuestionIndex < state.questions.length - 1) {
        emit(
          state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1),
        );
      }
    });

    on<AnswerQuestionRequested>((event, emit) {
      final newAnswers = Map<int, int>.from(state.selectedAnswers);
      newAnswers[event.questionIndex] = event.answerIndex;
      emit(state.copyWith(selectedAnswers: newAnswers));
      _saveToCache();
    });

    on<SubmitMockTestRequested>((event, emit) async {
      _timer?.cancel();

      emit(state.copyWith(isLoading: true));
      try {
        await _clearCacheForContent(state.contentId);

        // Submit to backend if we have a session
        if (state.sessionId != null) {
          final List<Map<String, dynamic>> answers = [];
          state.selectedAnswers.forEach((qIdx, sIdx) {
            if (qIdx < state.questions.length) {
              answers.add({
                'questionId': state.questions[qIdx].id,
                'selectedOptionIndex': sIdx,
                'timeTakenSeconds': 0,
              });
            }
          });
          try {
            await repository.submitTestSession(state.sessionId!, answers);
          } catch (_) {
            // Don't block completion on submission failure
          }
        }

        // Calculate local score
        int score = 0;
        for (int i = 0; i < state.questions.length; i++) {
          if (state.selectedAnswers[i] == state.questions[i].correctAnswer) {
            score++;
          }
        }

        emit(
          state.copyWith(
            isLoading: false,
            status: MockTestStatus.completed,
            score: score,
          ),
        );
      } catch (e) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });
  }

  // ── Private Helpers ─────────────────────────────────────────────────────────

  Future<void> _fetchAndStartTest(
    String contentId,
    Emitter<MockTestState> emit,
  ) async {
    final questionsResponse = await getQuestionsUseCase(contentId);
    if (questionsResponse.status && questionsResponse.data != null) {
      String? sessionId;
      try {
        final sessionResponse = await repository.startTestSession(contentId);
        sessionId = sessionResponse.data;
      } catch (_) {
        // Non-fatal: test can still proceed without server session
      }

      const initialTime = 3600;
      emit(
        state.copyWith(
          contentId: contentId,
          sessionId: sessionId,
          isLoading: false,
          status: MockTestStatus.inProgress,
          questions: questionsResponse.data!,
          total: questionsResponse.data!.length,
          remainingSeconds: initialTime,
          hasCache: false,
          selectedAnswers: {},
          currentQuestionIndex: 0,
          score: 0,
        ),
      );
      _startTimer();
      _saveToCache();
    } else {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: questionsResponse.message ?? 'Failed to load questions',
        ),
      );
    }
  }

  Future<void> _saveToCache() async {
    final contentId = state.contentId;
    if (contentId == null || state.status != MockTestStatus.inProgress) return;

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'mock_test_cache_$contentId';

    final data = {
      'selectedAnswers': state.selectedAnswers.map(
        (k, v) => MapEntry(k.toString(), v),
      ),
      'remainingSeconds': state.remainingSeconds,
      'currentQuestionIndex': state.currentQuestionIndex,
      'lastUpdated': DateTime.now().toIso8601String(),
    };

    await prefs.setString(cacheKey, jsonEncode(data));
  }

  Future<void> _clearCacheForContent(String? contentId) async {
    if (contentId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mock_test_cache_$contentId');
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isClosed && state.remainingSeconds > 0) {
        add(MockTestTimerTicked(state.remainingSeconds - 1));
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
