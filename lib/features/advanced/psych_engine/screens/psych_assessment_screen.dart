import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../controller/psych_controller.dart';
import '../widgets/psych_completion_card.dart';
import '../widgets/psych_question_card.dart';

class PsychologyAssessmentScreen extends StatefulWidget {
  const PsychologyAssessmentScreen({super.key});

  @override
  State<PsychologyAssessmentScreen> createState() =>
      _PsychologyAssessmentScreenState();
}

class _PsychologyAssessmentScreenState extends State<PsychologyAssessmentScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _cardController;
  late Animation<double> _progressAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PsychologyController>().startAssessment();
      _cardController.forward();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight, // ✅ Fixed: Dark background
      appBar: AppBar(
        title: Text(
          'Psychology Assessment',
          style: AppTextStyles.heading3.copyWith(
            // ✅ Fixed: Better text style
            color: AppColors.textDark, // ✅ Fixed: Cream text
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface, // ✅ Fixed: Surface background
        elevation: 2,
        shadowColor: AppColors.primaryDarkBlue.withValues(alpha: 0.1),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primarySageGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_back,
              color: AppColors.primarySageGreen, // ✅ Fixed: Bronze accent
              size: 20,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Progress indicator in app bar
          Consumer<PsychologyController>(
            builder: (context, controller, child) {
              if (controller.questions.isEmpty) return const SizedBox.shrink();

              // final progress =
              //     (controller.currentQuestionIndex + 1) /
              //     controller.questions.length;

              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySageGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primarySageGreen.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Text(
                      '${controller.currentQuestionIndex + 1}/${controller.questions.length}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primarySageGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<PsychologyController>(
        builder: (context, controller, child) {
          // Update progress animation when question changes
          if (controller.questions.isNotEmpty) {
            final progress =
                (controller.currentQuestionIndex + 1) /
                controller.questions.length;
            _progressController.animateTo(progress);
          }

          if (controller.isLoading) {
            return _buildLoadingState();
          }

          if (controller.error != null) {
            return _buildErrorState(controller);
          }

          if (controller.isComplete) {
            return _buildCompletionState(controller);
          }

          final currentQuestion = controller.currentQuestion;
          if (currentQuestion == null) {
            return _buildNoQuestionsState();
          }

          return _buildQuestionState(currentQuestion, controller);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primarySageGreen.withValues(alpha: 0.2),
                  AppColors.primaryAccent.withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: AppColors.primarySageGreen, // ✅ Fixed: Bronze accent
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Preparing Your Assessment',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textDark, // ✅ Fixed: Cream text
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Creating personalized questions just for you...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMedium, // ✅ Fixed: Bronze text
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(PsychologyController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.error, // ✅ Fixed: Error color
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something Went Wrong',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textDark, // ✅ Fixed: Cream text
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              controller.error!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error, // ✅ Fixed: Error color
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.startAssessment(),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primarySageGreen, // ✅ Fixed: Bronze
                  foregroundColor:
                      AppColors.primaryDarkBlue, // ✅ Fixed: Dark on bronze
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Try Again',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.primaryDarkBlue,
                        fontWeight: FontWeight.bold,
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

  Widget _buildCompletionState(PsychologyController controller) {
    return FadeTransition(
      opacity: _progressAnimation,
      child: PsychologyCompletionCard(
        totalQuestions: controller.questions.length,
        totalTimeSpent: controller.responses.fold(
          0,
          (sum, r) => sum + r.timeSpentSeconds,
        ),
        onViewResults: () {
          Navigator.of(context).pushNamed('/psychology-results');
        },
        onFindMatches: () {
          Navigator.of(context).pushNamed('/opposite-matches');
        },
      ),
    );
  }

  Widget _buildNoQuestionsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz,
            size: 64,
            color: AppColors.textMedium, // ✅ Fixed: Bronze text
          ),
          const SizedBox(height: 16),
          Text(
            'No Questions Available',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textDark, // ✅ Fixed: Cream text
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later or contact support.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMedium, // ✅ Fixed: Bronze text
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionState(
    dynamic currentQuestion,
    PsychologyController controller,
  ) {
    return Column(
      children: [
        // Enhanced progress bar
        Container(
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(3),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primarySageGreen,
                        AppColors.primaryAccent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            },
          ),
        ),

        // Question content with slide animation
        Expanded(
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              child: PsychologyQuestionCard(
                question: currentQuestion,
                onAnswer: (answer) {
                  controller.answerQuestion(answer);
                  // Trigger slide animation for next question
                  _cardController.reset();
                  _cardController.forward();
                },
                currentIndex: controller.currentQuestionIndex,
                totalQuestions: controller.questions.length,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
