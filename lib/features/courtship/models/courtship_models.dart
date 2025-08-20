// lib/features/courtship/models/courtship_models.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum CourtshipStatus {
  pending,
  active,
  completed,
  abandoned,
  successful,
  declined,
}

enum CourtshipStage {
  commitment,
  introduction,
  compatibility,
  discovery,
  decision,
}

enum CourtshipAction { continueCourtship, exitCourtship, viewDetails }

// Main Courtship Model
class Courtship {
  final String id;
  final List<String> participants;
  final CourtshipStatus status;
  final CourtshipStage stage;
  final DateTime startDate;
  final int currentDay;
  final int maxDays;
  final Map<String, CourtshipCommitment> commitments;
  final List<CourtshipStageHistory> stageHistory;
  final List<CourtshipInteraction> interactions;
  final CourtshipExitRequest? exitRequest;
  final CourtshipOutcome? outcome;

  Courtship({
    required this.id,
    required this.participants,
    required this.status,
    required this.stage,
    required this.startDate,
    required this.currentDay,
    required this.maxDays,
    required this.commitments,
    required this.stageHistory,
    required this.interactions,
    this.exitRequest,
    this.outcome,
  });

  factory Courtship.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Courtship(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      status: CourtshipStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => CourtshipStatus.pending,
      ),
      stage: CourtshipStage.values.firstWhere(
        (e) => e.name == data['stage'],
        orElse: () => CourtshipStage.commitment,
      ),
      startDate: (data['startDate'] as Timestamp).toDate(),
      currentDay: data['currentDay'] ?? 0,
      maxDays: data['maxDays'] ?? 14,
      commitments: (data['commitments'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(
          key,
          CourtshipCommitment.fromMap(value as Map<String, dynamic>),
        ),
      ),
      stageHistory:
          (data['stageHistory'] as List<dynamic>? ?? [])
              .map(
                (item) =>
                    CourtshipStageHistory.fromMap(item as Map<String, dynamic>),
              )
              .toList(),
      interactions:
          (data['interactions'] as List<dynamic>? ?? [])
              .map(
                (item) =>
                    CourtshipInteraction.fromMap(item as Map<String, dynamic>),
              )
              .toList(),
      exitRequest:
          data['exitRequest'] != null
              ? CourtshipExitRequest.fromMap(
                data['exitRequest'] as Map<String, dynamic>,
              )
              : null,
      outcome:
          data['outcome'] != null
              ? CourtshipOutcome.fromMap(
                data['outcome'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'status': status.name,
      'stage': stage.name,
      'startDate': Timestamp.fromDate(startDate),
      'currentDay': currentDay,
      'maxDays': maxDays,
      'commitments': commitments.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'stageHistory': stageHistory.map((item) => item.toMap()).toList(),
      'interactions': interactions.map((item) => item.toMap()).toList(),
      'exitRequest': exitRequest?.toMap(),
      'outcome': outcome?.toMap(),
    };
  }
}

class CourtshipCommitment {
  final bool committed;
  final DateTime? timestamp;
  final bool acknowledged;

  CourtshipCommitment({
    required this.committed,
    this.timestamp,
    required this.acknowledged,
  });

  factory CourtshipCommitment.fromMap(Map<String, dynamic> map) {
    return CourtshipCommitment(
      committed: map['committed'] ?? false,
      timestamp:
          map['timestamp'] != null
              ? (map['timestamp'] as Timestamp).toDate()
              : null,
      acknowledged: map['acknowledged'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'committed': committed,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
      'acknowledged': acknowledged,
    };
  }
}

class CourtshipStageHistory {
  final String stage;
  final DateTime startDate;
  final DateTime? endDate;
  final bool completed;

  CourtshipStageHistory({
    required this.stage,
    required this.startDate,
    this.endDate,
    required this.completed,
  });

