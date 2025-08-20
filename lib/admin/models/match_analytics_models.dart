// lib/features/admin/models/match_analytics_models.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MatchEngineRun {
  final String id;
  final DateTime timestamp;
  final String runType;
  final RunMetrics metrics;
  final QualityMetrics qualityMetrics;
  final CostMetrics costMetrics;
  final String status;
  final List<String>? errorDetails;

  MatchEngineRun({
    required this.id,
    required this.timestamp,
    required this.runType,
    required this.metrics,
    required this.qualityMetrics,
    required this.costMetrics,
    required this.status,
    this.errorDetails,
  });

  factory MatchEngineRun.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MatchEngineRun(
      id: doc.id,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      runType: data['runType'] ?? 'production',
      metrics: RunMetrics.fromMap(data['metrics'] ?? {}),
      qualityMetrics: QualityMetrics.fromMap(data['qualityMetrics'] ?? {}),
      costMetrics: CostMetrics.fromMap(data['costMetrics'] ?? {}),
      status: data['status'] ?? 'unknown',
      errorDetails: data['errorDetails'] != null 
        ? List<String>.from(data['errorDetails']) 
        : null,
    );
  }
}

class RunMetrics {
  final int usersProcessed;
  final int matchesGenerated;
  final int apiCallsMade;
  final int executionTimeMs;
  final int errorsCount;
  final int successfulMatches;

  RunMetrics({
    required this.usersProcessed,
    required this.matchesGenerated,
    required this.apiCallsMade,
    required this.executionTimeMs,
    required this.errorsCount,
    required this.successfulMatches,
  });

  factory RunMetrics.fromMap(Map<String, dynamic> data) {
    return RunMetrics(
      usersProcessed: data['usersProcessed'] ?? 0,
      matchesGenerated: data['matchesGenerated'] ?? 0,
      apiCallsMade: data['apiCallsMade'] ?? 0,
      executionTimeMs: data['executionTimeMs'] ?? 0,
      errorsCount: data['errorsCount'] ?? 0,
      successfulMatches: data['successfulMatches'] ?? 0,
    );
  }

  double get successRate => 
    matchesGenerated > 0 ? (successfulMatches / matchesGenerated) * 100 : 0;
    
  double get executionTimeSeconds => executionTimeMs / 1000;
}

class QualityMetrics {
  final double averageCompatibilityScore;
  final Map<String, int> scoreDistribution;
  final List<CompatibilityFactor> topCompatibilityFactors;
  final int conversationStartersGenerated;

  QualityMetrics({
    required this.averageCompatibilityScore,
    required this.scoreDistribution,
    required this.topCompatibilityFactors,
    required this.conversationStartersGenerated,
  });

  factory QualityMetrics.fromMap(Map<String, dynamic> data) {
    return QualityMetrics(
      averageCompatibilityScore: (data['averageCompatibilityScore'] ?? 0).toDouble(),
      scoreDistribution: Map<String, int>.from(data['scoreDistribution'] ?? {}),
      topCompatibilityFactors: (data['topCompatibilityFactors'] as List? ?? [])
        .map((f) => CompatibilityFactor.fromMap(f))
        .toList(),
      conversationStartersGenerated: data['conversationStartersGenerated'] ?? 0,
    );
  }
}

class CostMetrics {
  final int geminiTokensUsed;
  final double estimatedCostUSD;
  final int firestoreReads;
  final int firestoreWrites;

  CostMetrics({
    required this.geminiTokensUsed,
    required this.estimatedCostUSD,
    required this.firestoreReads,
    required this.firestoreWrites,
  });

  factory CostMetrics.fromMap(Map<String, dynamic> data) {
    return CostMetrics(
      geminiTokensUsed: data['geminiTokensUsed'] ?? 0,
      estimatedCostUSD: (data['estimatedCostUSD'] ?? 0).toDouble(),
      firestoreReads: data['firestoreReads'] ?? 0,
      firestoreWrites: data['firestoreWrites'] ?? 0,
    );
  }
}

class CompatibilityFactor {
  final String factor;
  final double avgScore;
  final int frequency;

  CompatibilityFactor({
    required this.factor,
    required this.avgScore,
    required this.frequency,
  });

  factory CompatibilityFactor.fromMap(Map<String, dynamic> data) {
    return CompatibilityFactor(
      factor: data['factor'] ?? '',
      avgScore: (data['avgScore'] ?? 0).toDouble(),
      frequency: data['frequency'] ?? 0,
    );
  }
}

class MatchAnalytic {
  final String id;
  final String runId;
  final String userAId;
  final String userBId;
  final int compatibilityScore;
  final List<FactorScore> compatibilityFactors;
  final List<String> conversationStarters;
  final int processingTimeMs;
  final DateTime timestamp;
  final String aiModel;
  final bool userAViewed;
  final bool userBViewed;
  final bool conversationStarted;
  final bool premiumUpgrade;

