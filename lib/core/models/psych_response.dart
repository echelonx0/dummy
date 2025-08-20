// lib/features/psychological_profile/models/psychology_response.dart

class PsychologyResponse {
  final String questionId;
  final String selectedOption; // 'A' or 'B'
  final String selectedPrinciple;
  final DateTime timestamp;
  final int timeSpentSeconds;

  const PsychologyResponse({
    required this.questionId,
    required this.selectedOption,
    required this.selectedPrinciple,
    required this.timestamp,
    required this.timeSpentSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'selectedOption': selectedOption,
      'selectedPrinciple': selectedPrinciple,
      'timestamp': timestamp.toIso8601String(),
      'timeSpentSeconds': timeSpentSeconds,
    };
  }

  factory PsychologyResponse.fromMap(Map<String, dynamic> map) {
    return PsychologyResponse(
      questionId: map['questionId'] ?? '',
      selectedOption: map['selectedOption'] ?? '',
      selectedPrinciple: map['selectedPrinciple'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      timeSpentSeconds: map['timeSpentSeconds']?.toInt() ?? 0,
    );
  }
}
