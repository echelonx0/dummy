// lib/features/dashboard/models/user_insights.dart

class UserInsights {
  final double relationshipReadiness;
  final String readinessExplanation;
  final List<Map<String, String>> strengths;
  final List<Map<String, String>> growthAreas;

  // Enhanced psychological analysis
  final IntellectualProfile? intellectualAssessment;
  final GenderTraitsAnalysis? genderTraitsAnalysis;
  final AstrologicalProfile? astrologicalProfile;

  // Persona and audience targeting
  final String? persona;
  final String? audienceType;

  // Enhanced insight categories
  final Map<String, String>? communicationStyle;
  final Map<String, String>? emotionalIntelligence;
  final Map<String, String>? relationshipPatterns;
  final List<Map<String, String>>? compatibilityIndicators;

  UserInsights({
    required this.relationshipReadiness,
    required this.readinessExplanation,
    required this.strengths,
    required this.growthAreas,
    this.intellectualAssessment,
    this.genderTraitsAnalysis,
    this.astrologicalProfile,
    this.persona,
    this.audienceType,
    this.communicationStyle,
    this.emotionalIntelligence,
    this.relationshipPatterns,
    this.compatibilityIndicators,
  });

  factory UserInsights.fromFirestore(Map<String, dynamic> data) {
    return UserInsights(
      relationshipReadiness: (data['relationshipReadiness'] ?? 0.0).toDouble(),
      readinessExplanation:
          data['readinessExplanation'] ?? 'Analysis in progress...',

      // ✅ FIXED: Add defensive parsing for lists
      strengths: _parseInsightPoints(data['strengths']),
      growthAreas: _parseInsightPoints(data['growthAreas']),

      // ✅ FIXED: Add null checks for enhanced analysis
      intellectualAssessment:
          data['intellectualAssessment'] != null
              ? IntellectualProfile.fromMap(data['intellectualAssessment'])
              : null,
      genderTraitsAnalysis:
          data['genderTraitsAnalysis'] != null
              ? GenderTraitsAnalysis.fromMap(data['genderTraitsAnalysis'])
              : null,
      astrologicalProfile:
          data['astrologicalProfile'] != null
              ? AstrologicalProfile.fromMap(data['astrologicalProfile'])
              : null,

      // Persona targeting
      persona: data['persona'],
      audienceType: data['audienceType'],

      // ✅ FIXED: Enhanced categories with null safety
      communicationStyle:
          data['communicationStyle'] != null
              ? _parseStringMap(data['communicationStyle'])
              : null,
      emotionalIntelligence:
          data['emotionalIntelligence'] != null
              ? _parseStringMap(data['emotionalIntelligence'])
              : null,
      relationshipPatterns:
          data['relationshipPatterns'] != null
              ? _parseStringMap(data['relationshipPatterns'])
              : null,

      // ✅ FIXED: Handle compatibilityIndicators safely
      compatibilityIndicators:
          data['compatibilityIndicators'] != null
              ? _parseInsightPoints(data['compatibilityIndicators'])
              : null,
    );
  }

  // ✅ FIXED: Enhanced insight point parsing to handle supportingEvidence arrays
  static List<Map<String, String>> _parseInsightPoints(dynamic data) {
    if (data == null) return [];

    if (data is List) {
      return data.map((item) {
        if (item is Map) {
          // Convert all values to strings, handling arrays specially
          final cleanedItem = <String, String>{};
          item.forEach((key, value) {
            if (value is List) {
              // Convert array to comma-separated string
              cleanedItem[key.toString()] = value.join(', ');
            } else {
              cleanedItem[key.toString()] = value.toString();
            }
          });
          return cleanedItem;
        }
        return <String, String>{}; // Empty map fallback
      }).toList();
    }

    return []; // Empty list fallback
  }

  // ✅ NEW: Helper method for safe string map parsing
  static Map<String, String> _parseStringMap(dynamic data) {
    if (data == null) return {};

    if (data is Map) {
      return Map<String, String>.from(data);
    }

    return {}; // Empty map fallback
  }

