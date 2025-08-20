// lib/features/admin/services/match_analytics_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match_analytics_models.dart';

class MatchAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Real-time stream of match engine runs
  Stream<List<MatchEngineRun>> getMatchEngineRuns({
    int limit = 10,
    String? timeRange,
  }) {
    Query query = _firestore.collection('matchEngineRuns')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (timeRange != null) {
      final DateTime cutoff = _getCutoffDate(timeRange);
      query = query.where('timestamp', isGreaterThan: cutoff);
    }

    return query.snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => MatchEngineRun.fromFirestore(doc)).toList()
    );
  }

  // Real-time stream of individual match analytics
  Stream<List<MatchAnalytic>> getMatchAnalytics({
    int limit = 50,
    AnalyticsFilters? filters,
  }) {
    Query query = _firestore.collection('matchAnalytics')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (filters != null) {
      if (filters.startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: filters.startDate);
      }
      if (filters.endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: filters.endDate);
      }
      if (filters.runIdFilter != null) {
        query = query.where('runId', isEqualTo: filters.runIdFilter);
      }
    }

    return query.snapshots().map((snapshot) {
      final matches = snapshot.docs
          .map((doc) => MatchAnalytic.fromFirestore(doc))
          .toList();

      // Apply client-side filters (Firestore limitations)
      if (filters != null) {
        return matches.where((match) {
          if (match.compatibilityScore < filters.minScore || 
              match.compatibilityScore > filters.maxScore) {
            return false;
          }
          
          if (filters.factorFilter != null && filters.factorFilter != 'all') {
            final hasMatchingFactor = match.compatibilityFactors
                .any((factor) => factor.factor == filters.factorFilter);
            if (!hasMatchingFactor) return false;
          }
          
          return true;
        }).toList();
      }

      return matches;
    });
  }

  // Get daily insights stream
  Stream<List<DailyInsights>> getDailyInsights({int days = 7}) {
    final DateTime cutoff = DateTime.now().subtract(Duration(days: days));
    
    return _firestore.collection('matchEngineInsights')
        .where('lastUpdated', isGreaterThan: cutoff)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) =>
          snapshot.docs.map((doc) => DailyInsights.fromFirestore(doc)).toList()
        );
  }

  // Get aggregated metrics for dashboard cards
  Stream<AggregatedMetrics> getAggregatedMetrics(String timeRange) {
    return getMatchEngineRuns(timeRange: timeRange).map((runs) {
      if (runs.isEmpty) {
        return AggregatedMetrics.empty();
      }

      final totalMatches = runs.fold<int>(
        0, (sum, run) => sum + run.metrics.matchesGenerated
      );
      
      final avgScore = runs.fold<double>(
        0, (sum, run) => sum + run.qualityMetrics.averageCompatibilityScore
      ) / runs.length;
      
      final totalCost = runs.fold<double>(
        0, (sum, run) => sum + run.costMetrics.estimatedCostUSD
      );
      
      final avgSuccessRate = runs.fold<double>(
        0, (sum, run) => sum + run.metrics.successRate
      ) / runs.length;

      final lastRun = runs.first;
      
      return AggregatedMetrics(
        totalMatches: totalMatches,
        averageScore: avgScore,
        totalCost: totalCost,
        successRate: avgSuccessRate,
        lastRunTimestamp: lastRun.timestamp,
        totalRuns: runs.length,
        totalUsers: runs.fold<int>(
          0, (sum, run) => sum + run.metrics.usersProcessed
        ),
      );
    });
  }

  // Get score distribution for charts
  Stream<Map<String, int>> getScoreDistribution(String timeRange) {
    return getMatchEngineRuns(timeRange: timeRange).map((runs) {
      if (runs.isEmpty) return <String, int>{};
      
      // Aggregate score distributions from all runs
      final Map<String, int> aggregated = {};
      for (final run in runs) {
        run.qualityMetrics.scoreDistribution.forEach((range, count) {
          aggregated[range] = (aggregated[range] ?? 0) + count;
        });
      }
      
      return aggregated;
    });
  }

  // Get top compatibility factors
  Stream<List<CompatibilityFactor>> getTopCompatibilityFactors(String timeRange) {
    return getMatchEngineRuns(timeRange: timeRange).map((runs) {
      if (runs.isEmpty) return <CompatibilityFactor>[];
      
      // Aggregate factors from all runs
      final Map<String, FactorAggregation> factorStats = {};
      
      for (final run in runs) {
        for (final factor in run.qualityMetrics.topCompatibilityFactors) {
          if (!factorStats.containsKey(factor.factor)) {
            factorStats[factor.factor] = FactorAggregation();
          }
          factorStats[factor.factor]!.addScore(factor.avgScore, factor.frequency);
        }
      }
      
      // Convert to sorted list
      return factorStats.entries
          .map((entry) => CompatibilityFactor(
            factor: entry.key,
            avgScore: entry.value.averageScore,
            frequency: entry.value.totalFrequency,
          ))
          .toList()
        ..sort((a, b) => b.avgScore.compareTo(a.avgScore));
    });
  }

  // Export data to CSV format
  Future<String> exportMatchAnalytics({
    AnalyticsFilters? filters,
    int limit = 1000,
  }) async {
    final matches = await getMatchAnalytics(filters: filters, limit: limit).first;
    
    final csvLines = <String>[];
    
    // CSV Header
    csvLines.add('Match ID,Run ID,User A,User B,Score,Top Factor,Processing Time (s),Timestamp');
    
    // CSV Data
    for (final match in matches) {
      final topFactor = match.topFactors.isNotEmpty 
          ? '${match.topFactors.first.factor} (${match.topFactors.first.score.toStringAsFixed(1)})'
          : 'N/A';
          
      csvLines.add([
        match.id,
        match.runId,
        match.userAId,
        match.userBId,
        match.compatibilityScore.toString(),
        topFactor,
        match.processingTimeSeconds.toStringAsFixed(2),
        match.timestamp.toIso8601String(),
      ].join(','));
    }
    
    return csvLines.join('\n');
  }

  // Helper method to get cutoff date based on time range
  DateTime _getCutoffDate(String timeRange) {
    final now = DateTime.now();
    switch (timeRange) {
      case '1h':
        return now.subtract(const Duration(hours: 1));
      case '24h':
        return now.subtract(const Duration(hours: 24));
      case '7d':
        return now.subtract(const Duration(days: 7));
      case '30d':
        return now.subtract(const Duration(days: 30));
      default:
        return now.subtract(const Duration(hours: 24));
    }
  }
}

