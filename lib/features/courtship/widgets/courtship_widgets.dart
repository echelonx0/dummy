// lib/features/courtship/widgets/courtship_status_card.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';
import '../../../core/shared/widgets/custom_button.dart';

// lib/features/courtship/widgets/premium_trust_banner.dart
class PremiumTrustBanner extends StatelessWidget {
  const PremiumTrustBanner({super.key});

  static const Color _sunsetOrange = Color(0xFFFFE66D);
  static const Color _coralPink = Color(0xFFFF6B9D);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _sunsetOrange.withValues(alpha: 0.1),
            _coralPink.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: _sunsetOrange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _sunsetOrange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unlock Trust Insights',
                      style: AppTextStyles.heading3.copyWith(
                        color: _sunsetOrange,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'See trust scores of your matches',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _sunsetOrange,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '\$19.99/mo',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            '✓ See detailed trust scores\n✓ Priority matching with verified users\n✓ Protected from low-trust profiles',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textDark),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Upgrade Now',
              onPressed: () {
                // Navigate to premium upgrade
              },
              type: ButtonType.primary,
              icon: Icons.upgrade,
            ),
          ),
        ],
      ),
    );
  }
}