  static UserInsights empty() {
    return UserInsights(
      relationshipReadiness: 0.0,
      readinessExplanation: 'No insights available yet',
      strengths: [],
      growthAreas: [],
    );
  }

  bool get hasData => relationshipReadiness > 0 || strengths.isNotEmpty;

  bool get hasEnhancedData =>
      intellectualAssessment != null ||
      genderTraitsAnalysis != null ||
      astrologicalProfile != null;

  bool get isPersonalVersion => audienceType == 'personal';
  bool get isMatchProfileVersion => audienceType == 'match_profile';

  String get readinessLevel {
    if (relationshipReadiness >= 0.8) return 'High';
    if (relationshipReadiness >= 0.6) return 'Moderate';
    if (relationshipReadiness >= 0.4) return 'Developing';
    return 'Early Stage';
  }

  String get personaDisplayName {
    switch (persona) {
      case 'sage':
        return 'Sophia the Sage';
      case 'cheerleader':
        return 'Maya the Cheerleader';
      case 'strategist':
        return 'Alex the Strategist';
      case 'empath':
        return 'Luna the Empath';
      default:
        return 'Your Matchmaker';
    }
  }
}

// Supporting classes for enhanced analysis
class IntellectualProfile {
  final int estimatedIQ;
  final String confidenceLevel;
  final String reasoning;
  final List<String> cognitiveStrengths;
  final String analysisQuality;

  IntellectualProfile({
    required this.estimatedIQ,
    required this.confidenceLevel,
    required this.reasoning,
    required this.cognitiveStrengths,
    required this.analysisQuality,
  });

  factory IntellectualProfile.fromMap(Map<String, dynamic> data) {
    return IntellectualProfile(
      estimatedIQ: data['estimatedIQ'] ?? 100,
      confidenceLevel: data['confidenceLevel'] ?? 'moderate',
      reasoning: data['reasoning'] ?? '',

      // ✅ FIXED: Handle cognitiveStrengths safely
      cognitiveStrengths: _parseStringList(data['cognitiveStrengths']),
      analysisQuality: data['analysisQuality'] ?? '',
    );
  }

  // ✅ NEW: Safe string list parsing
  static List<String> _parseStringList(dynamic data) {
    if (data == null) return [];

    if (data is List) {
      return data.map((item) => item.toString()).toList();
    }

    if (data is String) {
      return [data]; // Single string to list
    }

    return []; // Fallback
  }

  String get iqRange {
    if (estimatedIQ >= 130) return 'Very Superior (130+)';
    if (estimatedIQ >= 120) return 'Superior (120-129)';
    if (estimatedIQ >= 110) return 'High Average (110-119)';
    if (estimatedIQ >= 90) return 'Average (90-109)';
    if (estimatedIQ >= 80) return 'Low Average (80-89)';
    return 'Below Average (<80)';
  }

  String get confidenceDescription {
    switch (confidenceLevel) {
      case 'high':
        return 'High confidence based on extensive profile data';
      case 'moderate':
        return 'Moderate confidence based on available responses';
      case 'low':
        return 'Estimated based on limited data';
      default:
        return 'Assessment confidence not specified';
    }
  }
}

class GenderTraitsAnalysis {
  final List<TraitExpression> masculineTraits;
  final List<TraitExpression> feminineTraits;
  final String balanceAssessment;
  final String expressionStyle;

  GenderTraitsAnalysis({
    required this.masculineTraits,
    required this.feminineTraits,
    required this.balanceAssessment,
    required this.expressionStyle,
  });

  factory GenderTraitsAnalysis.fromMap(Map<String, dynamic> data) {
    return GenderTraitsAnalysis(
      masculineTraits: _parseTraitExpressionList(data['masculineTraits']),
      feminineTraits: _parseTraitExpressionList(data['feminineTraits']),
      balanceAssessment: data['balanceAssessment'] ?? '',
      expressionStyle: data['expressionStyle'] ?? '',
    );
  }

