// lib/features/dashboard/widgets/philosophy_widgets/philosophy_promise.dart
import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';

class PhilosophyPromise extends StatelessWidget {
  const PhilosophyPromise({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceContainerLow,
            AppColors.surfaceContainer,
            AppColors.surfaceContainerLow,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primarySageGreen.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySageGreen.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.surfaceContainerHigh,
                  AppColors.surfaceContainerLow,
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.surfaceContainer,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.favorite,
              color: AppColors.primaryDarkBlue,
              size: 28,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Our Promise to You',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            'We promise to honor your journey, respect your time, and help you find not just any relationship, but the right relationship. This is not just another app—this is your sanctuary for authentic love.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textDark,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
