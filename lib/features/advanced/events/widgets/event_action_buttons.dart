// lib/features/events/widgets/event_action_buttons.dart
import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../core/models/events_models.dart';
import '../../../../core/subscriptions/subscription_manager.dart';
import '../events_service.dart';

class EventBottomActionBar extends StatelessWidget {
  final Event event;
  final EventRegistration? userRegistration;
  final SubscriptionManager subscriptionManager;
  final bool isRegistering;
  final VoidCallback onRegister;
  final VoidCallback onCancel;
  final VoidCallback onUpgrade;

  const EventBottomActionBar({
    super.key,
    required this.event,
    this.userRegistration,
    required this.subscriptionManager,
    required this.isRegistering,
    required this.onRegister,
    required this.onCancel,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(child: _buildActionButton()),
    );
  }

  Widget _buildActionButton() {
    // Check user access
    if (!EventsService.canUserAccessEvent(event)) {
      return _buildUpgradeButton();
    }

    // If user is registered, show status
    if (userRegistration != null) {
      return _buildRegisteredActions();
    }

    // Show register button
    return _buildRegisterButton();
  }

  Widget _buildUpgradeButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onUpgrade,
        icon: Icon(Icons.star),
        label: Text(
          'Upgrade to ${event.minimumTier.toUpperCase()} to Register',
          style: AppTextStyles.button.copyWith(fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisteredActions() {
    return Row(
      children: [
        // Status indicator
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primarySageGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: AppColors.primarySageGreen),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: AppColors.primarySageGreen),
                const SizedBox(width: 8),
                Text(
                  _getRegistrationStatusText(),
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.primarySageGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Cancel button
        IconButton(
          onPressed: onCancel,
          icon: Icon(Icons.close, color: Colors.red),
          style: IconButton.styleFrom(
            backgroundColor: Colors.red.withValues(alpha: 0.1),
            shape: CircleBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    final isWaitlist = event.currentAttendees >= event.maxAttendees;
    final userTier = subscriptionManager.currentTierString;
    final price = event.getPriceForTier(userTier);

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isRegistering ? null : onRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isWaitlist ? Colors.orange : AppColors.primarySageGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child:
            isRegistering
                ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                : Text(
                  isWaitlist
                      ? 'Join Waitlist ${price > 0 ? "• \$$price" : "• FREE"}'
                      : 'Register Now ${price > 0 ? "• \$$price" : "• FREE"}',
                  style: AppTextStyles.button.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }

  String _getRegistrationStatusText() {
    if (userRegistration == null) return 'Registered';

    switch (userRegistration!.status) {
      case RegistrationStatus.confirmed:
        return 'Registered';
      case RegistrationStatus.waitlisted:
        return 'On Waitlist';
      case RegistrationStatus.pending:
        return 'Registration Pending';
      default:
        return 'Registered';
    }
  }
}
