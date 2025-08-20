// lib/features/profile/screens/profile_assessment_screen.dart
import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/shared/widgets/custom_button.dart';
import '../../../app/locator.dart';
import '../widgets/profile_step_indicator.dart';
import 'profile_feedback_screen.dart';

class ProfileAssessmentScreen extends StatefulWidget {
  const ProfileAssessmentScreen({super.key});

  @override
  State<ProfileAssessmentScreen> createState() =>
      _ProfileAssessmentScreenState();
}

class _ProfileAssessmentScreenState extends State<ProfileAssessmentScreen> {
  final _authService = locator<AuthService>();
  final _firebaseService = locator<FirebaseService>();
  final _pageController = PageController();

  bool _isLoading = false;
  int _currentQuestionIndex = 0;

  // Assessment questions and responses
  final Map<String, int> _responses = {};

  // Define different assessment types
  final List<Map<String, dynamic>> _assessments = [
    {
      'id': 'attachment',
      'title': 'Attachment Style Assessment',
      'description':
          'Understand how you form bonds and feel secure in relationships',
      'questions': [
        {
          'id': 'attachment_1',
          'text': 'I find it difficult to depend on romantic partners.',
          'type': 'avoidant',
        },
        {
          'id': 'attachment_2',
          'text':
              'I worry that romantic partners won\'t care about me as much as I care about them.',
          'type': 'anxious',
        },
        {
          'id': 'attachment_3',
          'text': 'I am comfortable being close to romantic partners.',
          'type': 'secure',
        },
        {
          'id': 'attachment_4',
          'text': 'I worry about my partner abandoning me.',
          'type': 'anxious',
        },
        {
          'id': 'attachment_5',
          'text': 'I prefer not to show a partner how I feel deep down.',
          'type': 'avoidant',
        },
      ],
    },
    {
      'id': 'communication',
      'title': 'Communication Pattern Assessment',
      'description':
          'Identify your natural communication style in relationships',
      'questions': [
        {
          'id': 'communication_1',
          'text':
              'When there\'s a problem in my relationship, I prefer to talk about it immediately.',
          'type': 'direct',
        },
        {
          'id': 'communication_2',
          'text':
              'I find it easy to express my feelings, even when they\'re negative.',
          'type': 'expressive',
        },
        {
          'id': 'communication_3',
          'text':
              'I need time to process my thoughts before discussing relationship issues.',
          'type': 'reflective',
        },
        {
          'id': 'communication_4',
          'text':
              'During arguments, I tend to stay calm and focus on solving the problem.',
          'type': 'analytical',
        },
        {
          'id': 'communication_5',
          'text':
              'I often worry about how my words might affect my partner\'s feelings.',
          'type': 'considerate',
        },
      ],
    },
  ];

