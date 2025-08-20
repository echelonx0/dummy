// lib/features/events/widgets/components/event_card_actions.dart
import 'package:flutter/material.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../constants/app_text_styles.dart';
import '../../../../../core/models/events_models.dart';
import '../../../../../core/subscriptions/subscription_manager.dart';
import '../events_service.dart';

class EventCardActions extends StatelessWidget {
  final Event event;
  final EventRegistration? userRegistration;
  final SubscriptionManager subscriptionManager;
  final bool isLoading;
  final VoidCallback onRegister;
  final VoidCallback onUpgrade;
  final VoidCallback onExpand;
  final bool isExpanded;
  final bool isCompact;

  const EventCardActions({
    super.key,
    required this.event,
    this.userRegistration,
    required this.subscriptionManager,
    required this.isLoading,
    required this.onRegister,
    required this.onUpgrade,
    required this.onExpand,
    this.isExpanded = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      child: Column(
        children: [
          Row(
            children: [
              // Pricing info
              Expanded(child: _buildPricingSection()),

              // Main action button
              _buildMainActionButton(),
            ],
          ),
          if (!isCompact) ...[
            const SizedBox(height: 12),
            _buildSecondaryActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    final userTier = subscriptionManager.currentTierName;
    final price = event.getPriceForTier(userTier);
    final originalPrice = event.pricing.freeUserPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (price == 0)
          Text(
            'FREE',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.primarySageGreen,
              fontWeight: FontWeight.bold,
              fontSize: isCompact ? 16 : 18,
            ),
          )
        else
          Row(
            children: [
              Text(
                '\$${price.toStringAsFixed(0)}',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: isCompact ? 16 : 18,
                ),
              ),
              if (price < originalPrice) ...[
                const SizedBox(width: 6),
                Text(
                  '\$${originalPrice.toStringAsFixed(0)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textLight,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
        if (event.hostName.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'by ${event.hostName}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textLight,
              fontSize: isCompact ? 10 : 11,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMainActionButton() {
    // Check user access first
    if (!EventsService.canUserAccessEvent(event)) {
      return _buildUpgradeButton();
    }

    // If user is registered, show status
    if (userRegistration != null) {
      return _buildRegisteredButton();
    }

    // Show register button
    return _buildRegisterButton();
  }

  Widget _buildUpgradeButton() {
    return ElevatedButton.icon(
      onPressed: onUpgrade,
      icon: Icon(Icons.star_rounded, size: isCompact ? 14 : 16),
      label: Text(
        'Upgrade',
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: isCompact ? 11 : 12,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGold,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 16,
          vertical: isCompact ? 6 : 8,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
      ),
    );
  }

  Widget _buildRegisteredButton() {
    final config = _getRegisteredButtonConfig();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 16,
        vertical: isCompact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            config['color'].withValues(alpha: 0.1),
            config['color'].withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config['color'].withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config['icon'],
            size: isCompact ? 14 : 16,
            color: config['color'],
          ),
          const SizedBox(width: 6),
          Text(
            config['text'],
            style: AppTextStyles.bodySmall.copyWith(
              color: config['color'],
              fontWeight: FontWeight.bold,
              fontSize: isCompact ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    final isWaitlist = event.currentAttendees >= event.maxAttendees;
    final buttonColor = isWaitlist ? Colors.orange : AppColors.primarySageGreen;

    return ElevatedButton.icon(
      onPressed: isLoading ? null : onRegister,
      icon:
          isLoading
              ? SizedBox(
                width: isCompact ? 12 : 14,
                height: isCompact ? 12 : 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : Icon(
                isWaitlist ? Icons.schedule_rounded : Icons.add_rounded,
                size: isCompact ? 14 : 16,
              ),
      label: Text(
        isWaitlist ? 'Join Waitlist' : 'Register',
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: isCompact ? 11 : 12,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 16,
          vertical: isCompact ? 6 : 8,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
      ),
    );
  }

  Widget _buildSecondaryActions() {
    return Row(
      children: [
        // Expand/Collapse button
        Expanded(
          child: TextButton.icon(
            onPressed: onExpand,
            icon: Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.primarySageGreen,
            ),
            label: Text(
              isExpanded ? 'Show Less' : 'Show More',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primarySageGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
        ),

        // Share button
        IconButton(
          onPressed: () => _shareEvent(),
          icon: Icon(
            Icons.share_rounded,
            size: 18,
            color: AppColors.textMedium,
          ),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.textLight.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(8),
          ),
        ),

        const SizedBox(width: 8),

        // Favorite button
        IconButton(
          onPressed: () => _toggleFavorite(),
          icon: Icon(
            Icons.favorite_border_rounded, // You can make this stateful
            size: 18,
            color: AppColors.textMedium,
          ),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.textLight.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getRegisteredButtonConfig() {
    switch (userRegistration!.status) {
      case RegistrationStatus.confirmed:
        return {
          'color': AppColors.primarySageGreen,
          'text': 'Registered',
          'icon': Icons.check_circle_rounded,
        };
      case RegistrationStatus.waitlisted:
        return {
          'color': Colors.orange,
          'text': 'Waitlisted',
          'icon': Icons.schedule_rounded,
        };
      case RegistrationStatus.pending:
        return {
          'color': Colors.blue,
          'text': 'Pending',
          'icon': Icons.pending_rounded,
        };
      default:
        return {
          'color': Colors.grey,
          'text': 'Unknown',
          'icon': Icons.help_outline_rounded,
        };
    }
  }

  void _shareEvent() {
    // TODO: Implement share functionality
    // You can use share_plus package
  }

  void _toggleFavorite() {
    // TODO: Implement favorite functionality
  }
}

// Extension for subscription manager
extension SubscriptionManagerExtension on SubscriptionManager {
  String get currentTierString {
    if (hasEliteAccess) return 'elite';
    if (hasPremiumAccess) return 'premium';
    return 'free';
  }
}
