// lib/features/psychological_profile/models/psychology_profile.dart

import 'psych_response.dart';

class PsychologyProfile {
  final String userId;
  final String profileCode; // Unique code for matching
  final List<PsychologyResponse> responses;
  final Map<String, String> principleMap; // dimension -> selected principle
  final DateTime completedAt;
  final int totalTimeSpentSeconds;
  final bool isComplete;

  const PsychologyProfile({
    required this.userId,
    required this.profileCode,
    required this.responses,
    required this.principleMap,
    required this.completedAt,
    required this.totalTimeSpentSeconds,
    required this.isComplete,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'profileCode': profileCode,
      'responses': responses.map((r) => r.toMap()).toList(),
      'principleMap': principleMap,
      'completedAt': completedAt.toIso8601String(),
      'totalTimeSpentSeconds': totalTimeSpentSeconds,
      'isComplete': isComplete,
    };
  }

  factory PsychologyProfile.fromMap(Map<String, dynamic> map) {
    return PsychologyProfile(
      userId: map['userId'] ?? '',
      profileCode: map['profileCode'] ?? '',
      responses: List<PsychologyResponse>.from(
        map['responses']?.map((x) => PsychologyResponse.fromMap(x)) ?? [],
      ),
      principleMap: Map<String, String>.from(map['principleMap'] ?? {}),
      completedAt: DateTime.parse(map['completedAt']),
      totalTimeSpentSeconds: map['totalTimeSpentSeconds']?.toInt() ?? 0,
      isComplete: map['isComplete'] ?? false,
    );
  }
}
