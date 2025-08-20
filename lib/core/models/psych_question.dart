// lib/features/psychological_profile/models/psychology_question.dart

class PsychologyQuestion {
  final String id;
  final String scenario;
  final String optionA;
  final String optionB;
  final String principleA; // For matching algorithm
  final String principleB; // For matching algorithm
  final String psychologicalDimension; // Core dimension being measured
  final int readingTimeSeconds;

  const PsychologyQuestion({
    required this.id,
    required this.scenario,
    required this.optionA,
    required this.optionB,
    required this.principleA,
    required this.principleB,
    required this.psychologicalDimension,
    required this.readingTimeSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'scenario': scenario,
      'optionA': optionA,
      'optionB': optionB,
      'principleA': principleA,
      'principleB': principleB,
      'psychologicalDimension': psychologicalDimension,
      'readingTimeSeconds': readingTimeSeconds,
    };
  }

  factory PsychologyQuestion.fromMap(Map<String, dynamic> map) {
    return PsychologyQuestion(
      id: map['id'] ?? '',
      scenario: map['scenario'] ?? '',
      optionA: map['optionA'] ?? '',
      optionB: map['optionB'] ?? '',
      principleA: map['principleA'] ?? '',
      principleB: map['principleB'] ?? '',
      psychologicalDimension: map['psychologicalDimension'] ?? '',
      readingTimeSeconds: map['readingTimeSeconds']?.toInt() ?? 0,
    );
  }
}
