// lib/features/courtship/providers/courtship_provider.dart
import 'package:flutter/foundation.dart';
import '../../../core/services/auth_service.dart';
import '../../../app/locator.dart';
import '../models/courtship_models.dart';
import '../services/courtship_service.dart';

class CourtshipProvider extends ChangeNotifier {
  final CourtshipService _courtshipService = CourtshipService();
  final AuthService _authService = locator<AuthService>();

  // State variables
  UserCourtshipStatus? _courtshipStatus;
  List<MatchRecommendation> _matchRecommendations = [];
  TrustScore? _userTrustScore;
  bool _hasPremiumTrustAccess = false;

  // Loading states
  bool _isLoadingStatus = false;
  bool _isLoadingRecommendations = false;
  bool _isLoadingTrustScore = false;

  // Error states
  String? _statusError;
  String? _recommendationsError;
  String? _trustScoreError;

  // Getters
  UserCourtshipStatus? get courtshipStatus => _courtshipStatus;
  List<MatchRecommendation> get matchRecommendations => _matchRecommendations;
  TrustScore? get userTrustScore => _userTrustScore;
  bool get hasPremiumTrustAccess => _hasPremiumTrustAccess;

  bool get isLoadingStatus => _isLoadingStatus;
  bool get isLoadingRecommendations => _isLoadingRecommendations;
  bool get isLoadingTrustScore => _isLoadingTrustScore;

  String? get statusError => _statusError;
  String? get recommendationsError => _recommendationsError;
  String? get trustScoreError => _trustScoreError;

  // Load user's courtship status
  Future<void> loadUserCourtshipStatus() async {
    _isLoadingStatus = true;
    _statusError = null;
    notifyListeners();

    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      _courtshipStatus = await _courtshipService.getUserCourtshipStatus(
        user.uid,
      );
      _isLoadingStatus = false;
      notifyListeners();
    } catch (error) {
      _statusError = error.toString();
      _isLoadingStatus = false;
      notifyListeners();
    }
  }

  // Load match recommendations
  Future<void> loadMatchRecommendations() async {
    _isLoadingRecommendations = true;
    _recommendationsError = null;
    notifyListeners();

    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      _matchRecommendations = await _courtshipService.getMatchRecommendations(
        user.uid,
      );
      _isLoadingRecommendations = false;
      notifyListeners();
    } catch (error) {
      _recommendationsError = error.toString();
      _isLoadingRecommendations = false;
      notifyListeners();
    }
  }

  // Load user's trust score
  Future<void> loadTrustScore() async {
    _isLoadingTrustScore = true;
    _trustScoreError = null;
    notifyListeners();

    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      _userTrustScore = await _courtshipService.getUserTrustScore(user.uid);
      _hasPremiumTrustAccess = await _courtshipService.hasPremiumTrustAccess(
        user.uid,
      );
      _isLoadingTrustScore = false;
      notifyListeners();
    } catch (error) {
      _trustScoreError = error.toString();
      _isLoadingTrustScore = false;
      notifyListeners();
    }
  }

  // Initiate a courtship with a potential match
  Future<String> initiateCourtship(String targetUserId) async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final courtshipId = await _courtshipService.initiateCourtship(
        user.uid,
        targetUserId,
      );

      // Reload status after initiating courtship
      await loadUserCourtshipStatus();

      return courtshipId;
    } catch (error) {
      throw Exception('Failed to initiate courtship: $error');
    }
  }

  // Respond to a courtship commitment
  Future<void> respondToCommitment(String courtshipId, bool accept) async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _courtshipService.respondToCourtshipCommitment(
        user.uid,
        courtshipId,
        accept,
      );

      // Reload status after responding
      await loadUserCourtshipStatus();
    } catch (error) {
      throw Exception('Failed to respond to commitment: $error');
    }
  }

  // Submit a response to a courtship interaction
  Future<void> submitInteractionResponse(
    String courtshipId,
    int day,
    String response,
  ) async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _courtshipService.submitInteractionResponse(
        user.uid,
        courtshipId,
        day,
        response,
      );

      // Reload status after submitting response
      await loadUserCourtshipStatus();
    } catch (error) {
      throw Exception('Failed to submit response: $error');
    }
  }

  // Exit a courtship respectfully
  Future<void> exitCourtship(String courtshipId, String reason) async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _courtshipService.requestRespectfulExit(
        user.uid,
        courtshipId,
        reason,
      );

      // Reload status after exiting
      await loadUserCourtshipStatus();
      await loadMatchRecommendations();
    } catch (error) {
      throw Exception('Failed to exit courtship: $error');
    }
  }

  // Submit feedback for a completed courtship
  Future<void> submitCourtshipFeedback(
    String courtshipId,
    CourtshipFeedback feedback,
  ) async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _courtshipService.submitCourtshipFeedback(
        user.uid,
        courtshipId,
        feedback,
      );

      // Reload trust score after feedback submission
      await loadTrustScore();
    } catch (error) {
      throw Exception('Failed to submit feedback: $error');
    }
  }

  // Get active courtship details
  Future<Courtship?> getActiveCourtship() async {
    try {
      if (_courtshipStatus?.currentCourtshipId == null) {
        return null;
      }

      return await _courtshipService.getCourtship(
        _courtshipStatus!.currentCourtshipId!,
      );
    } catch (error) {
      throw Exception('Failed to get active courtship: $error');
    }
  }

  // Check if user can initiate new courtship
  bool canInitiateCourtship() {
    if (_courtshipStatus == null) return false;

    // User must not be in active courtship
    if (_courtshipStatus!.isInCourtship) return false;

    // User must not be under penalty
    if (_courtshipStatus!.availableDate != null &&
        _courtshipStatus!.availableDate!.isAfter(DateTime.now())) {
      return false;
    }

    return true;
  }

  // Get time until user can participate in courtship again
  Duration? getTimeUntilAvailable() {
    if (_courtshipStatus?.availableDate == null) return null;

    final now = DateTime.now();
    if (_courtshipStatus!.availableDate!.isBefore(now)) return null;

    return _courtshipStatus!.availableDate!.difference(now);
  }

  // Clear all state (useful for logout)
  void clearState() {
    _courtshipStatus = null;
    _matchRecommendations = [];
    _userTrustScore = null;
    _hasPremiumTrustAccess = false;

    _isLoadingStatus = false;
    _isLoadingRecommendations = false;
    _isLoadingTrustScore = false;

    _statusError = null;
    _recommendationsError = null;
    _trustScoreError = null;

    notifyListeners();
  }

  // Refresh all courtship data
  Future<void> refreshAll() async {
    await Future.wait([
      loadUserCourtshipStatus(),
      loadMatchRecommendations(),
      loadTrustScore(),
    ]);
  }
}