  MatchAnalytic({
    required this.id,
    required this.runId,
    required this.userAId,
    required this.userBId,
    required this.compatibilityScore,
    required this.compatibilityFactors,
    required this.conversationStarters,
    required this.processingTimeMs,
    required this.timestamp,
    required this.aiModel,
    required this.userAViewed,
    required this.userBViewed,
    required this.conversationStarted,
    required this.premiumUpgrade,
  });

  factory MatchAnalytic.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MatchAnalytic(
      id: doc.id,
      runId: data['runId'] ?? '',
      userAId: data['userAId'] ?? '',
      userBId: data['userBId'] ?? '',
      compatibilityScore: data['compatibilityScore'] ?? 0,
      compatibilityFactors: (data['compatibilityFactors'] as List? ?? [])
        .map((f) => FactorScore.fromMap(f))
        .toList(),
      conversationStarters: List<String>.from(data['conversationStarters'] ?? []),
      processingTimeMs: data['processingTimeMs'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      aiModel: data['aiModel'] ?? '',
      userAViewed: data['userAViewed'] ?? false,
      userBViewed: data['userBViewed'] ?? false,
      conversationStarted: data['conversationStarted'] ?? false,
      premiumUpgrade: data['premiumUpgrade'] ?? false,
    );
  }

  double get processingTimeSeconds => processingTimeMs / 1000;
  
  String get scoreCategory {
    if (compatibilityScore >= 75) return 'High';
    if (compatibilityScore >= 50) return 'Medium';
    return 'Low';
  }
  
  List<FactorScore> get topFactors => 
    [...compatibilityFactors]..sort((a, b) => b.score.compareTo(a.score));
}

class FactorScore {
  final String factor;
  final double score;
  final double weight;
  final String details;

  FactorScore({
    required this.factor,
    required this.score,
    required this.weight,
    required this.details,
  });

  factory FactorScore.fromMap(Map<String, dynamic> data) {
    return FactorScore(
      factor: data['factor'] ?? '',
      score: (data['score'] ?? 0).toDouble(),
      weight: (data['weight'] ?? 0).toDouble(),
      details: data['details'] ?? '',
    );
  }
}

class DailyInsights {
  final String date;
  final int totalRuns;
  final int totalMatches;
  final int totalUsers;
  final double averageScore;
  final double totalCostUSD;
  final double userEngagementRate;
  final ConversionMetrics conversionMetrics;
  final DateTime lastUpdated;

  DailyInsights({
    required this.date,
    required this.totalRuns,
    required this.totalMatches,
    required this.totalUsers,
    required this.averageScore,
    required this.totalCostUSD,
    required this.userEngagementRate,
    required this.conversionMetrics,
    required this.lastUpdated,
  });

  factory DailyInsights.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyInsights(
      date: data['date'] ?? '',
      totalRuns: data['totalRuns'] ?? 0,
      totalMatches: data['totalMatches'] ?? 0,
      totalUsers: data['totalUsers'] ?? 0,
      averageScore: (data['averageScore'] ?? 0).toDouble(),
      totalCostUSD: (data['totalCostUSD'] ?? 0).toDouble(),
      userEngagementRate: (data['userEngagementRate'] ?? 0).toDouble(),
      conversionMetrics: ConversionMetrics.fromMap(data['conversionMetrics'] ?? {}),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }
}

class ConversionMetrics {
  final double matchesToConversations;
  final double conversationsToPremium;

  ConversionMetrics({
    required this.matchesToConversations,
    required this.conversationsToPremium,
  });

  factory ConversionMetrics.fromMap(Map<String, dynamic> data) {
    return ConversionMetrics(
      matchesToConversations: (data['matchesToConversations'] ?? 0).toDouble(),
      conversationsToPremium: (data['conversationsToPremium'] ?? 0).toDouble(),
    );
  }
}

// Filter models
class AnalyticsFilters {
  final DateTime? startDate;
  final DateTime? endDate;
  final int minScore;
  final int maxScore;
  final String? factorFilter;
  final String? runIdFilter;
  final String timeRange;

  AnalyticsFilters({
    this.startDate,
    this.endDate,
    this.minScore = 0,
    this.maxScore = 100,
    this.factorFilter,
    this.runIdFilter,
    this.timeRange = '24h',
  });

  AnalyticsFilters copyWith({
    DateTime? startDate,
    DateTime? endDate,
    int? minScore,
    int? maxScore,
    String? factorFilter,
    String? runIdFilter,
    String? timeRange,
  }) {
    return AnalyticsFilters(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minScore: minScore ?? this.minScore,
      maxScore: maxScore ?? this.maxScore,
      factorFilter: factorFilter ?? this.factorFilter,
      runIdFilter: runIdFilter ?? this.runIdFilter,
      timeRange: timeRange ?? this.timeRange,
    );
  }
}