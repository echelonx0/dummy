// lib/features/worldview_assessment/widgets/worldview_completion_card.dart

import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';

class WorldviewCompletionCard extends StatelessWidget {
  final int totalQuestions;
  final int totalTimeSpent;
  final int highDealBreakers;
  final int mediumDealBreakers;
  final VoidCallback onViewProfile;
  final VoidCallback onFindUnlikelyMatches;

  const WorldviewCompletionCard({
    super.key,
    required this.totalQuestions,
    required this.totalTimeSpent,
    required this.highDealBreakers,
    required this.mediumDealBreakers,
    required this.onViewProfile,
    required this.onFindUnlikelyMatches,
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
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Success icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primarySageGreen,
                    AppColors.primarySageGreen.withValues(alpha: 0.7),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.balance,
                size: 40,
                color: AppColors.primaryAccent,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Worldview Assessment Complete!',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              'You\'ve explored deep questions about society, values, and life philosophy. Now we can find fascinating people who see the world differently than you do.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textDark.withValues(alpha: 0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Stats grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        icon: Icons.quiz_outlined,
                        label: 'Questions',
                        value: totalQuestions.toString(),
                        color: AppColors.primarySageGreen,
                      ),
                      _buildStatItem(
                        icon: Icons.timer_outlined,
                        label: 'Time',
                        value: _formatTime(totalTimeSpent),
                        color: AppColors.primarySageGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        icon: Icons.priority_high,
                        label: 'Core Values',
                        value: highDealBreakers.toString(),
                        color: AppColors.error,
                      ),
                      _buildStatItem(
                        icon: Icons.interests,
                        label: 'Preferences',
                        value: mediumDealBreakers.toString(),
                        color: AppColors.warning,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Call to action
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primarySageGreen.withValues(alpha: 0.1),
                    AppColors.warmRed.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primarySageGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.explore,
                    size: 32,
                    color: AppColors.primarySageGreen,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ready for Unlikely Matches?',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.primarySageGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Discover people who challenge your worldview but share your humanity',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textDark.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewProfile,
                    icon: const Icon(Icons.person_outline),
                    label: const Text('View Profile'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primarySageGreen,
                      side: BorderSide(color: AppColors.primarySageGreen),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: onFindUnlikelyMatches,
                    icon: const Icon(Icons.explore),
                    label: const Text('Find Unlikely Matches'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primarySageGreen,
                      foregroundColor: AppColors.primaryAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
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
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textDark.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
