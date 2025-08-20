// lib/features/psychological_profile/widgets/psychology_completion_card.dart

import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';

class PsychologyCompletionCard extends StatelessWidget {
  final int totalQuestions;
  final int totalTimeSpent;
  final VoidCallback onViewResults;
  final VoidCallback onFindMatches;

  const PsychologyCompletionCard({
    super.key,
    required this.totalQuestions,
    required this.totalTimeSpent,
    required this.onViewResults,
    required this.onFindMatches,
  });

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      color: AppColors.surface, // ✅ Fixed: Removed .color
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Success icon with pulsing animation
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
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primarySageGreen.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.psychology_alt,
                size: 40,
                color: AppColors.primarySageGreen, // ✅ Fixed: Bronze accent
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Assessment Complete!',
              style: AppTextStyles.heading2.copyWith(
                // ✅ Fixed: Better text style
                color: AppColors.textDark, // ✅ Fixed: Cream text
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              'You\'ve completed all $totalQuestions questions in ${_formatTime(totalTimeSpent)}. Your psychological profile is now ready to find your perfect opposite match.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textMedium, // ✅ Fixed: Bronze secondary text
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Enhanced stats row with premium styling
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.surfaceContainerHigh,
                    AppColors.surfaceContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primarySageGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                    icon: Icons.quiz,
                    label: 'Questions',
                    value: totalQuestions.toString(),
                  ),
                  _buildStatItem(
                    icon: Icons.timer,
                    label: 'Time Spent',
                    value: _formatTime(totalTimeSpent),
                  ),
                  _buildStatItem(
                    icon: Icons.favorite,
                    label: 'Ready for',
                    value: 'Matches',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Premium action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onViewResults,
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          AppColors.primarySageGreen, // ✅ Fixed: Bronze
                      side: BorderSide(
                        color: AppColors.primarySageGreen,
                      ), // ✅ Fixed
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.visibility, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'View Profile',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.primarySageGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onFindMatches,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.primarySageGreen, // ✅ Fixed: Bronze
                      foregroundColor:
                          AppColors
                              .primaryDarkBlue, // ✅ Fixed: Dark text on bronze
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Find Matches',
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

            const SizedBox(height: 16),

            // Premium feature hint
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warmRedAlpha10,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.warmRed.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: AppColors.warmRed, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Upgrade to Premium for advanced insights and unlimited matches',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.warmRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primarySageGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primarySageGreen, // ✅ Fixed: Bronze accent
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.label.copyWith(
            // ✅ Fixed: Better text style
            color: AppColors.textDark, // ✅ Fixed: Cream text
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textMedium, // ✅ Fixed: Bronze secondary text
          ),
        ),
      ],
    );
  }
}
