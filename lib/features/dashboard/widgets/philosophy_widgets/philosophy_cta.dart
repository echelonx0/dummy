// lib/features/dashboard/widgets/philosophy_widgets/philosophy_cta.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';

class PhilosophyCTA extends StatelessWidget {
  const PhilosophyCTA({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDarkBlue,
            AppColors.primaryGold,
            AppColors.surfaceVariant,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkBlue.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'We are family first',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.primaryAccent,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          Text(
            'We are not for everyone. We are for those who value family, community, and the bonds that tie us together. If you share our vision, we invite you to join us in building a brighter future.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryAccent.withValues(alpha: 0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryAccent.withValues(alpha: 0.2),
                  AppColors.primaryAccent.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryAccent.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.web_sharp,
                      color: AppColors.primaryAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Invite a friend',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
