import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_dimensions.dart';
import '../../../../constants/app_text_styles.dart';
import '../utils/personalisation_models.dart';

class QuestionStepWidget extends StatefulWidget {
  final List<PersonalizationQuestion> questions;
  final Map<String, String> answers;
  final Function(String questionId, String answer) onAnswerChanged;
  final String title;
  final String stepInfo;

  const QuestionStepWidget({
    super.key,
    required this.questions,
    required this.answers,
    required this.onAnswerChanged,
    required this.title,
    required this.stepInfo,
  });

  @override
  State<QuestionStepWidget> createState() => _QuestionStepWidgetState();
}

class _QuestionStepWidgetState extends State<QuestionStepWidget>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  late AnimationController _progressController;
  late AnimationController _questionController;
  late Animation<double> _progressAnimation;
  late Animation<double> _questionFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _questionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _questionFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _questionController, curve: Curves.easeOut),
    );

    _questionController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  void _handleAnswer(String answer) {
    final currentQuestion = widget.questions[_currentQuestionIndex];
    widget.onAnswerChanged(currentQuestion.id, answer);

    if (_currentQuestionIndex < widget.questions.length - 1) {
      _questionController.reverse().then((_) {
        setState(() {
          _currentQuestionIndex++;
        });
        _questionController.forward();
      });
    }

    // Update progress animation
    final progress = (_currentQuestionIndex + 1) / widget.questions.length;
    _progressController.animateTo(progress);
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / widget.questions.length;

    return Column(
      children: [
        // Progress section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
              ),
            ),
            Text(
              '${_currentQuestionIndex + 1} of ${widget.questions.length}',
              style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.paddingM),

        // Progress bar
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(2),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primarySageGreen,
                        AppColors.primaryAccent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: AppDimensions.paddingXL),

        // Question content
        Expanded(
          child: FadeTransition(
            opacity: _questionFadeAnimation,
            child: Column(
              children: [
                Text(
                  currentQuestion.question,
                  style: AppTextStyles.heading2.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDimensions.paddingXL),

                // Answer options
                Expanded(
                  child: ListView.separated(
                    itemCount: currentQuestion.options.length,
                    separatorBuilder:
                        (context, index) =>
                            const SizedBox(height: AppDimensions.paddingM),
                    itemBuilder: (context, index) {
                      final option = currentQuestion.options[index];
                      final isSelected =
                          widget.answers[currentQuestion.id] == option.value;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _handleAnswer(option.value),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusL,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(
                                AppDimensions.paddingL,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? AppColors.primarySageGreen.withValues(
                                          alpha: 0.1,
                                        )
                                        : AppColors.cardBackground,
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? AppColors.primarySageGreen
                                          : AppColors.divider,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusL,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryDarkBlue.withValues(
                                      alpha: 0.1,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      option.label,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: AppColors.primarySageGreen,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        size: 16,
                                        color: AppColors.primaryAccent,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
