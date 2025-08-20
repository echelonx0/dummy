// lib/features/dashboard/widgets/premium_unlock_option.dart

import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

class PremiumUnlockOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? price;
  final String? progress;
  final Color color;
  final VoidCallback onTap;
  final bool isRecommended;
  final String? badge;

  const PremiumUnlockOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.price,
    this.progress,
    required this.color,
    required this.onTap,
    this.isRecommended = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor =
        badge == 'Coming Soon'
            ? const Color(0xFFFF8A95) // Soft pinkish color
            : color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              effectiveColor.withValues(alpha: 0.1),
              effectiveColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: effectiveColor.withValues(alpha: isRecommended ? 0.5 : 0.3),
            width: isRecommended ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: effectiveColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: AppColors.backgroundDark, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: effectiveColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textDark,
                        ),
                      ),
                      if (price != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          price!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: effectiveColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      if (progress != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          progress!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: effectiveColor, size: 20),
              ],
            ),

            // Badges
            if (isRecommended)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: effectiveColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Recommended',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.backgroundDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            if (badge != null && !isRecommended)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        badge == 'Coming Soon'
                            ? effectiveColor
                            : AppColors.textMedium,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge!,
                    style: AppTextStyles.caption.copyWith(
                      color:
                          badge == 'Coming Soon'
                              ? AppColors.backgroundDark
                              : AppColors.primaryAccent,
                      fontWeight: FontWeight.bold,
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
