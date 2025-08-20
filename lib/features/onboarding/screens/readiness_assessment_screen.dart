import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../generated/l10n.dart';
import 'exclusive_onboarding_screen.dart';
import 'not_yet_ready_screen.dart';
import 'welcomt_2_community_screen.dart';

class ReadinessAssessmentScreen extends StatefulWidget {
  const ReadinessAssessmentScreen({super.key});

  @override
  State<ReadinessAssessmentScreen> createState() =>
      _ReadinessAssessmentScreenState();
}

class _ReadinessAssessmentScreenState extends State<ReadinessAssessmentScreen> {
  int currentQuestion = 0;
  List<String> answers = [];
  List<ReadinessQuestion>? questions; // Made nullable

  @override
  void initState() {
    super.initState();
    // Don't access context in initState - wait for didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ FIXED: Initialize questions here where context is available
    if (questions == null) {
      _initializeQuestions();
    }
  }

  void _initializeQuestions() {
    final l10n = AppLocalizations.of(context);

    questions = [
      ReadinessQuestion(l10n.readinessQuestion1, [
        l10n.readinessAnswer1a,
        l10n.readinessAnswer1b,
        l10n.readinessAnswer1c,
        l10n.readinessAnswer1d,
      ], filteringQuestion: true),
      ReadinessQuestion(l10n.readinessQuestion2, [
        l10n.readinessAnswer2a,
        l10n.readinessAnswer2b,
        l10n.readinessAnswer2c,
        l10n.readinessAnswer2d,
      ], filteringQuestion: true),
      ReadinessQuestion(l10n.readinessQuestion3, [
        l10n.readinessAnswer3a,
        l10n.readinessAnswer3b,
        l10n.readinessAnswer3c,
        l10n.readinessAnswer3d,
      ], filteringQuestion: true),
    ];

    setState(() {}); // Refresh UI
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // ✅ FIXED: Proper null check with loading state
    if (questions == null || questions!.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primaryGold),
              const SizedBox(height: 16),
              Text(
                'Preparing assessment...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  48,
            ),
            child: IntrinsicHeight(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Progress indicator with exclusivity language
                    Text(
                      l10n.readinessAssessmentProgress(
                        currentQuestion + 1,
                        questions!
                            .length, // ✅ FIXED: Use non-null assertion safely
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: AppColors.primaryGold,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Question with premium styling
                    Text(
                      questions![currentQuestion]
                          .question, // ✅ FIXED: Safe access
                      style: AppTextStyles.heading2.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // Answer options with premium interaction
                    ...questions![currentQuestion].options.map(
                      // ✅ FIXED: Safe access
                      (option) => Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _selectAnswer(option),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.primaryGold.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                option,
                                style: AppTextStyles.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Subtle reminder of exclusivity
                    Text(
                      l10n.genuinelyReadyMessage,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMedium,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectAnswer(String answer) {
    answers.add(answer);

    if (currentQuestion < questions!.length - 1) {
      // ✅ FIXED: Safe access
      setState(() {
        currentQuestion++;
      });
    } else {
      _processAssessment();
    }
  }

  void _processAssessment() {
    // Analyze answers for filtering
    bool passesFilter = _evaluateReadiness(answers);

    if (passesFilter) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WelcomeToExclusiveCommunityScreen(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotReadyYetScreen(userAnswers: answers),
        ),
      );
    }
  }

  bool _evaluateReadiness(List<String> answers) {
    final l10n = AppLocalizations.of(context);

    // Implement actual filtering logic
    int redFlags = 0;

    // Check for filtering criteria
    if (answers.isNotEmpty && answers[0] == l10n.readinessAnswer1a) {
      redFlags++; // Less than 3 months single
    }

    if (answers.length > 1 && answers[1] == l10n.readinessAnswer2d) {
      redFlags++; // Just curious about app
    }

    if (answers.length > 2 && answers[2] == l10n.readinessAnswer3d) {
      redFlags++; // No time commitment
    }

    // Fail if 2 or more red flags
    return redFlags < 2;
  }
}
