// lib/features/profile/widgets/profile_progress_tracker.dart
import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:khedoo/generated/l10n.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';

class ProfileProgressTracker extends StatelessWidget {
  final Map<String, String> completionStatus;

  const ProfileProgressTracker({super.key, required this.completionStatus});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Sections',
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: AppDimensions.paddingM),

        // Basic Info
        _buildSectionItem(
          context: context,
          title: l10n.basicInfoTitle,
          status: completionStatus['basicInfo'] ?? 'not_started',
          index: 1,
        ),

        // Photos
        _buildSectionItem(
          context: context,
          title: l10n.uploadPhotosTitle,
          status: completionStatus['photos'] ?? 'not_started',
          index: 2,
        ),

        // Core Values
        _buildSectionItem(
          context: context,
          title: l10n.coreValuesTitle,
          status: completionStatus['coreValues'] ?? 'not_started',
          index: 3,
        ),

        // Lifestyle
        _buildSectionItem(
          context: context,
          title: l10n.lifestyleTitle,
          status: completionStatus['lifestyle'] ?? 'not_started',
          index: 4,
        ),

        // Relationship Goals
        _buildSectionItem(
          context: context,
          title: l10n.relationshipGoalsTitle,
          status: completionStatus['relationshipGoals'] ?? 'not_started',
          index: 5,
        ),

        // Deep Questions
        _buildSectionItem(
          context: context,
          title: l10n.deepQuestionsTitle,
          status: completionStatus['deepQuestions'] ?? 'not_started',
          index: 6,
        ),

        // Psychological Assessment
        _buildSectionItem(
          context: context,
          title: l10n.assessmentTitle,
          status: completionStatus['psychologicalAssessment'] ?? 'not_started',
          index: 7,
        ),

        // Third-Party Feedback
        _buildSectionItem(
          context: context,
          title: l10n.feedbackTitle,
          status: completionStatus['thirdPartyFeedback'] ?? 'not_started',
          index: 8,
          isOptional: true,
        ),
      ],
    );
  }

  Widget _buildSectionItem({
    required BuildContext context,
    required String title,
    required String status,
    required int index,
    bool isOptional = false,
  }) {
    // Status color and icon
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'completed':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        statusText = 'Completed';
        break;
      case 'in_progress':
        statusColor = AppColors.primaryGold;
        statusIcon = Icons.access_time;
        statusText = 'In Progress';
        break;
      case 'skipped':
        statusColor = AppColors.textMedium;
        statusIcon = Icons.skip_next;
        statusText = 'Skipped';
        break;
      case 'not_started':
      default:
        statusColor = AppColors.textMedium;
        statusIcon = Icons.circle_outlined;
        statusText = 'Not Started';
        break;
    }

    return DelayedDisplay(
      delay: Duration(milliseconds: 50 * index),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
        child: Row(
          children: [
            // Section Number and Title
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDarkBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        index.toString(),
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.bodyMedium),
                        if (isOptional)
                          Text(
                            'Optional',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textMedium,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Status
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 16),
                const SizedBox(width: AppDimensions.paddingXS),
                Text(
                  statusText,
                  style: AppTextStyles.caption.copyWith(color: statusColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
