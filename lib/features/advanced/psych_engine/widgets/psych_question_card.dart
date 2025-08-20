import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../core/models/psych_question.dart';

class PsychologyQuestionCard extends StatelessWidget {
  final PsychologyQuestion question;
  final Function(String) onAnswer;
  final int currentIndex;
  final int totalQuestions;

  const PsychologyQuestionCard({
    super.key,
    required this.question,
    required this.onAnswer,
    required this.currentIndex,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      color: AppColors.surface, // ✅ Fixed: Removed .color
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            Row(
              children: [
                Text(
                  'Question ${currentIndex + 1} of $totalQuestions',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMedium, // ✅ Fixed: Direct color
                  ),
                ),
                const Spacer(),
                Text(
                  '~${question.readingTimeSeconds}s read',
                  style: AppTextStyles.bodySmall.copyWith(
                    color:
                        AppColors
                            .primarySageGreen, // ✅ Fixed: Using bronze accent
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Progress bar
            LinearProgressIndicator(
              value: (currentIndex + 1) / totalQuestions,
              backgroundColor: AppColors.borderPrimary.withValues(
                alpha: 0.2,
              ), // ✅ Fixed
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primarySageGreen, // ✅ Fixed: Bronze accent
              ),
            ),

            const SizedBox(height: 32),

            // Scenario
            Text(
              question.scenario,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textDark, // ✅ Fixed: Cream text
                height: 1.6,
              ),
            ),

            const SizedBox(height: 32),

            // Option A
            _buildOptionButton(
              context,
              'A',
              question.optionA,
              question.principleA,
            ),

            const SizedBox(height: 16),

            // Option B
            _buildOptionButton(
              context,
              'B',
              question.optionB,
              question.principleB,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    String option,
    String description,
    String principle,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: () => onAnswer(option),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surfaceContainerHigh, // ✅ Fixed
          foregroundColor: AppColors.textDark, // ✅ Fixed: Cream text
          elevation: 2,
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColors.borderPrimary.withValues(alpha: 0.2), // ✅ Fixed
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primarySageGreen, // ✅ Fixed: Bronze accent
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: AppTextStyles.label.copyWith(
                        color:
                            AppColors
                                .primaryDarkBlue, // ✅ Fixed: Dark text on bronze
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    principle,
                    style: AppTextStyles.label.copyWith(
                      color:
                          AppColors.primarySageGreen, // ✅ Fixed: Bronze accent
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDark, // ✅ Fixed: Cream text
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
