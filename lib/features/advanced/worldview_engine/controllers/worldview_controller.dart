import 'package:flutter/material.dart';
import '../../../../core/models/worldview_question.dart';
import '../../../../core/models/worldview_response.dart';
import '../services/worldview_service.dart';

class WorldviewController extends ChangeNotifier {
  final WorldviewService _service = WorldviewService();

  List<WorldviewQuestion> _questions = [];
  List<WorldviewResponse> _responses = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  String? _error;
  DateTime? _questionStartTime;
  int _totalTimeSpent = 0;

  // Getters
  List<WorldviewQuestion> get questions => _questions;
  List<WorldviewResponse> get responses => _responses;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isComplete => _currentQuestionIndex >= _questions.length;
  double get progress =>
      _questions.isEmpty ? 0.0 : _currentQuestionIndex / _questions.length;
  WorldviewQuestion? get currentQuestion =>
      _currentQuestionIndex < _questions.length
          ? _questions[_currentQuestionIndex]
          : null;

  Future<void> startAssessment() async {
    _setLoading(true);
    _error = null;

    try {
      _questions = await _service.getQuestionsForUser();
      _responses.clear();
      _currentQuestionIndex = 0;
      _totalTimeSpent = 0;
      _startQuestionTimer();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _startQuestionTimer() {
    _questionStartTime = DateTime.now();
  }

  int _getTimeSpentOnCurrentQuestion() {
    if (_questionStartTime == null) return 0;
    return DateTime.now().difference(_questionStartTime!).inSeconds;
  }

  Future<void> answerQuestion(String selectedOption) async {
    if (currentQuestion == null) return;

    final timeSpent = _getTimeSpentOnCurrentQuestion();
    _totalTimeSpent += timeSpent;

    final worldview =
        selectedOption == 'A'
            ? currentQuestion!.worldviewA
            : currentQuestion!.worldviewB;

    final response = WorldviewResponse(
      questionId: currentQuestion!.id,
      selectedOption: selectedOption,
      selectedWorldview: worldview,
      valuesDimension: currentQuestion!.valuesDimension,
      dealBreakerLevel: currentQuestion!.dealBreakerLevel,
      timestamp: DateTime.now(),
      timeSpentSeconds: timeSpent,
    );

    _responses.add(response);

    try {
      await _service.saveResponse(response);
    } catch (e) {
      debugPrint('Error saving response: $e');
    }

    _currentQuestionIndex++;

    if (isComplete) {
      await _completeAssessment();
    } else {
      _startQuestionTimer();
    }

    notifyListeners();
  }

  Future<void> _completeAssessment() async {
    _setLoading(true);

    try {
      final userId = _responses.first.questionId; // Fix: get actual userId
      await _service.completeProfile(userId, _responses, _totalTimeSpent);
    } catch (e) {
      _error = 'Failed to save assessment: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void reset() {
    _questions.clear();
    _responses.clear();
    _currentQuestionIndex = 0;
    _totalTimeSpent = 0;
    _questionStartTime = null;
    _error = null;
    notifyListeners();
  }
}
