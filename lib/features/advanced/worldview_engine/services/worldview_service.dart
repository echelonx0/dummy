import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

import '../../../../core/models/worldview_profile.dart';
import '../../../../core/models/worldview_question.dart';
import '../../../../core/models/worldview_response.dart';
import '../../worldview_assessment_engine.dart';

class WorldviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _generateProfileCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  Future<List<WorldviewQuestion>> getQuestionsForUser() async {
    return WorldviewQuestionsData.getRandomQuestions(10);
  }

  Future<void> saveResponse(WorldviewResponse response) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('worldview_profiles')
        .doc(userId)
        .collection('responses')
        .doc(response.questionId)
        .set(response.toMap());
  }

  Future<void> saveCompleteProfile(WorldviewProfile profile) async {
    await _firestore
        .collection('worldview_profiles')
        .doc(profile.userId)
        .set(profile.toMap());
  }

  Future<WorldviewProfile?> getUserProfile(String userId) async {
    final doc =
        await _firestore.collection('worldview_profiles').doc(userId).get();

    if (!doc.exists) return null;
    return WorldviewProfile.fromMap(doc.data()!);
  }

  Future<String> createNewProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final profileCode = _generateProfileCode();

    await _firestore.collection('worldview_profiles').doc(userId).set({
      'userId': userId,
      'profileCode': profileCode,
      'responses': [],
      'worldviewMap': {},
      'dealBreakerMap': {},
      'completedAt': null,
      'totalTimeSpentSeconds': 0,
      'isComplete': false,
      'politicalAlignment': 0.0,
      'socialAlignment': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return profileCode;
  }

  Future<void> completeProfile(
    String userId,
    List<WorldviewResponse> responses,
    int totalTimeSpent,
  ) async {
    final questions = WorldviewQuestionsData.getAllQuestions();
    final worldviewMap = <String, String>{};
    final dealBreakerMap = <String, String>{};

    for (final response in responses) {
      final question = questions.firstWhere((q) => q.id == response.questionId);
      worldviewMap[question.valuesDimension] = response.selectedWorldview;
      dealBreakerMap[question.valuesDimension] = question.dealBreakerLevel;
    }

    final existingProfile = await getUserProfile(userId);
    final profileCode = existingProfile?.profileCode ?? _generateProfileCode();

    // Calculate political and social alignment scores
    final alignmentScores = _calculateAlignmentScores(responses, questions);

    final profile = WorldviewProfile(
      userId: userId,
      profileCode: profileCode,
      responses: responses,
      worldviewMap: worldviewMap,
      dealBreakerMap: dealBreakerMap,
      completedAt: DateTime.now(),
      totalTimeSpentSeconds: totalTimeSpent,
      isComplete: true,
      politicalAlignment: alignmentScores['political']!,
      socialAlignment: alignmentScores['social']!,
    );

    await saveCompleteProfile(profile);
  }

  Map<String, double> _calculateAlignmentScores(
    List<WorldviewResponse> responses,
    List<WorldviewQuestion> questions,
  ) {
    double politicalScore = 0.0;
    double socialScore = 0.0;
    int politicalCount = 0;
    int socialCount = 0;

    // Define which dimensions contribute to political vs social alignment
    final politicalDimensions = {
      'government_role',
      'economic_philosophy',
      'environmental_priority',
      'responsibility_attribution',
      'international_engagement',
      'business_regulation',
    };

    final socialDimensions = {
      'social_change_pace',
      'cultural_approach',
      'family_values',
      'religion_public_role',
      'gender_philosophy',
      'tradition_vs_progress',
    };

    for (final response in responses) {
      final question = questions.firstWhere((q) => q.id == response.questionId);
      final isProgressiveChoice = _isProgressiveWorldview(
        response.selectedWorldview,
      );
      final scoreValue = isProgressiveChoice ? -1.0 : 1.0;

      if (politicalDimensions.contains(question.valuesDimension)) {
        politicalScore += scoreValue;
        politicalCount++;
      } else if (socialDimensions.contains(question.valuesDimension)) {
        socialScore += scoreValue;
        socialCount++;
      }
    }

    return {
      'political': politicalCount > 0 ? politicalScore / politicalCount : 0.0,
      'social': socialCount > 0 ? socialScore / socialCount : 0.0,
    };
  }

  bool _isProgressiveWorldview(String worldview) {
    final progressiveWorldviews = {
      'Government Intervention Advocate',
      'Economic Equality Advocate',
      'Climate Emergency Activist',
      'Revolutionary Progressive',
      'Systemic Responsibility Advocate',
      'Multiculturalism Champion',
      'Privacy Rights Defender',
      'Critical Education Advocate',
      'Restorative Justice Advocate',
      'Family Diversity Celebrant',
      'Secular Governance Advocate',
      'Global Humanitarian Interventionist',
      'Systemic Advantage Recognizer',
      'Progressive Reform Advocate',
      'Social Safety Net Supporter',
      'Fair Competition Regulator',
      'Anti-Gentrification Activist',
      'Information Quality Controller',
      'Gender Identity Affirmer',
      'Transformational Risk Taker',
    };

    return progressiveWorldviews.contains(worldview);
  }

  // For matching algorithm - find users with opposite worldviews but similar core values
  Future<List<Map<String, dynamic>>> findUnlikelyMatches(String userId) async {
    final userProfile = await getUserProfile(userId);
    if (userProfile == null || !userProfile.isComplete) return [];

    final querySnapshot =
        await _firestore
            .collection('worldview_profiles')
            .where('isComplete', isEqualTo: true)
            .where('userId', isNotEqualTo: userId)
            .get();

    final unlikelyMatches = <Map<String, dynamic>>[];

    for (final doc in querySnapshot.docs) {
      final otherProfile = WorldviewProfile.fromMap(doc.data());
      final matchAnalysis = _analyzeUnlikelyMatch(userProfile, otherProfile);

      if (matchAnalysis['isUnlikelyMatch'] == true) {
        unlikelyMatches.add({
          'profile': otherProfile,
          'oppositeScore': matchAnalysis['oppositeScore'],
          'dealBreakerScore': matchAnalysis['dealBreakerScore'],
          'bridgeableGaps': matchAnalysis['bridgeableGaps'],
          'majorConflicts': matchAnalysis['majorConflicts'],
          'politicalGap': matchAnalysis['politicalGap'],
          'socialGap': matchAnalysis['socialGap'],
        });
      }
    }

    // Sort by highest "unlikely but potentially workable" score
    unlikelyMatches.sort((a, b) {
      final scoreA =
          (a['oppositeScore'] as double) - (a['dealBreakerScore'] as double);
      final scoreB =
          (b['oppositeScore'] as double) - (b['dealBreakerScore'] as double);
      return scoreB.compareTo(scoreA);
    });

    return unlikelyMatches
        .take(20)
        .toList(); // Limit to top 20 unlikely matches
  }

  Map<String, dynamic> _analyzeUnlikelyMatch(
    WorldviewProfile user,
    WorldviewProfile other,
  ) {
    final userViews = user.worldviewMap;
    final otherViews = other.worldviewMap;

    int totalOpposites = 0;
    int highDealBreakers = 0;
    final bridgeableGaps = <String>[];
    final majorConflicts = <String>[];

    for (final dimension in userViews.keys) {
      if (otherViews.containsKey(dimension)) {
        final areOpposite = _areOppositeWorldviews(
          userViews[dimension]!,
          otherViews[dimension]!,
        );

        if (areOpposite) {
          totalOpposites++;
          final dealBreakerLevel = user.dealBreakerMap[dimension] ?? 'low';

          if (dealBreakerLevel == 'high') {
            highDealBreakers++;
            majorConflicts.add(dimension);
          } else {
            // Medium and low deal breakers are both bridgeable
            bridgeableGaps.add(dimension);
          }
        }
      }
    }

    final totalDimensions = userViews.length;
    final oppositeScore =
        totalDimensions > 0 ? totalOpposites / totalDimensions : 0.0;
    final dealBreakerScore =
        totalOpposites > 0 ? highDealBreakers / totalOpposites : 0.0;

    // Calculate political and social gaps
    final politicalGap =
        (user.politicalAlignment - other.politicalAlignment).abs();
    final socialGap = (user.socialAlignment - other.socialAlignment).abs();

    // Unlikely match criteria:
    // 1. At least 40% opposite views
    // 2. No more than 2 high deal breakers
    // 3. At least some bridgeable gaps
    final isUnlikelyMatch =
        oppositeScore >= 0.4 &&
        highDealBreakers <= 2 &&
        bridgeableGaps.isNotEmpty;

    return {
      'isUnlikelyMatch': isUnlikelyMatch,
      'oppositeScore': oppositeScore,
      'dealBreakerScore': dealBreakerScore,
      'bridgeableGaps': bridgeableGaps,
      'majorConflicts': majorConflicts,
      'politicalGap': politicalGap,
      'socialGap': socialGap,
    };
  }

  bool _areOppositeWorldviews(String worldviewA, String worldviewB) {
    final oppositeViewPairs = {
      'Government Intervention Advocate': 'Free Market Believer',
      'Economic Equality Advocate': 'Meritocracy Defender',
      'Climate Emergency Activist': 'Balanced Transition Advocate',
      'Revolutionary Progressive': 'Evolutionary Conservative',
      'Systemic Responsibility Advocate': 'Individual Accountability Believer',
      'Multiculturalism Champion': 'Cultural Integration Advocate',
      'Privacy Rights Defender': 'Security First Pragmatist',
      'Critical Education Advocate': 'Traditional Learning Supporter',
      'Restorative Justice Advocate': 'Law and Order Supporter',
      'Family Diversity Celebrant': 'Traditional Family Supporter',
      'Secular Governance Advocate': 'Faith-Informed Civic Life Supporter',
      'Global Humanitarian Interventionist': 'National Interest Prioritizer',
      'Systemic Advantage Recognizer': 'Personal Agency Emphasizer',
      'Progressive Reform Advocate': 'Traditional Institution Preserver',
      'Social Safety Net Supporter': 'Self-Reliance Advocate',
      'Market Innovation Supporter': 'Fair Competition Regulator',
      'Anti-Gentrification Activist': 'Development Progress Supporter',
      'Information Quality Controller': 'Free Speech Absolutist',
      'Gender Identity Affirmer': 'Biological Reality Acknowledger',
      'Transformational Risk Taker': 'Cautious Incrementalist',
    };

    return oppositeViewPairs[worldviewA] == worldviewB ||
        oppositeViewPairs[worldviewB] == worldviewA;
  }
}
