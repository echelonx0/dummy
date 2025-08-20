// lib/features/worldview_assessment/models/worldview_response.dart

class WorldviewResponse {
  final String questionId;
  final String selectedOption; // 'A' or 'B'
  final String selectedWorldview;
  final String valuesDimension;
  final String dealBreakerLevel;
  final DateTime timestamp;
  final int timeSpentSeconds;

  const WorldviewResponse({
    required this.questionId,
    required this.selectedOption,
    required this.selectedWorldview,
    required this.valuesDimension,
    required this.dealBreakerLevel,
    required this.timestamp,
    required this.timeSpentSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'selectedOption': selectedOption,
      'selectedWorldview': selectedWorldview,
      'valuesDimension': valuesDimension,
      'dealBreakerLevel': dealBreakerLevel,
      'timestamp': timestamp.toIso8601String(),
      'timeSpentSeconds': timeSpentSeconds,
    };
  }

  factory WorldviewResponse.fromMap(Map<String, dynamic> map) {
    return WorldviewResponse(
      questionId: map['questionId'] ?? '',
      selectedOption: map['selectedOption'] ?? '',
      selectedWorldview: map['selectedWorldview'] ?? '',
      valuesDimension: map['valuesDimension'] ?? '',
      dealBreakerLevel: map['dealBreakerLevel'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      timeSpentSeconds: map['timeSpentSeconds']?.toInt() ?? 0,
    );
  }
}
