// lib/features/worldview_assessment/screens/worldview_assessment_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../controllers/worldview_controller.dart';
import '../widgets/worldview_card.dart';
import '../widgets/worldview_completion_card.dart';

class WorldviewAssessmentScreen extends StatefulWidget {
  const WorldviewAssessmentScreen({super.key});

  @override
  State<WorldviewAssessmentScreen> createState() =>
      _WorldviewAssessmentScreenState();
}

class _WorldviewAssessmentScreenState extends State<WorldviewAssessmentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorldviewController>().startAssessment();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Values & Worldview',
          style: AppTextStyles.heading2.copyWith(color: AppColors.textDark),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<WorldviewController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primarySageGreen),
                  const SizedBox(height: 16),
                  Text(
                    'Preparing your worldview assessment...',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textDark.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          if (controller.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.error!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => controller.startAssessment(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primarySageGreen,
                      foregroundColor: AppColors.primaryAccent,
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (controller.isComplete) {
            final highDealBreakers =
                controller.responses
                    .where((r) => r.dealBreakerLevel == 'high')
                    .length;
            final mediumDealBreakers =
                controller.responses
                    .where((r) => r.dealBreakerLevel == 'medium')
                    .length;

            return WorldviewCompletionCard(
              totalQuestions: controller.questions.length,
              totalTimeSpent: controller.responses.fold(
                0,
                (sum, r) => sum + r.timeSpentSeconds,
              ),
              highDealBreakers: highDealBreakers,
              mediumDealBreakers: mediumDealBreakers,
              onViewProfile: () {
                Navigator.of(context).pushNamed('/worldview-profile');
              },
              onFindUnlikelyMatches: () {
                Navigator.of(context).pushNamed('/unlikely-matches');
              },
            );
          }

          final currentQuestion = controller.currentQuestion;
          if (currentQuestion == null) {
            return Center(
              child: Text(
                'No questions available',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textDark,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: WorldviewQuestionCard(
              question: currentQuestion,
              onAnswer: controller.answerQuestion,
              currentIndex: controller.currentQuestionIndex,
              totalQuestions: controller.questions.length,
            ),
          );
        },
      ),
    );
  }
}
