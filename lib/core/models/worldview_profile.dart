// lib/features/worldview_assessment/models/worldview_profile.dart

import 'worldview_response.dart';

class WorldviewProfile {
  final String userId;
  final String profileCode;
  final List<WorldviewResponse> responses;
  final Map<String, String> worldviewMap; // dimension -> selected worldview
  final Map<String, String> dealBreakerMap; // dimension -> deal breaker level
  final DateTime completedAt;
  final int totalTimeSpentSeconds;
  final bool isComplete;
  final double
  politicalAlignment; // -1 (very progressive) to 1 (very conservative)
  final double socialAlignment; // -1 (very liberal) to 1 (very traditional)

  const WorldviewProfile({
    required this.userId,
    required this.profileCode,
    required this.responses,
    required this.worldviewMap,
    required this.dealBreakerMap,
    required this.completedAt,
    required this.totalTimeSpentSeconds,
    required this.isComplete,
    required this.politicalAlignment,
    required this.socialAlignment,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'profileCode': profileCode,
      'responses': responses.map((r) => r.toMap()).toList(),
      'worldviewMap': worldviewMap,
      'dealBreakerMap': dealBreakerMap,
      'completedAt': completedAt.toIso8601String(),
      'totalTimeSpentSeconds': totalTimeSpentSeconds,
      'isComplete': isComplete,
      'politicalAlignment': politicalAlignment,
      'socialAlignment': socialAlignment,
    };
  }

  factory WorldviewProfile.fromMap(Map<String, dynamic> map) {
    return WorldviewProfile(
      userId: map['userId'] ?? '',
      profileCode: map['profileCode'] ?? '',
      responses: List<WorldviewResponse>.from(
        map['responses']?.map((x) => WorldviewResponse.fromMap(x)) ?? [],
      ),
      worldviewMap: Map<String, String>.from(map['worldviewMap'] ?? {}),
      dealBreakerMap: Map<String, String>.from(map['dealBreakerMap'] ?? {}),
      completedAt: DateTime.parse(map['completedAt']),
      totalTimeSpentSeconds: map['totalTimeSpentSeconds']?.toInt() ?? 0,
      isComplete: map['isComplete'] ?? false,
      politicalAlignment: map['politicalAlignment']?.toDouble() ?? 0.0,
      socialAlignment: map['socialAlignment']?.toDouble() ?? 0.0,
    );
  }
}
