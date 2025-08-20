// ==========================================================================
// ACTION BUTTONS COMPONENT
// ==========================================================================

import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

class MatchCardActions extends StatelessWidget {
  final VoidCallback? onInterested;
  final VoidCallback? onNotInterested;

  const MatchCardActions({super.key, this.onInterested, this.onNotInterested});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Not Interested Button
        Expanded(
          child: OutlinedButton(
            onPressed: onNotInterested,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textMedium,
              side: BorderSide(
                color: AppColors.textMedium.withValues(alpha: 0.3),
                width: 1.5,
              ),
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.close, size: 8, color: AppColors.textMedium),
                const SizedBox(width: 8),
                Text(
                  'Not Interested',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Interested Button
        Expanded(
          child: ElevatedButton(
            onPressed: onInterested,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primarySageGreen,
              foregroundColor: AppColors.primaryAccent,
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 2,
              shadowColor: AppColors.primarySageGreen.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite, size: 16, color: AppColors.primaryAccent),
                const SizedBox(width: 8),
                Text(
                  'Interested',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.primaryAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
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
