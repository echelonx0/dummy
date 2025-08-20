// ===============================================================
// MATCH ENGINE CONTROLLER
// lib/features/match_engine/controllers/match_engine_controller.dart
// ===============================================================

import 'package:flutter/foundation.dart';
import '../../../core/models/match_data_models.dart';
import '../../../core/services/auth_service.dart';
import '../../../app/locator.dart';
import '../services/match_engine_service.dart';

class MatchEngineController extends ChangeNotifier {
  final MatchEngineService _matchService;

  List<MatchProfile> _matches = [];
  bool _isLoading = false;
  String? _error;

  // Current match being viewed
  int _currentMatchIndex = 0;

  MatchEngineController()
    : _matchService = MatchEngineService(locator<AuthService>());

  // ==========================================================================
  // GETTERS
  // ==========================================================================

  List<MatchProfile> get matches => _matches;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentMatchIndex => _currentMatchIndex;

  MatchProfile? get currentMatch {
    if (_matches.isEmpty || _currentMatchIndex >= _matches.length) {
      return null;
    }
    return _matches[_currentMatchIndex];
  }

  bool get hasMoreMatches => _currentMatchIndex < _matches.length - 1;

  // ==========================================================================
  // MATCH LOADING
  // ==========================================================================

  /// Initialize and load matches
  Future<void> loadMatches() async {
    _setLoading(true);
    _clearError();

    try {
      // Subscribe to matches stream
      _matchService
          .getPotentialMatches(limit: 20)
          .listen(
            (matches) {
              _matches = matches;
              _currentMatchIndex = 0;
              _setLoading(false);
              notifyListeners();
            },
            onError: (error) {
              _setError('Failed to load matches: $error');
              _setLoading(false);
            },
          );
    } catch (e) {
      _setError('Failed to initialize matches: $e');
      _setLoading(false);
    }
  }

  /// Refresh matches manually
  Future<void> refreshMatches() async {
    await loadMatches();
  }

  // ==========================================================================
  // MATCH ACTIONS
  // ==========================================================================

  /// Express interest in current match
  Future<bool> expressInterest() async {
    final match = currentMatch;
    if (match == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final result = await _matchService.expressInterest(match.id);

      if (result.success) {
        // Move to next match
        _moveToNextMatch();

        // Show success feedback based on result
        if (result.isMutualMatch) {
          _showMutualMatchFeedback();
        }

        _setLoading(false);
        return true;
      } else {
        _setError(result.message ?? 'Failed to express interest');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error expressing interest: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Express no interest in current match
  Future<bool> expressNoInterest() async {
    final match = currentMatch;
    if (match == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final result = await _matchService.expressNoInterest(match.id);

      if (result.success) {
        // Move to next match
        _moveToNextMatch();
        _setLoading(false);
        return true;
      } else {
        _setError(result.message ?? 'Failed to record response');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error recording response: $e');
      _setLoading(false);
      return false;
    }
  }

  // ==========================================================================
  // NAVIGATION HELPERS
  // ==========================================================================

  /// Move to next match in the list
  void _moveToNextMatch() {
    if (hasMoreMatches) {
      _currentMatchIndex++;
    } else {
      // No more matches, could trigger reload or show end screen
      _currentMatchIndex = _matches.length;
    }
    notifyListeners();
  }

  /// Go back to previous match (if needed)
  void goToPreviousMatch() {
    if (_currentMatchIndex > 0) {
      _currentMatchIndex--;
      notifyListeners();
    }
  }

  /// Jump to specific match index
  void goToMatch(int index) {
    if (index >= 0 && index < _matches.length) {
      _currentMatchIndex = index;
      notifyListeners();
    }
  }

  // ==========================================================================
  // UI FEEDBACK METHODS
  // ==========================================================================

  void _showMutualMatchFeedback() {
    // This would trigger UI feedback for mutual match
    // Could be handled by the UI layer listening to this controller
    print('🎉 Mutual match detected!');
  }

  // ==========================================================================
  // PRIVATE HELPERS
  // ==========================================================================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