  // Current assessment index
  int _currentAssessmentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAssessmentData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAssessmentData() async {
    setState(() => _isLoading = true);

    try {
      final user = _authService.getCurrentUser();

      if (user != null) {
        final profileDoc = await _firebaseService.getDocumentById(
          'profiles',
          user.uid,
        );

        if (profileDoc.exists) {
          final data = profileDoc.data() as Map<String, dynamic>;

          // Check if assessment data exists
          if (data['psychologicalAssessments'] != null &&
              data['psychologicalAssessments'] is Map) {
            setState(() {
              // Load saved responses if they exist
              final assessments =
                  data['psychologicalAssessments'] as Map<String, dynamic>;

              for (final assessmentType in assessments.keys) {
                final responses = assessments[assessmentType];
                if (responses != null && responses is Map) {
                  for (final questionId in responses.keys) {
                    _responses[questionId] = responses[questionId];
                  }
                }
              }

              // Check which assessment was completed last
              for (int i = 0; i < _assessments.length; i++) {
                final questions = _assessments[i]['questions'] as List;

                bool allAnswered = true;
                for (final question in questions) {
                  final questionId = question['id'];
                  if (!_responses.containsKey(questionId)) {
                    allAnswered = false;
                    break;
                  }
                }

                if (!allAnswered) {
                  _currentAssessmentIndex = i;
                  break;
                }

                // If all were answered and we're at the last assessment, stay there
                if (i == _assessments.length - 1) {
                  _currentAssessmentIndex = i;
                }
              }
            });
          }
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        Helpers.showErrorModal(
          context,
          message: 'Failed to load assessment data: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _saveAssessmentData() async {
    try {
      final user = _authService.getCurrentUser();

      if (user != null) {
        // Organize responses by assessment type
        final Map<String, Map<String, int>> organizedResponses = {};

        for (final assessment in _assessments) {
          final assessmentId = assessment['id'];
          final questions = assessment['questions'] as List;

          organizedResponses[assessmentId] = {};

          for (final question in questions) {
            final questionId = question['id'];
            if (_responses.containsKey(questionId)) {
              organizedResponses[assessmentId]![questionId] =
                  _responses[questionId]!;
            }
          }
        }

        // Calculate attachment style
        String attachmentStyle = _calculateAttachmentStyle();

        // Calculate communication style
        String communicationStyle = _calculateCommunicationStyle();

        // Update profile data in Firestore
        await _firebaseService.updateDocument('profiles', user.uid, {
          'psychologicalAssessments': organizedResponses,
          'attachmentStyle': attachmentStyle,
          'communicationStyle': communicationStyle,
          'completionStatus.psychologicalAssessment': 'completed',
          'completionPercentage': FieldValue.increment(12.5),
          'lastUpdated': Timestamp.now(),
        });
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorModal(
          context,
          message: 'Failed to save assessment data: ${e.toString()}',
        );
      }
    }
  }

  String _calculateAttachmentStyle() {
    // Simple calculation of attachment style based on responses
    // In a real app, this would be a more sophisticated algorithm

    int anxiousScore = 0;
    int avoidantScore = 0;
    int secureScore = 0;
    int questionsAnswered = 0;

    for (final assessment in _assessments) {
      if (assessment['id'] != 'attachment') continue;

      final questions = assessment['questions'] as List;

      for (final question in questions) {
        final questionId = question['id'];
        final type = question['type'];

        if (_responses.containsKey(questionId)) {
          final value = _responses[questionId]!;
          questionsAnswered++;

          if (type == 'anxious') {
            anxiousScore += value;
          } else if (type == 'avoidant') {
            avoidantScore += value;
          } else if (type == 'secure') {
            secureScore += value;
          }
        }
      }
    }

    if (questionsAnswered == 0) return 'unknown';

    // Determine the dominant style
    if (secureScore > anxiousScore && secureScore > avoidantScore) {
      return 'secure';
    } else if (anxiousScore > avoidantScore) {
      return 'anxious';
    } else {
      return 'avoidant';
    }
  }

  String _calculateCommunicationStyle() {
    // Simple calculation of communication style based on responses
    // In a real app, this would be a more sophisticated algorithm

    Map<String, int> typeScores = {
      'direct': 0,
      'expressive': 0,
      'reflective': 0,
      'analytical': 0,
      'considerate': 0,
    };

    int questionsAnswered = 0;

    for (final assessment in _assessments) {
      if (assessment['id'] != 'communication') continue;

      final questions = assessment['questions'] as List;

      for (final question in questions) {
        final questionId = question['id'];
        final type = question['type'];

        if (_responses.containsKey(questionId)) {
          final value = _responses[questionId]!;
          questionsAnswered++;

          if (typeScores.containsKey(type)) {
            typeScores[type] = (typeScores[type] ?? 0) + value;
          }
        }
      }
    }

    if (questionsAnswered == 0) return 'unknown';

    // Find the dominant style
    String dominantStyle = 'unknown';
    int highestScore = 0;

    for (final type in typeScores.keys) {
      final score = typeScores[type] ?? 0;
      if (score > highestScore) {
        highestScore = score;
        dominantStyle = type;
      }
    }

    return dominantStyle;
  }

  void _handleResponse(String questionId, int value) {
    setState(() {
      _responses[questionId] = value;
    });
  }

  void _nextQuestion() {
    final currentAssessment = _assessments[_currentAssessmentIndex];
    final questions = currentAssessment['questions'] as List;

    if (_currentQuestionIndex < questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });

      _pageController.animateToPage(
        _currentQuestionIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // End of current assessment
      if (_currentAssessmentIndex < _assessments.length - 1) {
        // Move to the next assessment
        setState(() {
          _currentAssessmentIndex++;
          _currentQuestionIndex = 0;
        });

        _pageController.jumpToPage(0);
      } else {
        // Completed all assessments
        _completeAssessment();
      }
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });

      _pageController.animateToPage(
        _currentQuestionIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Start of current assessment
      if (_currentAssessmentIndex > 0) {
        // Move to the previous assessment
        setState(() {
          _currentAssessmentIndex--;

          // Get the last question index of the previous assessment
          final previousAssessment = _assessments[_currentAssessmentIndex];
          final questions = previousAssessment['questions'] as List;
          _currentQuestionIndex = questions.length - 1;
        });

        _pageController.jumpToPage(_currentQuestionIndex);
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentQuestionIndex = index;
    });
  }

  Future<void> _completeAssessment() async {
    setState(() => _isLoading = true);

    try {
      await _saveAssessmentData();

      if (mounted) {
        setState(() => _isLoading = false);

        // Show success message
        Helpers.showSuccessModal(
          context,
          title: 'Assessment Complete',
          message:
              'You\'ve successfully completed the psychological assessment!',
          actionButton: CustomButton(
            text: 'Continue',
            onPressed: () {
              Navigator.of(context).pop(); // Close modal
              _navigateToNextStep();
            },
            type: ButtonType.primary,
          ),
          duration: Duration.zero, // Don't auto-dismiss
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        Helpers.showErrorModal(
          context,
          message: 'Failed to complete assessment: ${e.toString()}',
        );
      }
    }
  }

  void _navigateToNextStep() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ProfileFeedbackScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentAssessment = _assessments[_currentAssessmentIndex];
    final questions = currentAssessment['questions'] as List;
    final totalQuestions = questions.length;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(currentAssessment['title']),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Column(
                  children: [
                    // Step Indicator
                    const ProfileStepIndicator(currentStep: 7, totalSteps: 8),

                    // Assessment Introduction
                    Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: DelayedDisplay(
                        delay: const Duration(milliseconds: 100),
                        child: Container(
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusL,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentAssessment['title'],
                                style: AppTextStyles.heading3.copyWith(
                                  color: AppColors.primaryDarkBlue,
                                ),
                              ),

                              const SizedBox(height: AppDimensions.paddingM),

                              Text(
                                currentAssessment['description'],
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primaryDarkBlue,
                                ),
                              ),

                              const SizedBox(height: AppDimensions.paddingM),

                              LinearProgressIndicator(
                                value:
                                    (_currentQuestionIndex + 1) /
                                    totalQuestions,
                                backgroundColor: AppColors.divider,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryDarkBlue,
                                ),
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusS,
                                ),
                              ),

                              const SizedBox(height: AppDimensions.paddingS),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Question ${_currentQuestionIndex + 1} of $totalQuestions',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textMedium,
                                    ),
                                  ),
                                  Text(
                                    'Assessment ${_currentAssessmentIndex + 1} of ${_assessments.length}',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Questions
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: _onPageChanged,
                        itemCount: totalQuestions,
                        itemBuilder: (context, index) {
                          final question = questions[index];
                          final questionId = question['id'];
                          final questionText = question['text'];

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingL,
                            ),
                            child: DelayedDisplay(
                              delay: const Duration(milliseconds: 200),
                              child: _buildQuestionCard(
                                questionId,
                                questionText,
                                _responses[questionId] ??
                                    3, // Default to neutral
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Navigation Buttons
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: DelayedDisplay(
                        delay: const Duration(milliseconds: 300),
                        child: Row(
                          children: [
                            // Back Button
                            if (_currentQuestionIndex > 0 ||
                                _currentAssessmentIndex > 0)
                              Expanded(
                                child: CustomButton(
                                  text: 'Back',
                                  onPressed: _previousQuestion,
                                  type: ButtonType.outlined,
                                ),
                              ),

                            if (_currentQuestionIndex > 0 ||
                                _currentAssessmentIndex > 0)
                              const SizedBox(width: AppDimensions.paddingM),

                            // Next Button
                            Expanded(
                              flex: 2,
                              child: CustomButton(
                                text: _isLastQuestion() ? 'Complete' : 'Next',
                                onPressed: _nextQuestion,
                                type: ButtonType.primary,
                                icon:
                                    _isLastQuestion()
                                        ? Icons.check
                                        : Icons.arrow_forward,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  bool _isLastQuestion() {
    final currentAssessment = _assessments[_currentAssessmentIndex];
    final questions = currentAssessment['questions'] as List;

    return _currentAssessmentIndex == _assessments.length - 1 &&
        _currentQuestionIndex == questions.length - 1;
  }

  Widget _buildQuestionCard(
    String questionId,
    String questionText,
    int currentValue,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Add this to prevent expansion
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            questionText,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDarkBlue,
            ),
          ),

          const SizedBox(height: AppDimensions.paddingXL),

          // Agreement scale - wrap in Expanded with SingleChildScrollView
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildScaleOption(
                    questionId,
                    5,
                    'Strongly Agree',
                    currentValue,
                  ),
                  _buildScaleOption(
                    questionId,
                    4,
                    'Somewhat Agree',
                    currentValue,
                  ),
                  _buildScaleOption(questionId, 3, 'Neutral', currentValue),
                  _buildScaleOption(
                    questionId,
                    2,
                    'Somewhat Disagree',
                    currentValue,
                  ),
                  _buildScaleOption(
                    questionId,
                    1,
                    'Strongly Disagree',
                    currentValue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScaleOption(
    String questionId,
    int value,
    String label,
    int currentValue,
  ) {
    final isSelected = value == currentValue;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: InkWell(
        onTap: () => _handleResponse(questionId, value),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppColors.primaryDarkBlue.withOpacity(0.1)
                    : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(
              color:
                  isSelected ? AppColors.primaryDarkBlue : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primaryDarkBlue : Colors.white,
                  border: Border.all(
                    color:
                        isSelected
                            ? AppColors.primaryDarkBlue
                            : AppColors.divider,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
              ),

              const SizedBox(width: AppDimensions.paddingM),

              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color:
                      isSelected
                          ? AppColors.primaryDarkBlue
                          : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
