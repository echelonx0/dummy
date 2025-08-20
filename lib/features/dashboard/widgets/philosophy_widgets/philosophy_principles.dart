// lib/features/dashboard/widgets/philosophy_widgets/philosophy_principles.dart
import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';

class PhilosophyPrinciples extends StatelessWidget {
  const PhilosophyPrinciples({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGold,
            AppColors.cardBackground,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primarySageGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How We\'re Different',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),

          _buildPrincipleItem(
            number: '01',
            title: 'No Swiping',
            description:
                'We use AI-driven compatibility analysis instead of endless photo judgments.',
          ),

          _buildPrincipleItem(
            number: '02',
            title: 'Guided Courtship',
            description:
                'Our 14-day structured journey helps you build genuine connections.',
          ),

          _buildPrincipleItem(
            number: '03',
            title: 'Personal Growth',
            description:
                'Become your best self while finding your perfect match.',
          ),

          _buildPrincipleItem(
            number: '04',
            title: 'Quality Over Quantity',
            description:
                'Carefully curated matches based on deep psychological compatibility.',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPrincipleItem({
    required String number,
    required String title,
    required String description,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primarySageGreen, AppColors.primaryAccent],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primarySageGreen.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  number,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryDarkBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMedium,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.only(left: 60),
            height: 1,
            color: AppColors.primarySageGreen.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}