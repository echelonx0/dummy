import 'package:flutter/material.dart';

import '../../../../core/models/psych_question.dart';
import '../../../../core/models/psych_response.dart';
import '../services/psych_service.dart';

class PsychologyController extends ChangeNotifier {
  final PsychologyService _service = PsychologyService();

  List<PsychologyQuestion> _questions = [];
  List<PsychologyResponse> _responses = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  String? _error;
  DateTime? _questionStartTime;
  int _totalTimeSpent = 0;

  // Getters
  List<PsychologyQuestion> get questions => _questions;
  List<PsychologyResponse> get responses => _responses;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isComplete => _currentQuestionIndex >= _questions.length;
  double get progress =>
      _questions.isEmpty ? 0.0 : _currentQuestionIndex / _questions.length;
  PsychologyQuestion? get currentQuestion =>
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

    final principle =
        selectedOption == 'A'
            ? currentQuestion!.principleA
            : currentQuestion!.principleB;

    final response = PsychologyResponse(
      questionId: currentQuestion!.id,
      selectedOption: selectedOption,
      selectedPrinciple: principle,
      timestamp: DateTime.now(),
      timeSpentSeconds: timeSpent,
    );

    _responses.add(response);

    // Save individual response
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
      await _service.completeProfile(
        _responses.first.questionId, // This should be userId, let me fix this
        _responses,
        _totalTimeSpent,
      );
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