// Helper class for aggregating compatibility factors
class FactorAggregation {
  double totalScore = 0;
  int totalFrequency = 0;
  int count = 0;

  void addScore(double score, int frequency) {
    totalScore += score * frequency;
    totalFrequency += frequency;
    count++;
  }

  double get averageScore => totalFrequency > 0 ? totalScore / totalFrequency : 0;
}

// Aggregated metrics for dashboard cards
class AggregatedMetrics {
  final int totalMatches;
  final double averageScore;
  final double totalCost;
  final double successRate;
  final DateTime lastRunTimestamp;
  final int totalRuns;
  final int totalUsers;

  AggregatedMetrics({
    required this.totalMatches,
    required this.averageScore,
    required this.totalCost,
    required this.successRate,
    required this.lastRunTimestamp,
    required this.totalRuns,
    required this.totalUsers,
  });

  factory AggregatedMetrics.empty() {
    return AggregatedMetrics(
      totalMatches: 0,
      averageScore: 0,
      totalCost: 0,
      successRate: 0,
      lastRunTimestamp: DateTime.now(),
      totalRuns: 0,
      totalUsers: 0,
    );
  }

  String get formattedCost => '\$${totalCost.toStringAsFixed(2)}';
  String get formattedScore => '${averageScore.toStringAsFixed(1)}%';
  String get formattedSuccessRate => '${successRate.toStringAsFixed(1)}%';
}