  // ✅ NEW: Safe trait expression list parsing
  static List<TraitExpression> _parseTraitExpressionList(dynamic data) {
    if (data == null) return [];

    if (data is List) {
      return data.map((item) {
        if (item is Map) {
          return TraitExpression.fromMap(Map<String, dynamic>.from(item));
        }
        return TraitExpression(
          trait: '',
          manifestation: '',
          relationshipImpact: '',
        );
      }).toList();
    }

    return [];
  }

  List<TraitExpression> get allTraits => [
    ...masculineTraits,
    ...feminineTraits,
  ];

  bool get hasBalancedExpression =>
      masculineTraits.isNotEmpty && feminineTraits.isNotEmpty;
}

class TraitExpression {
  final String trait;
  final String manifestation;
  final String relationshipImpact;

  TraitExpression({
    required this.trait,
    required this.manifestation,
    required this.relationshipImpact,
  });

  factory TraitExpression.fromMap(Map<String, dynamic> data) {
    return TraitExpression(
      trait: data['trait'] ?? '',
      manifestation: data['manifestation'] ?? '',
      relationshipImpact: data['relationshipImpact'] ?? '',
    );
  }
}

class AstrologicalProfile {
  final BirthDetails birthDetails;
  final PersonalityCorrelations personalityCorrelations;
  final RelationshipAstrology relationshipAstrology;
  final String confidence;

  AstrologicalProfile({
    required this.birthDetails,
    required this.personalityCorrelations,
    required this.relationshipAstrology,
    required this.confidence,
  });

  factory AstrologicalProfile.fromMap(Map<String, dynamic> data) {
    return AstrologicalProfile(
      birthDetails: BirthDetails.fromMap(data['birthDetails'] ?? {}),
      personalityCorrelations: PersonalityCorrelations.fromMap(
        data['personalityCorrelations'] ?? {},
      ),
      relationshipAstrology: RelationshipAstrology.fromMap(
        data['relationshipAstrology'] ?? {},
      ),
      confidence: data['confidence'] ?? 'estimated',
    );
  }

  bool get isEstimated => confidence == 'estimated';

  String get fullAstroDescription =>
      '${birthDetails.sunSign} ☀️ ${birthDetails.moonSign} 🌙 ${birthDetails.risingSign} ⬆️';
}

class BirthDetails {
  final String sunSign;
  final String moonSign;
  final String risingSign;

  BirthDetails({
    required this.sunSign,
    required this.moonSign,
    required this.risingSign,
  });

  factory BirthDetails.fromMap(Map<String, dynamic> data) {
    return BirthDetails(
      sunSign: data['sunSign'] ?? 'Unknown',
      moonSign: data['moonSign'] ?? 'Unknown',
      risingSign: data['risingSign'] ?? 'Unknown',
    );
  }
}

class PersonalityCorrelations {
  final String sunSignTraits;
  final String moonSignEmotions;
  final String risingSignPresentation;

  PersonalityCorrelations({
    required this.sunSignTraits,
    required this.moonSignEmotions,
    required this.risingSignPresentation,
  });

  factory PersonalityCorrelations.fromMap(Map<String, dynamic> data) {
    return PersonalityCorrelations(
      sunSignTraits: data['sunSignTraits'] ?? '',
      moonSignEmotions: data['moonSignEmotions'] ?? '',
      risingSignPresentation: data['risingSignPresentation'] ?? '',
    );
  }
}

class RelationshipAstrology {
  final String loveLanguageConnection;
  final String communicationStyle;
  final List<String> compatibilityIndicators;

  RelationshipAstrology({
    required this.loveLanguageConnection,
    required this.communicationStyle,
    required this.compatibilityIndicators,
  });

  factory RelationshipAstrology.fromMap(Map<String, dynamic> data) {
    return RelationshipAstrology(
      loveLanguageConnection: data['loveLanguageConnection'] ?? '',
      communicationStyle: data['communicationStyle'] ?? '',

      // ✅ FIXED: Handle compatibilityIndicators safely
      compatibilityIndicators: IntellectualProfile._parseStringList(
        data['compatibilityIndicators'],
      ),
    );
  }
}
