// lib/features/psychological_profile/services/psychology_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

import '../../../../core/models/psych_profile.dart';
import '../../../../core/models/psych_question.dart';
import '../../../../core/models/psych_response.dart';
import '../psych_profile_engine.dart';

class PsychologyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _generateProfileCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  Future<List<PsychologyQuestion>> getQuestionsForUser() async {
    return PsychologyQuestionsData.getRandomQuestions(10);
  }

  Future<void> saveResponse(PsychologyResponse response) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('psychological_profiles')
        .doc(userId)
        .collection('responses')
        .doc(response.questionId)
        .set(response.toMap());
  }

  Future<void> saveCompleteProfile(PsychologyProfile profile) async {
    await _firestore
        .collection('psychological_profiles')
        .doc(profile.userId)
        .set(profile.toMap());
  }

  Future<PsychologyProfile?> getUserProfile(String userId) async {
    final doc =
        await _firestore.collection('psychological_profiles').doc(userId).get();

    if (!doc.exists) return null;
    return PsychologyProfile.fromMap(doc.data()!);
  }

  Future<String> createNewProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final profileCode = _generateProfileCode();

    // Create initial profile document
    await _firestore.collection('psychological_profiles').doc(userId).set({
      'userId': userId,
      'profileCode': profileCode,
      'responses': [],
      'principleMap': {},
      'completedAt': null,
      'totalTimeSpentSeconds': 0,
      'isComplete': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return profileCode;
  }

  Future<void> completeProfile(
    String userId,
    List<PsychologyResponse> responses,
    int totalTimeSpent,
  ) async {
    // Generate principle map from responses
    final questions = PsychologyQuestionsData.getAllQuestions();
    final principleMap = <String, String>{};

    for (final response in responses) {
      final question = questions.firstWhere((q) => q.id == response.questionId);
      principleMap[question.psychologicalDimension] =
          response.selectedPrinciple;
    }

    final existingProfile = await getUserProfile(userId);
    final profileCode = existingProfile?.profileCode ?? _generateProfileCode();

    final profile = PsychologyProfile(
      userId: userId,
      profileCode: profileCode,
      responses: responses,
      principleMap: principleMap,
      completedAt: DateTime.now(),
      totalTimeSpentSeconds: totalTimeSpent,
      isComplete: true,
    );

    await saveCompleteProfile(profile);
  }

  // For matching algorithm - find users with opposite principles
  Future<List<Map<String, dynamic>>> findOppositeMatches(String userId) async {
    final userProfile = await getUserProfile(userId);
    if (userProfile == null || !userProfile.isComplete) return [];

    // Query for profiles with opposite principles
    final querySnapshot =
        await _firestore
            .collection('psychological_profiles')
            .where('isComplete', isEqualTo: true)
            .where('userId', isNotEqualTo: userId)
            .get();

    final oppositeMatches = <Map<String, dynamic>>[];

    for (final doc in querySnapshot.docs) {
      final otherProfile = PsychologyProfile.fromMap(doc.data());
      final oppositeScore = _calculateOppositeScore(userProfile, otherProfile);

      if (oppositeScore > 0.6) {
        // 60% opposite threshold
        oppositeMatches.add({
          'profile': otherProfile,
          'oppositeScore': oppositeScore,
          'sharedDimensions': _getSharedDimensions(userProfile, otherProfile),
        });
      }
    }

    // Sort by opposite score (highest first)
    oppositeMatches.sort(
      (a, b) => (b['oppositeScore'] as double).compareTo(
        a['oppositeScore'] as double,
      ),
    );

    return oppositeMatches;
  }

  double _calculateOppositeScore(
    PsychologyProfile user,
    PsychologyProfile other,
  ) {
    final userPrinciples = user.principleMap;
    final otherPrinciples = other.principleMap;

    int oppositeCount = 0;
    int totalDimensions = 0;

    for (final dimension in userPrinciples.keys) {
      if (otherPrinciples.containsKey(dimension)) {
        totalDimensions++;
        if (_areOpposite(
          userPrinciples[dimension]!,
          otherPrinciples[dimension]!,
        )) {
          oppositeCount++;
        }
      }
    }

    return totalDimensions > 0 ? oppositeCount / totalDimensions : 0.0;
  }

  bool _areOpposite(String principleA, String principleB) {
    // Define opposite principle pairs
    final oppositePairs = {
      'Action-Oriented Problem Solver': 'Emotional Support Provider',
      'Security-First Planner': 'Experience-Driven Risk Taker',
      'Direct Communicator': 'Adaptive Accommodator',
      'Social Energizer': 'Solitary Recharger',
      'Ambition-Driven Achiever': 'Balance-Focused Harmonizer',
      'Dialogue Seeker': 'Harmony Preserver',
      'Sanctuary Seeker': 'Experience Maximizer',
      'Caretaking Supporter': 'Boundary Setting Protector',
      'Spontaneous Adventurer': 'Strategic Planner',
      'Intuitive Flow Follower': 'Deliberate Pace Setter',
      'Logic-Driven Decider': 'Emotion-Guided Chooser',
      'Inclusive Caretaker': 'Authentic Engager',
      'Change Embracer': 'Stability Seeker',
      'Collaborative Team Builder': 'Individual Achievement Focuser',
      'Open Vulnerability Sharer': 'Private Strength Maintainer',
      'Structured Learning Seeker': 'Independent Explorer',
      'Goal-Oriented Planner': 'Adaptive Growth Focuser',
      'Direct Truth Teller': 'Diplomatic Influencer',
      'Stimulation Seeker': 'Restoration Prioritizer',
      'Principled Action Taker': 'Pragmatic Value Balancer',
    };

    // Check if principles are opposites (bidirectional)
    return oppositePairs[principleA] == principleB ||
        oppositePairs[principleB] == principleA;
  }

  List<String> _getSharedDimensions(
    PsychologyProfile user,
    PsychologyProfile other,
  ) {
    final sharedDimensions = <String>[];

    for (final dimension in user.principleMap.keys) {
      if (other.principleMap.containsKey(dimension)) {
        sharedDimensions.add(dimension);
      }
    }

    return sharedDimensions;
  }
}
