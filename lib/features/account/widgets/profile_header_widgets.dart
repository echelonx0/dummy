// lib/features/profile/widgets/profile_header_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../services/profile_management_screen.dart';

class ProfileManagementHeader extends StatelessWidget {
  final ProfileData profileData;
  final VoidCallback onEditProfile;

  const ProfileManagementHeader({
    super.key,
    required this.profileData,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 100),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const SizedBox(width: 20),

            // User Info
            Expanded(
              child: DelayedDisplay(
                delay: const Duration(milliseconds: 300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profileData.userName ?? 'User',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.primaryDarkBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profileData.userEmail ?? '',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ProfileCompletionBadge(
                      completionPercentage: profileData.completionPercentage,
                      isComplete: profileData.isComplete,
                    ),
                  ],
                ),
              ),
            ),

            // Edit Button
            DelayedDisplay(
              delay: const Duration(milliseconds: 400),
              child: IconButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onEditProfile();
                },
                icon: Icon(
                  Icons.edit_outlined,
                  color: AppColors.primaryDarkBlue,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryDarkBlue.withValues(
                    alpha: 0.1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileCompletionBadge extends StatelessWidget {
  final double completionPercentage;
  final bool isComplete;

  const ProfileCompletionBadge({
    super.key,
    required this.completionPercentage,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            isComplete
                ? AppColors.primaryDarkBlue
                : AppColors.primaryDarkBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.pending,
            color: isComplete ? Colors.white : AppColors.primaryDarkBlue,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            isComplete
                ? 'Complete'
                : '${completionPercentage.toInt()}% Complete',
            style: AppTextStyles.caption.copyWith(
              color: isComplete ? Colors.white : AppColors.primaryDarkBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
