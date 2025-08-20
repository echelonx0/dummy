// lib/features/advanced_personalization/screens/advanced_personalization_screen.dart

import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_dimensions.dart';
import '../../../../constants/app_text_styles.dart';
import '../services/personalisation_service.dart';

import '../utils/personalisation_questions.dart';
import '../widgets/processing_widget.dart';
import '../widgets/question_step.dart';
import '../widgets/results_widget.dart';

class AdvancedPersonalizationScreen extends StatefulWidget {
  final String userGender; // 'male' or 'female'

  const AdvancedPersonalizationScreen({super.key, required this.userGender});

  @override
  State<AdvancedPersonalizationScreen> createState() =>
      _AdvancedPersonalizationScreenState();
}

class _AdvancedPersonalizationScreenState
    extends State<AdvancedPersonalizationScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  Map<String, String> _partnerPreferences = {};
  Map<String, String> _personalDetails = {};
  int _qualificationScore = 0;
  bool _isProcessing = false;
  bool _showResults = false;
  bool _isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final PersonalizationService _service = PersonalizationService();

  String get clubName =>
      widget.userGender == 'female' ? 'Club Cherry' : 'Club Alpha';
  bool get isClubEligible => _qualificationScore >= 75;

  final List<String> _steps = [
    'Introduction',
    'Partner Preferences',
    'Your Profile',
    'Processing',
    'Results',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    if (_currentStep == 2) {
      await _processQualification();
    } else {
      _goToNextStep();
    }
  }

  void _goToNextStep() {
    setState(() {
      _currentStep = (_currentStep + 1).clamp(0, _steps.length - 1);
    });
    _resetAnimations();
  }

  void _goToPreviousStep() {
    setState(() {
      _currentStep = (_currentStep - 1).clamp(0, _steps.length - 1);
    });
    _resetAnimations();
  }

  void _resetAnimations() {
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _processQualification() async {
    setState(() {
      _isProcessing = true;
      _currentStep = 3;
    });

    try {
      // Calculate qualification score
      final score = _service.calculateQualificationScore(_personalDetails);

      // Save to Firebase
      await _service.savePersonalizationData(
        partnerPreferences: _partnerPreferences,
        personalDetails: _personalDetails,
        qualificationScore: score,
        userGender: widget.userGender,
      );

      // Simulate processing time for better UX
      await Future.delayed(const Duration(milliseconds: 2500));

      setState(() {
        _qualificationScore = score;
        _isProcessing = false;
        _showResults = true;
        _currentStep = 4;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing your data. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleClubApplication() async {
    setState(() => _isLoading = true);

    try {
      await _service.submitClubApplication(
        clubType: widget.userGender == 'female' ? 'cherry' : 'alpha',
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Club application submitted! We\'ll review your profile within 48 hours.',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting application. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                index <= _currentStep
                    ? AppColors.primarySageGreen
                    : AppColors.divider,
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildIntroductionStep();
      case 1:
        return QuestionStepWidget(
          questions: PersonalizationQuestions.partnerQuestions,
          answers: _partnerPreferences,
          onAnswerChanged: (questionId, answer) {
            setState(() {
              _partnerPreferences[questionId] = answer;
            });
          },
          title: 'Partner Preferences',
          stepInfo: '1 of 2',
        );
      case 2:
        return QuestionStepWidget(
          questions: PersonalizationQuestions.personalQuestions,
          answers: _personalDetails,
          onAnswerChanged: (questionId, answer) {
            setState(() {
              _personalDetails[questionId] = answer;
            });
          },
          title: 'About You',
          stepInfo: '2 of 2',
        );
      case 3:
        return const ProcessingWidget();
      case 4:
        return ResultsWidget(
          isClubEligible: isClubEligible,
          clubName: clubName,
          userGender: widget.userGender,
          onClubApplication: _handleClubApplication,
          isLoading: _isLoading,
        );
      default:
        return Container();
    }
  }

  Widget _buildIntroductionStep() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primarySageGreen, AppColors.primaryAccent],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.auto_awesome,
            size: 40,
            color: AppColors.primaryAccent,
          ),
        ),

        const SizedBox(height: AppDimensions.paddingXL),

        Text(
          'Unlock Advanced Matching',
          style: AppTextStyles.heading1.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppDimensions.paddingL),

        Text(
          'Based on analysis of our most successful relationships, we\'ve identified key compatibility factors that lead to lasting love.',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textMedium,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppDimensions.paddingXL),

        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primarySageGreen.withValues(alpha: 0.1),
                AppColors.primaryAccent.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildFeatureItem(
                  Icons.psychology,
                  'Deeper\nCompatibility',
                  AppColors.primarySageGreen,
                ),
              ),
              Expanded(
                child: _buildFeatureItem(
                  Icons.diamond,
                  'Premium\nMatches',
                  AppColors.warmRed,
                ),
              ),
              Expanded(
                child: _buildFeatureItem(
                  Icons.verified,
                  'Quality\nFirst',
                  AppColors.primaryAccent,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.paddingL),

        Text(
          'Takes about 3 minutes • Significantly improves match quality',
          style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 1:
        return _partnerPreferences.length >=
            PersonalizationQuestions.partnerQuestions.length;
      case 2:
        return _personalDetails.length >=
            PersonalizationQuestions.personalQuestions.length;
      default:
        return true;
    }
  }

  String get _buttonText {
    switch (_currentStep) {
      case 0:
        return 'Begin Assessment';
      case 1:
        return 'Continue';
      case 2:
        return 'Analyze My Profile';
      default:
        return 'Continue';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundDark, AppColors.backgroundSecondary],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button and progress
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Row(
                  children: [
                    if (_currentStep > 0 && !_isProcessing)
                      IconButton(
                        onPressed: _goToPreviousStep,
                        icon: Icon(Icons.arrow_back, color: AppColors.textDark),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.cardBackground,
                          elevation: 2,
                        ),
                      )
                    else
                      const SizedBox(width: 48),

                    const Spacer(),
                    _buildProgressIndicator(),
                    const Spacer(),

                    if (_currentStep == 0)
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, color: AppColors.textMedium),
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildStepContent(),
                    ),
                  ),
                ),
              ),

              // Bottom button
              if (!_isProcessing && !_showResults)
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canProceed ? _handleNext : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primarySageGreen,
                        foregroundColor: AppColors.primaryAccent,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingL,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusL,
                          ),
                        ),
                        elevation: 4,
                        disabledBackgroundColor: AppColors.divider,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _buttonText,
                            style: AppTextStyles.button.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.paddingS),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
