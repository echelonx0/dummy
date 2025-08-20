// ===============================================================
// MATCH ENGINE SERVICE
// lib/core/services/match_engine_service.dart
// ===============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/match_data_models.dart';
import '../../../core/services/auth_service.dart';

class MatchEngineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService;

  MatchEngineService(this._authService);

  // ==========================================================================
  // FETCH MATCHES
  // ==========================================================================

  /// Fetches potential matches for the current user
  Stream<List<MatchProfile>> getPotentialMatches({int limit = 10}) {
    final currentUserId = _authService.getCurrentUser()?.uid;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('matches')
        .where('targetUserId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'pending')
        .orderBy('compatibilityScore', descending: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return MatchProfile.fromMap(data);
          }).toList();
        });
  }

  /// Fetches a single match by ID
  Future<MatchProfile?> getMatchById(String matchId) async {
    try {
      final doc = await _firestore.collection('matches').doc(matchId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return MatchProfile.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error fetching match: $e');
      return null;
    }
  }

  // ==========================================================================
  // MATCH ACTIONS
  // ==========================================================================

  /// User expresses interest in a match
  Future<MatchActionResult> expressInterest(String matchId) async {
    try {
      final currentUserId = _authService.getCurrentUser()?.uid;
      if (currentUserId == null) {
        return MatchActionResult.failure('User not authenticated');
      }

      // Update the match status
      await _firestore.collection('matches').doc(matchId).update({
        'status': MatchStatus.interested.value,
        'lastInteraction': FieldValue.serverTimestamp(),
        'userResponse': 'interested',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      // Check if it's a mutual match
      final isMutual = await _checkForMutualMatch(matchId, currentUserId);

      if (isMutual) {
        // Create conversation or notification for mutual match
        await _handleMutualMatch(matchId, currentUserId);
      }

      // Fetch updated match
      final updatedMatch = await getMatchById(matchId);

      return MatchActionResult.success(
        message:
            isMutual
                ? 'It\'s a mutual match!'
                : 'Interest expressed successfully',
        updatedMatch: updatedMatch,
        isMutualMatch: isMutual,
      );
    } catch (e) {
      return MatchActionResult.failure('Failed to express interest: $e');
    }
  }

  /// User expresses no interest in a match
  Future<MatchActionResult> expressNoInterest(String matchId) async {
    try {
      final currentUserId = _authService.getCurrentUser()?.uid;
      if (currentUserId == null) {
        return MatchActionResult.failure('User not authenticated');
      }

      // Update the match status
      await _firestore.collection('matches').doc(matchId).update({
        'status': MatchStatus.notInterested.value,
        'lastInteraction': FieldValue.serverTimestamp(),
        'userResponse': 'not_interested',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      // Log the rejection for algorithm improvement
      await _logMatchFeedback(matchId, currentUserId, false);

      final updatedMatch = await getMatchById(matchId);

      return MatchActionResult.success(
        message: 'Response recorded',
        updatedMatch: updatedMatch,
      );
    } catch (e) {
      return MatchActionResult.failure('Failed to record response: $e');
    }
  }

  // ==========================================================================
  // PRIVATE HELPER METHODS
  // ==========================================================================

  /// Check if this creates a mutual match
  Future<bool> _checkForMutualMatch(
    String matchId,
    String currentUserId,
  ) async {
    try {
      // Get the match document to find the other user
      final matchDoc =
          await _firestore.collection('matches').doc(matchId).get();
      if (!matchDoc.exists) return false;

      final matchData = matchDoc.data()!;
      final otherUserId =
          matchData['userId'] as String; // The user who was suggested

      // Check if the other user has also expressed interest in current user
      final reverseMatchQuery =
          await _firestore
              .collection('matches')
              .where('userId', isEqualTo: otherUserId)
              .where('targetUserId', isEqualTo: currentUserId)
              .where('status', isEqualTo: MatchStatus.interested.value)
              .get();

      return reverseMatchQuery.docs.isNotEmpty;
    } catch (e) {
      print('Error checking mutual match: $e');
      return false;
    }
  }

  /// Handle mutual match creation
  Future<void> _handleMutualMatch(String matchId, String currentUserId) async {
    try {
      // Update both match documents to mutual status
      await _firestore.collection('matches').doc(matchId).update({
        'status': MatchStatus.mutual.value,
        'mutualMatchAt': FieldValue.serverTimestamp(),
      });

      // Find and update the reverse match
      final matchDoc =
          await _firestore.collection('matches').doc(matchId).get();
      final otherUserId = matchDoc.data()!['userId'] as String;

      final reverseMatchQuery =
          await _firestore
              .collection('matches')
              .where('userId', isEqualTo: otherUserId)
              .where('targetUserId', isEqualTo: currentUserId)
              .get();

      if (reverseMatchQuery.docs.isNotEmpty) {
        await reverseMatchQuery.docs.first.reference.update({
          'status': MatchStatus.mutual.value,
          'mutualMatchAt': FieldValue.serverTimestamp(),
        });
      }

      // Create a conversation between the users
      await _createConversation(currentUserId, otherUserId);

      // Send notifications to both users
      await _sendMutualMatchNotifications(currentUserId, otherUserId);
    } catch (e) {
      print('Error handling mutual match: $e');
    }
  }

  /// Create a conversation for mutual matches
  Future<void> _createConversation(String userId1, String userId2) async {
    try {
      final conversationData = {
        'participants': [userId1, userId2],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': null,
        'lastMessageAt': null,
        'type': 'mutual_match',
        'status': 'active',
      };

      await _firestore.collection('conversations').add(conversationData);
    } catch (e) {
      print('Error creating conversation: $e');
    }
  }

  /// Send notifications for mutual matches
  Future<void> _sendMutualMatchNotifications(
    String userId1,
    String userId2,
  ) async {
    try {
      // Create notification documents for both users
      final notificationData1 = {
        'userId': userId1,
        'type': 'mutual_match',
        'title': 'It\'s a Match!',
        'message': 'You have a new mutual match. Start your courtship journey!',
        'otherUserId': userId2,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      };

      final notificationData2 = {
        'userId': userId2,
        'type': 'mutual_match',
        'title': 'It\'s a Match!',
        'message': 'You have a new mutual match. Start your courtship journey!',
        'otherUserId': userId1,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      };

      await Future.wait([
        _firestore.collection('notifications').add(notificationData1),
        _firestore.collection('notifications').add(notificationData2),
      ]);
    } catch (e) {
      print('Error sending notifications: $e');
    }
  }

  /// Log match feedback for algorithm improvement
  Future<void> _logMatchFeedback(
    String matchId,
    String userId,
    bool wasPositive,
  ) async {
    try {
      final feedbackData = {
        'matchId': matchId,
        'userId': userId,
        'feedback': wasPositive ? 'interested' : 'not_interested',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('match_feedback').add(feedbackData);
    } catch (e) {
      print('Error logging feedback: $e');
    }
  }

  // ==========================================================================
  // ANALYTICS & INSIGHTS
  // ==========================================================================

  /// Get user's match statistics
  Future<Map<String, int>> getUserMatchStats(String userId) async {
    try {
      final matches =
          await _firestore
              .collection('matches')
              .where('targetUserId', isEqualTo: userId)
              .get();

      int pending = 0;
      int interested = 0;
      int notInterested = 0;
      int mutual = 0;

      for (final doc in matches.docs) {
        final status = MatchStatus.fromString(doc.data()['status']);
        switch (status) {
          case MatchStatus.pending:
            pending++;
            break;
          case MatchStatus.interested:
            interested++;
            break;
          case MatchStatus.notInterested:
            notInterested++;
            break;
          case MatchStatus.mutual:
            mutual++;
            break;
          default:
            break;
        }
      }

      return {
        'pending': pending,
        'interested': interested,
        'notInterested': notInterested,
        'mutual': mutual,
        'total': matches.docs.length,
      };
    } catch (e) {
      print('Error fetching match stats: $e');
      return {};
    }
  }
}