  factory CourtshipStageHistory.fromMap(Map<String, dynamic> map) {
    return CourtshipStageHistory(
      stage: map['stage'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate:
          map['endDate'] != null
              ? (map['endDate'] as Timestamp).toDate()
              : null,
      completed: map['completed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stage': stage,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'completed': completed,
    };
  }
}

class CourtshipInteraction {
  final int day;
  final String stage;
  final String aiPrompt;
  final Map<String, UserResponse> userResponses;
  final String? aiFollowUp;
  final bool completed;
  final String nextAction;
  final DateTime timestamp;

  CourtshipInteraction({
    required this.day,
    required this.stage,
    required this.aiPrompt,
    required this.userResponses,
    this.aiFollowUp,
    required this.completed,
    required this.nextAction,
    required this.timestamp,
  });

  factory CourtshipInteraction.fromMap(Map<String, dynamic> map) {
    return CourtshipInteraction(
      day: map['day'] ?? 0,
      stage: map['stage'] ?? '',
      aiPrompt: map['aiPrompt'] ?? '',
      userResponses: (map['userResponses'] as Map<String, dynamic>? ?? {}).map(
        (key, value) =>
            MapEntry(key, UserResponse.fromMap(value as Map<String, dynamic>)),
      ),
      aiFollowUp: map['aiFollowUp'],
      completed: map['completed'] ?? false,
      nextAction: map['nextAction'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'stage': stage,
      'aiPrompt': aiPrompt,
      'userResponses': userResponses.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'aiFollowUp': aiFollowUp,
      'completed': completed,
      'nextAction': nextAction,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class UserResponse {
  final String response;
  final DateTime timestamp;
  final String engagement; // 'high', 'medium', 'low'

  UserResponse({
    required this.response,
    required this.timestamp,
    required this.engagement,
  });

  factory UserResponse.fromMap(Map<String, dynamic> map) {
    return UserResponse(
      response: map['response'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      engagement: map['engagement'] ?? 'medium',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'response': response,
      'timestamp': Timestamp.fromDate(timestamp),
      'engagement': engagement,
    };
  }
}

class CourtshipExitRequest {
  final String requestedBy;
  final String reason;
  final DateTime timestamp;
  final String type; // 'respectful' or 'abandonment'
  final bool acknowledged;

  CourtshipExitRequest({
    required this.requestedBy,
    required this.reason,
    required this.timestamp,
    required this.type,
    required this.acknowledged,
  });

  factory CourtshipExitRequest.fromMap(Map<String, dynamic> map) {
    return CourtshipExitRequest(
      requestedBy: map['requestedBy'] ?? '',
      reason: map['reason'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      type: map['type'] ?? 'respectful',
      acknowledged: map['acknowledged'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestedBy': requestedBy,
      'reason': reason,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type,
      'acknowledged': acknowledged,
    };
  }
}

class CourtshipOutcome {
  final String result; // 'matched', 'no_match', 'abandoned'
  final Map<String, CourtshipFeedback> feedback;
  final String? relationshipStatus;

  CourtshipOutcome({
    required this.result,
    required this.feedback,
    this.relationshipStatus,
  });

  factory CourtshipOutcome.fromMap(Map<String, dynamic> map) {
    return CourtshipOutcome(
      result: map['result'] ?? '',
      feedback: (map['feedback'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(
          key,
          CourtshipFeedback.fromMap(value as Map<String, dynamic>),
        ),
      ),
      relationshipStatus: map['relationshipStatus'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'result': result,
      'feedback': feedback.map((key, value) => MapEntry(key, value.toMap())),
      'relationshipStatus': relationshipStatus,
    };
  }
}

// User Courtship Status Model
class UserCourtshipStatus {
  final bool isInCourtship;
  final String? currentCourtshipId;
  final DateTime? availableDate;
  final List<String> courtshipHistory;
  final CourtshipPenalties penalties;

  UserCourtshipStatus({
    required this.isInCourtship,
    this.currentCourtshipId,
    this.availableDate,
    required this.courtshipHistory,
    required this.penalties,
  });

  factory UserCourtshipStatus.fromFirestore(Map<String, dynamic> data) {
    return UserCourtshipStatus(
      isInCourtship: data['isInCourtship'] ?? false,
      currentCourtshipId: data['currentCourtshipId'],
      availableDate:
          data['availableDate'] != null
              ? (data['availableDate'] as Timestamp).toDate()
              : null,
      courtshipHistory: List<String>.from(data['courtshipHistory'] ?? []),
      penalties: CourtshipPenalties.fromMap(
        data['penalties'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'isInCourtship': isInCourtship,
      'currentCourtshipId': currentCourtshipId,
      'availableDate':
          availableDate != null ? Timestamp.fromDate(availableDate!) : null,
      'courtshipHistory': courtshipHistory,
      'penalties': penalties.toMap(),
    };
  }
}

class CourtshipPenalties {
  final int abandonmentCount;
  final DateTime? lastPenaltyDate;
  final int currentPenaltyLevel;

  CourtshipPenalties({
    required this.abandonmentCount,
    this.lastPenaltyDate,
    required this.currentPenaltyLevel,
  });

  factory CourtshipPenalties.fromMap(Map<String, dynamic> map) {
    return CourtshipPenalties(
      abandonmentCount: map['abandonmentCount'] ?? 0,
      lastPenaltyDate:
          map['lastPenaltyDate'] != null
              ? (map['lastPenaltyDate'] as Timestamp).toDate()
              : null,
      currentPenaltyLevel: map['currentPenaltyLevel'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'abandonmentCount': abandonmentCount,
      'lastPenaltyDate':
          lastPenaltyDate != null ? Timestamp.fromDate(lastPenaltyDate!) : null,
      'currentPenaltyLevel': currentPenaltyLevel,
    };
  }
}

// Match Recommendation Model
class MatchRecommendation {
  final String userId;
  final String name;
  final int age;
  final String city;
  final List<String> photos;
  final double compatibilityScore;
  final List<String> sharedValues;
  final String? attachmentStyle;
  final DateTime matchedAt;
  final TrustScore? trustScore;

  MatchRecommendation({
    required this.userId,
    required this.name,
    required this.age,
    required this.city,
    required this.photos,
    required this.compatibilityScore,
    required this.sharedValues,
    this.attachmentStyle,
    required this.matchedAt,
    this.trustScore,
  });

  factory MatchRecommendation.fromFirestore(
    String userId,
    Map<String, dynamic> data,
  ) {
    return MatchRecommendation(
      userId: userId,
      name: data['name'] ?? 'Unknown',
      age: data['age'] ?? 0,
      city: data['city'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
      compatibilityScore: (data['compatibilityScore'] ?? 0).toDouble(),
      sharedValues: List<String>.from(data['sharedValues'] ?? []),
      attachmentStyle: data['attachmentStyle'],
      matchedAt: (data['matchedAt'] as Timestamp).toDate(),
      trustScore:
          data['trustScore'] != null
              ? TrustScore.fromMap(data['trustScore'] as Map<String, dynamic>)
              : null,
    );
  }
}

// Trust Score Model
class TrustScore {
  final double overallScore;
  final double completionRate;
  final double averageRating;
  final double responseTime;
  final double authenticityScore;
  final double communityContribution;
  final String trend; // 'improving', 'stable', 'declining'
  final DateTime lastUpdated;

  TrustScore({
    required this.overallScore,
    required this.completionRate,
    required this.averageRating,
    required this.responseTime,
    required this.authenticityScore,
    required this.communityContribution,
    required this.trend,
    required this.lastUpdated,
  });

  factory TrustScore.fromMap(Map<String, dynamic> map) {
    return TrustScore(
      overallScore: (map['overallScore'] ?? 0).toDouble(),
      completionRate: (map['completionRate'] ?? 0).toDouble(),
      averageRating: (map['averageRating'] ?? 0).toDouble(),
      responseTime: (map['responseTime'] ?? 0).toDouble(),
      authenticityScore: (map['authenticityScore'] ?? 0).toDouble(),
      communityContribution: (map['communityContribution'] ?? 0).toDouble(),
      trend: map['trend'] ?? 'stable',
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'overallScore': overallScore,
      'completionRate': completionRate,
      'averageRating': averageRating,
      'responseTime': responseTime,
      'authenticityScore': authenticityScore,
      'communityContribution': communityContribution,
      'trend': trend,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  String get scoreCategory {
    if (overallScore >= 90) return 'Excellent';
    if (overallScore >= 70) return 'Good';
    if (overallScore >= 50) return 'Fair';
    return 'Needs Improvement';
  }

  Color get scoreColor {
    if (overallScore >= 90) return const Color(0xFF95E1A3); // Mint green
    if (overallScore >= 70) return const Color(0xFF4ECDC4); // Electric blue
    if (overallScore >= 50) return const Color(0xFFFFE66D); // Sunset orange
    return const Color(0xFFFF6B9D); // Coral pink
  }
}

// Feedback Model for Rating System
class CourtshipFeedback {
  final int communicationRating;
  final int authenticityRating;
  final int respectRating;
  final int commitmentRating;
  final int? meetingRating;
  final String writtenFeedback;
  final String reasonCategory;
  final bool wouldRecommend;
  final int processRating;
  final DateTime submittedAt;

  CourtshipFeedback({
    required this.communicationRating,
    required this.authenticityRating,
    required this.respectRating,
    required this.commitmentRating,
    this.meetingRating,
    required this.writtenFeedback,
    required this.reasonCategory,
    required this.wouldRecommend,
    required this.processRating,
    required this.submittedAt,
  });

  factory CourtshipFeedback.fromMap(Map<String, dynamic> map) {
    return CourtshipFeedback(
      communicationRating: map['communicationRating'] ?? 0,
      authenticityRating: map['authenticityRating'] ?? 0,
      respectRating: map['respectRating'] ?? 0,
      commitmentRating: map['commitmentRating'] ?? 0,
      meetingRating: map['meetingRating'],
      writtenFeedback: map['writtenFeedback'] ?? '',
      reasonCategory: map['reasonCategory'] ?? '',
      wouldRecommend: map['wouldRecommend'] ?? false,
      processRating: map['processRating'] ?? 0,
      submittedAt: (map['submittedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'communicationRating': communicationRating,
      'authenticityRating': authenticityRating,
      'respectRating': respectRating,
      'commitmentRating': commitmentRating,
      'meetingRating': meetingRating,
      'writtenFeedback': writtenFeedback,
      'reasonCategory': reasonCategory,
      'wouldRecommend': wouldRecommend,
      'processRating': processRating,
      'submittedAt': Timestamp.fromDate(submittedAt),
    };
  }

  double get averageRating {
    final ratings = [
      communicationRating,
      authenticityRating,
      respectRating,
      commitmentRating,
      if (meetingRating != null) meetingRating!,
    ];
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }
}
