// lib/features/courtship/services/courtship_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart';
import '../../../app/locator.dart';
import '../models/courtship_models.dart';

class CourtshipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final AuthService _authService = locator<AuthService>();

  String? get currentUserId => _authService.getCurrentUser()?.uid;

  // ============================================================================
  // COURTSHIP STATUS & MANAGEMENT
  // ============================================================================

  /// Get current user's courtship status - FIXED METHOD SIGNATURE
  Future<UserCourtshipStatus?> getUserCourtshipStatus(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) return null;

      final data = userDoc.data() as Map<String, dynamic>;
      final courtshipStatus = data['courtshipStatus'] as Map<String, dynamic>?;

      if (courtshipStatus == null) return null;

      return UserCourtshipStatus.fromFirestore(courtshipStatus);
    } catch (e) {
      throw Exception('Failed to get courtship status: $e');
    }
  }

  /// Check if user is available for courtship
  Future<bool> isUserAvailableForCourtship([String? userId]) async {
    final targetUserId = userId ?? currentUserId;
    if (targetUserId == null) return false;

    try {
      final userDoc =
          await _firestore.collection('users').doc(targetUserId).get();

      if (!userDoc.exists) return false;

      final data = userDoc.data() as Map<String, dynamic>;
      final courtshipStatus = data['courtshipStatus'] as Map<String, dynamic>?;

      if (courtshipStatus == null) return true;

      final isInCourtship = courtshipStatus['isInCourtship'] as bool? ?? false;
      final availableDate = courtshipStatus['availableDate'] as Timestamp?;

      if (isInCourtship) return false;
      if (availableDate != null &&
          availableDate.toDate().isAfter(DateTime.now())) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get active courtship for current user
  Future<Courtship?> getActiveCourtship() async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final querySnapshot =
          await _firestore
              .collection('courtships')
              .where('participants', arrayContains: currentUserId)
              .where('status', whereIn: ['active', 'pending'])
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) return null;

      return Courtship.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to get active courtship: $e');
    }
  }

  /// Get courtship by ID - ADDED MISSING METHOD
  Future<Courtship?> getCourtship(String courtshipId) async {
    try {
      final doc =
          await _firestore.collection('courtships').doc(courtshipId).get();
      if (!doc.exists) return null;
      return Courtship.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get courtship: $e');
    }
  }

  // ============================================================================
  // COURTSHIP INITIATION & MANAGEMENT
  // ============================================================================

  /// Initiate a new courtship with another user - FIXED METHOD SIGNATURE
  Future<String> initiateCourtship(
    String currentUserId,
    String targetUserId,
  ) async {
    try {
      // Check availability of both users
      final currentUserAvailable = await isUserAvailableForCourtship(
        currentUserId,
      );
      final targetUserAvailable = await isUserAvailableForCourtship(
        targetUserId,
      );

      if (!currentUserAvailable) {
        throw Exception('You are not available for courtship');
      }
      if (!targetUserAvailable) {
        throw Exception('Target user is not available for courtship');
      }

      // Generate courtship ID
      final courtshipId = _generateCourtshipId();

      // Create courtship document
      final courtshipData = Courtship(
        id: courtshipId,
        participants: [currentUserId, targetUserId],
        status: CourtshipStatus.pending,
        stage: CourtshipStage.commitment,
        startDate: DateTime.now(),
        currentDay: 0,
        maxDays: 14,
        commitments: {
          currentUserId: CourtshipCommitment(
            committed: true,
            timestamp: DateTime.now(),
            acknowledged: false,
          ),
          targetUserId: CourtshipCommitment(
            committed: false,
            timestamp: null,
            acknowledged: false,
          ),
        },
        stageHistory: [
          CourtshipStageHistory(
            stage: CourtshipStage.commitment.name,
            startDate: DateTime.now(),
            completed: false,
          ),
        ],
        interactions: [],
      );

      // Save courtship to Firestore
      await _firestore
          .collection('courtships')
          .doc(courtshipId)
          .set(courtshipData.toFirestore());

      // Update current user's status
      await _updateUserCourtshipStatus(currentUserId, {
        'isInCourtship': true,
        'currentCourtshipId': courtshipId,
      });

      // TODO: Send notification to target user
      await _sendCourtshipInvitationNotification(targetUserId, courtshipId);

      return courtshipId;
    } catch (e) {
      throw Exception('Failed to initiate courtship: $e');
    }
  }

  /// Respond to a courtship invitation - FIXED METHOD SIGNATURE
  Future<bool> respondToCourtshipCommitment(
    String userId,
    String courtshipId,
    bool accept,
  ) async {
    try {
      final courtshipRef = _firestore.collection('courtships').doc(courtshipId);
      final courtshipDoc = await courtshipRef.get();

      if (!courtshipDoc.exists) {
        throw Exception('Courtship not found');
      }

      final courtship = Courtship.fromFirestore(courtshipDoc);

      if (!courtship.participants.contains(userId)) {
        throw Exception('You are not a participant in this courtship');
      }

      if (accept) {
        // Accept the courtship
        await courtshipRef.update({
          'commitments.$userId.committed': true,
          'commitments.$userId.timestamp': Timestamp.now(),
          'status': CourtshipStatus.active.name,
          'stage': CourtshipStage.introduction.name,
          'currentDay': 1,
          'stageHistory': FieldValue.arrayUnion([
            {
              'stage': CourtshipStage.introduction.name,
              'startDate': Timestamp.now(),
              'completed': false,
            },
          ]),
        });

        // Update user status
        await _updateUserCourtshipStatus(userId, {
          'isInCourtship': true,
          'currentCourtshipId': courtshipId,
        });

        // Start first AI interaction
        await _initiateStageInteraction(courtshipId, 1);

        return true;
      } else {
        // Decline the courtship
        await courtshipRef.update({
          'status': CourtshipStatus.declined.name,
          'commitments.$userId.committed': false,
          'commitments.$userId.timestamp': Timestamp.now(),
        });

        // Free both users
        final otherUserId = courtship.participants.firstWhere(
          (id) => id != userId,
        );
        await _updateUserCourtshipStatus(otherUserId, {
          'isInCourtship': false,
          'currentCourtshipId': null,
        });

        return false;
      }
    } catch (e) {
      throw Exception('Failed to respond to courtship: $e');
    }
  }

  /// Submit interaction response - ADDED MISSING METHOD
  Future<void> submitInteractionResponse(
    String userId,
    String courtshipId,
    int day,
    String response,
  ) async {
    try {
      final courtshipRef = _firestore.collection('courtships').doc(courtshipId);
      final courtshipDoc = await courtshipRef.get();

      if (!courtshipDoc.exists) {
        throw Exception('Courtship not found');
      }

      final courtship = Courtship.fromFirestore(courtshipDoc);
      final interactionIndex = courtship.interactions.indexWhere(
        (i) => i.day == day,
      );

      if (interactionIndex == -1) {
        throw Exception('No interaction found for day $day');
      }

      // Update the interaction with user response
      final updatedInteractions = List<CourtshipInteraction>.from(
        courtship.interactions,
      );
      final interaction = updatedInteractions[interactionIndex];

      final updatedResponses = Map<String, UserResponse>.from(
        interaction.userResponses,
      );
      updatedResponses[userId] = UserResponse(
        response: response,
        timestamp: DateTime.now(),
        engagement: _assessEngagement(response),
      );

      updatedInteractions[interactionIndex] = CourtshipInteraction(
        day: interaction.day,
        stage: interaction.stage,
        aiPrompt: interaction.aiPrompt,
        userResponses: updatedResponses,
        aiFollowUp: interaction.aiFollowUp,
        completed: interaction.completed,
        nextAction: interaction.nextAction,
        timestamp: interaction.timestamp,
      );

      // Update Firestore
      await courtshipRef.update({
        'interactions': updatedInteractions.map((i) => i.toMap()).toList(),
      });

      // Check if both users have responded and handle next steps
      final otherUserId = courtship.participants.firstWhere(
        (id) => id != userId,
      );
      if (updatedResponses.containsKey(otherUserId)) {
        // Both responded - could trigger next day or AI follow-up
        await _handleBothUsersResponded(courtshipId, day);
      }
    } catch (e) {
      throw Exception('Failed to submit interaction response: $e');
    }
  }

  /// Request respectful exit - ADDED MISSING METHOD
  Future<void> requestRespectfulExit(
    String userId,
    String courtshipId,
    String reason,
  ) async {
    try {
      final courtshipRef = _firestore.collection('courtships').doc(courtshipId);
      final courtshipDoc = await courtshipRef.get();

      if (!courtshipDoc.exists) {
        throw Exception('Courtship not found');
      }

      final courtship = Courtship.fromFirestore(courtshipDoc);

      // Update courtship with exit request
      await courtshipRef.update({
        'exitRequest': {
          'requestedBy': userId,
          'reason': reason,
          'timestamp': Timestamp.now(),
          'type': 'respectful',
          'acknowledged': false,
        },
        'status': CourtshipStatus.completed.name,
      });

      // Free both users (respectful exit = no penalty)
      for (final participantId in courtship.participants) {
        await _updateUserCourtshipStatus(participantId, {
          'isInCourtship': false,
          'currentCourtshipId': null,
          'availableDate': Timestamp.now(), // Immediately available
        });
      }

      // TODO: Send notification to other participant
      final otherUserId = courtship.participants.firstWhere(
        (id) => id != userId,
      );
      await _sendCourtshipExitNotification(otherUserId, courtshipId, reason);
    } catch (e) {
      throw Exception('Failed to exit courtship: $e');
    }
  }

  /// Submit courtship feedback - ADDED MISSING METHOD
  Future<void> submitCourtshipFeedback(
    String userId,
    String courtshipId,
    CourtshipFeedback feedback,
  ) async {
    try {
      // Save feedback to courtship document
      await _firestore.collection('courtships').doc(courtshipId).update({
        'feedback.$userId': feedback.toMap(),
      });

      // Update the other participant's trust score
      final courtshipDoc =
          await _firestore.collection('courtships').doc(courtshipId).get();
      if (courtshipDoc.exists) {
        final courtship = Courtship.fromFirestore(courtshipDoc);
        final otherUserId = courtship.participants.firstWhere(
          (id) => id != userId,
        );

        await _updateTrustScoreFromFeedback(otherUserId, feedback);
      }
    } catch (e) {
      throw Exception('Failed to submit feedback: $e');
    }
  }

  // ============================================================================
  // MATCH RECOMMENDATIONS
  // ============================================================================

  /// Get match recommendations for current user - FIXED METHOD SIGNATURE
  Future<List<MatchRecommendation>> getMatchRecommendations(
    String userId,
  ) async {
    try {
      final recommendationsSnapshot =
          await _firestore
              .collection('profiles')
              .doc(userId)
              .collection('matchRecommendations')
              .orderBy('score', descending: true)
              .limit(10)
              .get();

      final recommendations = <MatchRecommendation>[];

      for (final doc in recommendationsSnapshot.docs) {
        final data = doc.data();
        final matchUserId = doc.id;

        // Get the match user's profile
        final profileDoc =
            await _firestore.collection('profiles').doc(matchUserId).get();

        if (profileDoc.exists) {
          final profileData = profileDoc.data() as Map<String, dynamic>;

          recommendations.add(
            MatchRecommendation(
              userId: matchUserId,
              name: profileData['displayName'] ?? 'Unknown',
              age: _calculateAge(profileData['dateOfBirth']),
              city: profileData['cityOfResidence'] ?? '',
              photos: [
                profileData['profileImage'] ?? '',
              ], // Fixed: expects List<String>
              compatibilityScore: (data['score'] as num).toDouble(),
              sharedValues: List<String>.from(profileData['coreValues'] ?? []),
              attachmentStyle: profileData['attachmentStyle'],
              matchedAt: (data['matchedAt'] as Timestamp).toDate(),
              trustScore: null, // Will be populated based on premium access
            ),
          );
        }
      }

      return recommendations;
    } catch (e) {
      throw Exception('Failed to get match recommendations: $e');
    }
  }

  // ============================================================================
  // TRUST SCORE & RATINGS
  // ============================================================================

  /// Get user's trust score - FIXED METHOD SIGNATURE
  Future<TrustScore> getUserTrustScore(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final data = userDoc.data() as Map<String, dynamic>;
      final trustScoreData = data['trustScore'] as Map<String, dynamic>?;

      if (trustScoreData == null) {
        // Return default trust score for new users
        return TrustScore(
          overallScore: 75.0, // Default for new users
          completionRate: 0.0,
          averageRating: 0.0,
          responseTime: 0.0,
          authenticityScore: 50.0,
          communityContribution: 0.0,
          trend: 'stable',
          lastUpdated: DateTime.now(),
        );
      }

      return TrustScore.fromMap(trustScoreData);
    } catch (e) {
      throw Exception('Failed to get trust score: $e');
    }
  }

  /// Check if user has premium trust access - ADDED MISSING METHOD
  Future<bool> hasPremiumTrustAccess(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return false;

      final data = userDoc.data() as Map<String, dynamic>;
      return data['premiumTrustAccess'] as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  // ============================================================================
  // AI INTERACTIONS (SIMPLIFIED FOR MVP)
  // ============================================================================

  /// Initiate stage interaction (template-based for MVP)
  Future<void> _initiateStageInteraction(String courtshipId, int day) async {
    try {
      final template = _getPromptTemplate(day);
      if (template == null) return;

      // Get user profiles for personalization
      final courtshipDoc =
          await _firestore.collection('courtships').doc(courtshipId).get();
      if (!courtshipDoc.exists) return;

      final courtship = Courtship.fromFirestore(courtshipDoc);
      final personalizedPrompt = await _personalizePrompt(
        template,
        courtship.participants,
      );

      // Create interaction record
      final interaction = CourtshipInteraction(
        day: day,
        stage: _getStageForDay(day).name,
        aiPrompt: personalizedPrompt,
        userResponses: {},
        completed: false,
        nextAction: 'awaiting_responses',
        timestamp: DateTime.now(),
      );

      // Update courtship with new interaction
      await _firestore.collection('courtships').doc(courtshipId).update({
        'interactions': FieldValue.arrayUnion([interaction.toMap()]),
        'currentDay': day,
      });

      // TODO: Send notifications to both participants
    } catch (e) {
      print('Error initiating stage interaction: $e');
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  String _generateCourtshipId() {
    return 'courtship_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  Future<void> _updateUserCourtshipStatus(
    String userId,
    Map<String, dynamic> status,
  ) async {
    await _firestore.collection('users').doc(userId).update({
      'courtshipStatus': status,
    });
  }

  int _calculateAge(dynamic dateOfBirth) {
    if (dateOfBirth == null) return 0;

    DateTime birthDate;
    if (dateOfBirth is Timestamp) {
      birthDate = dateOfBirth.toDate();
    } else if (dateOfBirth is DateTime) {
      birthDate = dateOfBirth;
    } else {
      return 0;
    }

    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  CourtshipStage _getStageForDay(int day) {
    if (day <= 3) return CourtshipStage.introduction;
    if (day <= 7) return CourtshipStage.compatibility;
    if (day <= 11) return CourtshipStage.discovery;
    return CourtshipStage.decision;
  }

  String? _getPromptTemplate(int day) {
    // Simplified template system for MVP
    final templates = {
      1: "I'd like to introduce you both by sharing what I learned about your core values. Let's start by sharing what's one life experience that shaped your most important value?",
      2: "Yesterday's conversation about formative experiences was beautiful. Today, I'd like to explore how you both approach life's bigger questions.",
      3: "We're completing our introduction phase. What's one thing that's surprised you positively about getting to know each other?",
      4: "Welcome to our compatibility exploration phase. Let's get practical about daily life compatibility.",
      5: "Based on our conversations, I'm seeing how you both express care and appreciation.",
      6: "Let's explore lifestyle compatibility and how you balance different priorities.",
      7: "You've built a beautiful foundation of understanding. Now it's time to plan your first in-person meeting!",
      8: "It's time for your first meeting! Let's coordinate the perfect date.",
      9: "Your date is coming up! Let's prepare for this exciting milestone.",
      10:
          "Welcome back! I hope your first meeting was wonderful. Let's reflect on how it went.",
      11:
          "Now that you've met in person, let's explore how you both envision your futures.",
      12:
          "We're entering our final phase together. Let's talk about relationship readiness.",
      13: "Today I want to help you both express your genuine interest level.",
      14:
          "This is our final day together. Time to make a clear decision about next steps.",
    };

    return templates[day];
  }

  Future<String> _personalizePrompt(
    String template,
    List<String> participants,
  ) async {
    // For MVP, return template as-is
    // In future, we'll replace placeholders with actual user data
    return template;
  }

  String _assessEngagement(String response) {
    // Simple engagement assessment based on response length and content
    if (response.length < 50) return 'low';
    if (response.length > 200) return 'high';
    return 'medium';
  }

  Future<void> _handleBothUsersResponded(String courtshipId, int day) async {
    // TODO: Implement logic for when both users respond
    // Could trigger AI follow-up or next day's interaction
    print('Both users responded to day $day');
  }

  Future<void> _updateTrustScoreFromFeedback(
    String userId,
    CourtshipFeedback feedback,
  ) async {
    // Simplified trust score update for MVP
    try {
      final userRef = _firestore.collection('users').doc(userId);

      // Get current trust score
      final userDoc = await userRef.get();
      final currentTrustScore =
          userDoc.data()?['trustScore'] as Map<String, dynamic>?;

      double currentScore = currentTrustScore?['overallScore'] ?? 75.0;
      double averageRating = currentTrustScore?['averageRating'] ?? 0.0;
      int ratingCount = currentTrustScore?['ratingCount'] ?? 0;

      // Calculate new average rating using feedback
      double newAverageRating =
          ((averageRating * ratingCount) + feedback.averageRating) /
          (ratingCount + 1);

      // Simple trust score calculation (can be enhanced later)
      double newTrustScore =
          (currentScore * 0.8) +
          (newAverageRating * 4.0); // Scale 5-star to 20 points

      await userRef.update({
        'trustScore.overallScore': newTrustScore.clamp(0.0, 100.0),
        'trustScore.averageRating': newAverageRating,
        'trustScore.ratingCount': ratingCount + 1,
        'trustScore.lastUpdated': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating trust score: $e');
    }
  }

  // ============================================================================
  // NOTIFICATION PLACEHOLDERS (TO BE IMPLEMENTED)
  // ============================================================================

  Future<void> _sendCourtshipInvitationNotification(
    String userId,
    String courtshipId,
  ) async {
    // TODO: Implement push notification
    print('Sending courtship invitation to $userId');
  }

  Future<void> _sendCourtshipExitNotification(
    String userId,
    String courtshipId,
    String reason,
  ) async {
    // TODO: Implement push notification
    print('Sending courtship exit notification to $userId');
  }
}
