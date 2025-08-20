// lib/features/advanced_personalization/models/personalization_models.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalizationQuestion {
  final String id;
  final String question;
  final List<PersonalizationOption> options;

  const PersonalizationQuestion({
    required this.id,
    required this.question,
    required this.options,
  });
}

class PersonalizationOption {
  final String value;
  final String label;
  final int points;

  const PersonalizationOption({
    required this.value,
    required this.label,
    required this.points,
  });
}

class PersonalizationData {
  final String userId;
  final Map<String, String> partnerPreferences;
  final Map<String, String> personalDetails;
  final int qualificationScore;
  final bool clubEligible;
  final String clubType;
  final DateTime completedAt;
  final String manualReviewStatus;

  PersonalizationData({
    required this.userId,
    required this.partnerPreferences,
    required this.personalDetails,
    required this.qualificationScore,
    required this.clubEligible,
    required this.clubType,
    required this.completedAt,
    this.manualReviewStatus = 'pending',
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'partnerPreferences': partnerPreferences,
      'personalDetails': personalDetails,
      'qualificationScore': qualificationScore,
      'clubEligible': clubEligible,
      'clubType': clubType,
      'completedAt': Timestamp.fromDate(completedAt),
      'manualReviewStatus': manualReviewStatus,
    };
  }

  factory PersonalizationData.fromFirestore(Map<String, dynamic> data) {
    return PersonalizationData(
      userId: data['userId'] ?? '',
      partnerPreferences: Map<String, String>.from(
        data['partnerPreferences'] ?? {},
      ),
      personalDetails: Map<String, String>.from(data['personalDetails'] ?? {}),
      qualificationScore: data['qualificationScore'] ?? 0,
      clubEligible: data['clubEligible'] ?? false,
      clubType: data['clubType'] ?? '',
      completedAt:
          (data['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      manualReviewStatus: data['manualReviewStatus'] ?? 'pending',
    );
  }
}
