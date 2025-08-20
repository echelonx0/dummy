// lib/features/events/widgets/event_pricing_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../core/models/events_models.dart';
import '../../../../core/subscriptions/subscription_manager.dart';

class EventPricingCard extends StatelessWidget {
  final Event event;
  final SubscriptionManager subscriptionManager;

  const EventPricingCard({
    super.key,
    required this.event,
    required this.subscriptionManager,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pricing',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildPricingTier('Free Members', event.pricing.freeUserPrice),
          _buildPricingTier('Premium Members', event.pricing.premiumPrice),
          _buildPricingTier('Elite Members', event.pricing.elitePrice),

          if (event.isEarlyBird && event.pricing.earlyBirdDiscount > 0) ...[
            const SizedBox(height: 12),
            _buildEarlyBirdBanner(),
          ],
        ],
      ),
    );
  }

  Widget _buildPricingTier(String tier, double price) {
    final userTier = subscriptionManager.currentTierName;
    final isUserTier = (tier.toLowerCase().contains(userTier));
    final finalPrice =
        event.isEarlyBird
            ? price * (1 - event.pricing.earlyBirdDiscount)
            : price;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isUserTier
                ? AppColors.primarySageGreen.withValues(alpha: 0.1)
                : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isUserTier
                  ? AppColors.primarySageGreen.withValues(alpha: 0.3)
                  : AppColors.textLight.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              tier,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDark,
                fontWeight: isUserTier ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          if (finalPrice != price) ...[
            Text(
              '\$$price',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textLight,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            finalPrice == 0 ? 'FREE' : '\$$finalPrice',
            style: AppTextStyles.bodyLarge.copyWith(
              color:
                  isUserTier ? AppColors.primarySageGreen : AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isUserTier) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.check_circle,
              color: AppColors.primarySageGreen,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEarlyBirdBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: AppColors.primaryGold, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Early Bird: ${(event.pricing.earlyBirdDiscount * 100).toInt()}% off until ${DateFormat('MMM d').format(event.earlyBirdDeadline!)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
