import 'package:equatable/equatable.dart';

class QuestionModel extends Equatable {
  final String id;
  final String contentId;
  final String text;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;
  final int difficulty; // 1: Easy, 2: Medium, 3: Hard

  const QuestionModel({
    required this.id,
    required this.contentId,
    required this.text,
    this.options = const [],
    this.correctAnswer = 0,
    this.explanation,
    this.difficulty = 1,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      contentId: json['contentId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      options:
          (json['options'] as List?)?.map((e) => e as String).toList() ??
          const [],
      correctAnswer: (json['correctAnswer'] as num?)?.toInt() ?? 0,
      explanation: json['explanation'] as String?,
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentId': contentId,
      'text': text,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'difficulty': difficulty,
    };
  }

  QuestionModel copyWith({
    String? id,
    String? contentId,
    String? text,
    List<String>? options,
    int? correctAnswer,
    String? explanation,
    int? difficulty,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      text: text ?? this.text,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  static QuestionModel fromBackend(Map<String, dynamic> json) {
    final optionsRaw = json['options'] as List? ?? [];
    final List<String> options = [];
    int correctAnswerIndex = 0;

    for (int i = 0; i < optionsRaw.length; i++) {
      final opt = optionsRaw[i] as Map<String, dynamic>;
      options.add(opt['text'] ?? '');
      if (opt['isCorrect'] == true) {
        correctAnswerIndex = i;
      }
    }

    int difficulty = 1;
    final diffLevel = json['difficultyLevel'] as String? ?? 'MEDIUM';
    if (diffLevel == 'MEDIUM') difficulty = 2;
    if (diffLevel == 'HARD') difficulty = 3;

    return QuestionModel.fromJson({
      ...json,
      'id': json['_id'],
      'contentId': json['mockTestId'],
      'text': json['questionText'],
      'options': options,
      'correctAnswer': correctAnswerIndex,
      'difficulty': difficulty,
    });
  }

  factory QuestionModel.empty() {
    return const QuestionModel(id: '', contentId: '', text: '');
  }

  @override
  List<Object?> get props => [
    id,
    contentId,
    text,
    options,
    correctAnswer,
    explanation,
    difficulty,
  ];
}
