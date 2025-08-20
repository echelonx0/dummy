// lib/features/dashboard/widgets/feature_card.dart

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../core/models/premium_feature.dart';
import '../../../core/subscriptions/subscription_manager.dart';

class FeatureCard extends StatelessWidget {
  final PremiumFeature feature;
  final AnimationController pulseController;
  final AnimationController shimmerController;
  final bool? overrideAccess;

  const FeatureCard({
    super.key,
    required this.feature,
    required this.pulseController,
    required this.shimmerController,
    this.overrideAccess,
  });

  @override
  Widget build(BuildContext context) {
    final subscription = SubscriptionManager();
    final hasAccess =
        overrideAccess ?? subscription.hasAccessToTier(feature.requiredTier);

    return Container(
      width: 240,
      height: 200, // Fixed height to prevent overflow
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: feature.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primarySageGreen.withValues(alpha: 0.2),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkBlue.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle shimmer effect for locked features
          if (!hasAccess)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: shimmerController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.transparent,
                          AppColors.primaryAccent.withValues(
                            alpha: (0.1 * shimmerController.value).clamp(
                              0.0,
                              1.0,
                            ),
                          ),
                          Colors.transparent,
                        ],
                        stops: [
                          (shimmerController.value - 0.3).clamp(0.0, 1.0),
                          shimmerController.value.clamp(0.0, 1.0),
                          (shimmerController.value + 0.3).clamp(0.0, 1.0),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          // Card Content - Using Flexible layout
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header with icon and tier badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryAccent.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        feature.icon,
                        color: AppColors.primaryAccent,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    if (!hasAccess)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getTierName(feature.requiredTier),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryDarkBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Title - Using Flexible to prevent overflow
                Flexible(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      feature.title,
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle - Using Flexible
                Flexible(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      feature.subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMedium,
                        height: 1.2,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                const Spacer(),

                // CTA Button - Fixed at bottom
                Container(
                  width: double.infinity,
                  height: 36,
                  decoration: BoxDecoration(
                    color:
                        hasAccess
                            ? AppColors.primaryAccent
                            : AppColors.primaryAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.primaryAccent.withValues(
                        alpha: hasAccess ? 1.0 : 0.4,
                      ),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!hasAccess) ...[
                          Icon(
                            Icons.lock_outline,
                            color: AppColors.primaryAccent,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            hasAccess ? feature.ctaText : 'Unlock',
                            style: AppTextStyles.button.copyWith(
                              color:
                                  hasAccess
                                      ? AppColors.primaryDarkBlue
                                      : AppColors.primaryAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTierName(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.intentional:
        return 'PRO';
      case SubscriptionTier.concierge:
        return 'ELITE';
      case SubscriptionTier.executive:
        return 'VIP';
      case SubscriptionTier.free:
        return 'FREE';
    }
  }
}
