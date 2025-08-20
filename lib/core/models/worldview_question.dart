// lib/features/worldview_assessment/models/worldview_question.dart

class WorldviewQuestion {
  final String id;
  final String scenario;
  final String optionA;
  final String optionB;
  final String worldviewA; // For matching algorithm
  final String worldviewB; // For matching algorithm
  final String valuesDimension; // Core values dimension being tested
  final String dealBreakerLevel; // 'high', 'medium', 'low'
  final int readingTimeSeconds;

  const WorldviewQuestion({
    required this.id,
    required this.scenario,
    required this.optionA,
    required this.optionB,
    required this.worldviewA,
    required this.worldviewB,
    required this.valuesDimension,
    required this.dealBreakerLevel,
    required this.readingTimeSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'scenario': scenario,
      'optionA': optionA,
      'optionB': optionB,
      'worldviewA': worldviewA,
      'worldviewB': worldviewB,
      'valuesDimension': valuesDimension,
      'dealBreakerLevel': dealBreakerLevel,
      'readingTimeSeconds': readingTimeSeconds,
    };
  }

  factory WorldviewQuestion.fromMap(Map<String, dynamic> map) {
    return WorldviewQuestion(
      id: map['id'] ?? '',
      scenario: map['scenario'] ?? '',
      optionA: map['optionA'] ?? '',
      optionB: map['optionB'] ?? '',
      worldviewA: map['worldviewA'] ?? '',
      worldviewB: map['worldviewB'] ?? '',
      valuesDimension: map['valuesDimension'] ?? '',
      dealBreakerLevel: map['dealBreakerLevel'] ?? '',
      readingTimeSeconds: map['readingTimeSeconds']?.toInt() ?? 0,
    );
  }
}
