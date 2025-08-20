// lib/features/worldview_assessment/widgets/worldview_question_card.dart

import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../core/models/worldview_question.dart';

class WorldviewQuestionCard extends StatelessWidget {
  final WorldviewQuestion question;
  final Function(String) onAnswer;
  final int currentIndex;
  final int totalQuestions;

  const WorldviewQuestionCard({
    super.key,
    required this.question,
    required this.onAnswer,
    required this.currentIndex,
    required this.totalQuestions,
  });

  Color _getDealBreakerColor() {
    switch (question.dealBreakerLevel) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      case 'low':
        return AppColors.success;
      default:
        return AppColors.primarySageGreen;
    }
  }

  String _getDealBreakerLabel() {
    switch (question.dealBreakerLevel) {
      case 'high':
        return 'Major Values';
      case 'medium':
        return 'Important Views';
      case 'low':
        return 'Personal Preference';
      default:
        return 'Values Question';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress and category indicator
            Row(
              children: [
                Text(
                  'Question ${currentIndex + 1} of $totalQuestions',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textDark.withValues(alpha: 0.7),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getDealBreakerColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getDealBreakerColor().withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _getDealBreakerLabel(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _getDealBreakerColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Progress bar
            LinearProgressIndicator(
              value: (currentIndex + 1) / totalQuestions,
              backgroundColor: AppColors.borderPrimary.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(_getDealBreakerColor()),
            ),

            const SizedBox(height: 24),

            // Reading time
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.primarySageGreen,
                ),
                const SizedBox(width: 4),
                Text(
                  '~${question.readingTimeSeconds}s read',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primarySageGreen,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Scenario
            Text(
              question.scenario,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textDark,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 32),

            // Option A
            _buildOptionButton(
              context,
              'A',
              question.optionA,
              question.worldviewA,
            ),

            const SizedBox(height: 16),

            // Option B
            _buildOptionButton(
              context,
              'B',
              question.optionB,
              question.worldviewB,
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
    String worldview,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: () => onAnswer(option),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surfaceContainerHigh,
          foregroundColor: AppColors.textDark,
          elevation: 2,
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColors.borderPrimary.withValues(alpha: 0.2),
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
                    color: _getDealBreakerColor(),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    worldview,
                    style: AppTextStyles.label.copyWith(
                      color: _getDealBreakerColor(),
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
                color: AppColors.textDark,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
