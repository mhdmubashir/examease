import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'mock_test_bloc.dart';
import 'mock_test_state.dart';
import '../../../core/widgets/helper/responsive.dart';
import '../../../core/widgets/custom_text_button.dart';

class MockTestScreen extends StatefulWidget {
  final String contentId;
  final String contentTitle;

  const MockTestScreen({
    super.key,
    required this.contentId,
    required this.contentTitle,
  });

  @override
  State<MockTestScreen> createState() => _MockTestScreenState();
}

class _MockTestScreenState extends State<MockTestScreen> {
  bool _resumeDialogShown = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<MockTestBloc>();
    bloc.add(ResetMockTestRequested());
    Future.microtask(() {
      if (mounted) {
        bloc.add(StartMockTestRequested(widget.contentId));
      }
    });
  }

  @override
  void dispose() {
    _resumeDialogShown = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MockTestBloc, MockTestState>(
      listenWhen: (prev, curr) => prev.hasCache != curr.hasCache,
      listener: (context, state) {
        if (state.hasCache && !_resumeDialogShown) {
          _resumeDialogShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showResumeDialog(context);
          });
        }
      },
      child: BlocBuilder<MockTestBloc, MockTestState>(
        builder: (context, state) {
          if (state.isLoading) {
            return _buildLoadingView();
          }
          if (state.errorMessage != null) {
            return _buildErrorView(state.errorMessage!);
          }
          if (state.hasCache) {
            return _buildLoadingView(message: 'Checking for saved progress...');
          }
          if (state.status == MockTestStatus.completed) {
            return _buildResultsView(state);
          }
          if (state.status == MockTestStatus.inProgress &&
              state.questions.isNotEmpty) {
            return _buildQuestionView(state);
          }
          return _buildLoadingView(message: 'Preparing test...');
        },
      ),
    );
  }

  // ── Loading ─────────────────────────────────────────────────────────────────
  Widget _buildLoadingView({String message = 'Loading questions...'}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: Responsive.s(16)),
          Text(
            message,
            style: TextStyle(color: Colors.grey, fontSize: Responsive.s(14)),
          ),
        ],
      ),
    );
  }

  // ── Error ───────────────────────────────────────────────────────────────────
  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.s(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: Responsive.s(64),
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.read<MockTestBloc>().add(
                  StartMockTestRequested(widget.contentId, forceRestart: true),
                );
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Results ─────────────────────────────────────────────────────────────────
  Widget _buildResultsView(MockTestState state) {
    final percentage = state.total > 0
        ? (state.score / state.total * 100)
        : 0.0;
    final color = percentage >= 70
        ? Colors.green
        : percentage >= 40
        ? Colors.orange
        : Colors.red;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Trophy / Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
              border: Border.all(color: color, width: 2.5),
            ),
            child: Icon(
              percentage >= 70
                  ? Icons.emoji_events_rounded
                  : Icons.check_circle_outline_rounded,
              size: 48,
              color: color,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            percentage >= 70
                ? 'Excellent!'
                : percentage >= 40
                ? 'Good Effort!'
                : 'Keep Practicing!',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Test Completed',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 28),

          // Score Card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(Responsive.s(14)),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  _StatItem(
                    label: 'Score',
                    value: '${percentage.toStringAsFixed(1)}%',
                    color: color,
                  ),
                  SizedBox(height: Responsive.s(16)),
                  Row(
                    children: [
                      Expanded(
                        child: _StatItem(
                          label: 'Correct',
                          value: state.score.toString(),
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(width: Responsive.s(16)),
                      Expanded(
                        child: _StatItem(
                          label: 'Wrong',
                          value: (state.total - state.score).toString(),
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: Responsive.s(32)),

          // Action Buttons
          CustomTextButton(
            text: 'Retake Test',
            icon: Icons.refresh,
            onPressed: () {
              _resumeDialogShown = false;
              context.read<MockTestBloc>().add(ResetMockTestRequested());
              Future.microtask(() {
                if (mounted) {
                  context.read<MockTestBloc>().add(
                    StartMockTestRequested(widget.contentId),
                  );
                }
              });
            },
            buttonColor: Colors.blue,
            height: Responsive.s(50),
          ),
          SizedBox(height: Responsive.s(16)),
          CustomTextButton(
            text: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            buttonColor: Colors.transparent,
            textStyle: TextStyle(
              color: Colors.blue,
              fontSize: Responsive.s(16),
              fontWeight: FontWeight.w700,
            ),
            height: Responsive.s(50),
          ),
        ],
      ),
    );
  }

  // ── Question View ───────────────────────────────────────────────────────────
  Widget _buildQuestionView(MockTestState state) {
    final question = state.questions[state.currentQuestionIndex];
    final isLast = state.currentQuestionIndex >= state.questions.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.contentTitle,
          style: TextStyle(fontSize: Responsive.s(18)),
        ),
        actions: [
          _TimerChip(seconds: state.remainingSeconds),
          SizedBox(width: Responsive.s(8)),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.s(16),
              vertical: Responsive.s(12),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(color: Colors.grey.withAlpha(25)),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${state.currentQuestionIndex + 1}/${state.questions.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.s(14),
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${((state.currentQuestionIndex + 1) / state.questions.length * 100).toInt()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.s(14),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.s(8)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(Responsive.s(4)),
                  child: LinearProgressIndicator(
                    value:
                        (state.currentQuestionIndex + 1) /
                        state.questions.length,
                    minHeight: Responsive.s(8),
                    backgroundColor: Colors.grey[200],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Question + Options
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(Responsive.s(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: Responsive.s(4)),
                  Text(
                    question.text,
                    style: TextStyle(
                      fontSize: Responsive.s(17),
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: Responsive.s(24)),
                  ...List.generate(question.options.length, (i) {
                    final selected =
                        state.selectedAnswers[state.currentQuestionIndex] == i;
                    return _OptionTile(
                      index: i,
                      text: question.options[i],
                      isSelected: selected,
                      onTap: () {
                        context.read<MockTestBloc>().add(
                          AnswerQuestionRequested(
                            state.currentQuestionIndex,
                            i,
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),

          // Bottom Nav
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.s(20),
              vertical: Responsive.s(12),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (state.currentQuestionIndex > 0)
                    Expanded(
                      child: CustomTextButton(
                        text: 'Previous',
                        onPressed: () => context.read<MockTestBloc>().add(
                          PreviousQuestionRequested(),
                        ),
                        buttonColor: Colors.transparent,
                        textStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: Responsive.s(15),
                          fontWeight: FontWeight.w700,
                        ),
                        height: Responsive.s(48),
                      ),
                    )
                  else
                    const Expanded(child: SizedBox()),
                  SizedBox(width: Responsive.s(12)),
                  Expanded(
                    child: CustomTextButton(
                      text: isLast ? 'Submit' : 'Next',
                      onPressed: () {
                        if (!isLast) {
                          context.read<MockTestBloc>().add(
                            NextQuestionRequested(),
                          );
                        } else {
                          _showSubmitConfirmation(context, state);
                        }
                      },
                      buttonColor: isLast ? Colors.green : Colors.blue,
                      height: Responsive.s(48),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dialogs ─────────────────────────────────────────────────────────────────
  void _showSubmitConfirmation(BuildContext context, MockTestState state) {
    final unanswered = state.total - state.selectedAnswers.length;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Test?'),
        content: Text(
          unanswered > 0
              ? 'You have $unanswered unanswered question(s). Submit anyway?'
              : 'Are you sure you want to submit?',
        ),
        actions: [
          CustomTextButton(
            text: 'Cancel',
            onPressed: () => Navigator.of(ctx).pop(),
            buttonColor: Colors.transparent,
            textStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: Responsive.s(14),
              fontWeight: FontWeight.w600,
            ),
            width: Responsive.s(100),
          ),
          CustomTextButton(
            text: 'Submit',
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<MockTestBloc>().add(SubmitMockTestRequested());
            },
            buttonColor: Colors.green,
            width: Responsive.s(100),
          ),
        ],
      ),
    );
  }

  void _showResumeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Resume Test?'),
        content: const Text('Saved progress found. Resume where you left off?'),
        actions: [
          CustomTextButton(
            text: 'Start Fresh',
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<MockTestBloc>().add(
                StartMockTestRequested(widget.contentId, forceRestart: true),
              );
            },
            buttonColor: Colors.transparent,
            textStyle: TextStyle(
              color: Colors.red,
              fontSize: Responsive.s(14),
              fontWeight: FontWeight.w600,
            ),
            width: Responsive.s(120),
          ),
          CustomTextButton(
            text: 'Resume',
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<MockTestBloc>().add(ResumeMockTestRequested());
            },
            buttonColor: Colors.blue,
            width: Responsive.s(120),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Widgets ──────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: Responsive.s(20),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: Responsive.s(4)),
        Text(
          label,
          style: TextStyle(fontSize: Responsive.s(11), color: Colors.grey[500]),
        ),
      ],
    );
  }
}

class _TimerChip extends StatelessWidget {
  final int seconds;
  const _TimerChip({required this.seconds});

  @override
  Widget build(BuildContext context) {
    final isLow = seconds < 300;
    final color = isLow ? Colors.red : Colors.blue;
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.s(10),
        vertical: Responsive.s(4),
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(Responsive.s(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: Responsive.s(15), color: color),
          SizedBox(width: Responsive.s(4)),
          Text(
            '$mins:$secs',
            style: TextStyle(
              fontSize: Responsive.s(13),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final int index;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.index,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.s(10)),
      child: Material(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withAlpha(15)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(Responsive.s(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(Responsive.s(12)),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(Responsive.s(14)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Responsive.s(12)),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300]!,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: Responsive.s(28),
                  height: Responsive.s(28),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[200],
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index),
                      style: TextStyle(
                        fontSize: Responsive.s(13),
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: Responsive.s(12)),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: Responsive.s(15),
                      color: Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: Responsive.s(20),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
