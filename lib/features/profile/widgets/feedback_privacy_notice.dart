// lib/features/profile/widgets/feedback_privacy_notice.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';
import '../../../generated/l10n.dart';

class FeedbackPrivacyNotice extends StatelessWidget {
  const FeedbackPrivacyNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primarySageGreen.withValues(alpha: 0.1),
            AppColors.primaryAccent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.primarySageGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySageGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.privacy_tip_outlined,
                  color: AppColors.primarySageGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: Text(
                  l10n.privacyNote,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primarySageGreen,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingM),

          Text(
            l10n.privacyExplanation,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDark,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}