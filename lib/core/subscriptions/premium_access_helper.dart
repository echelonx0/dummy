// lib/features/subscriptions/widgets/premium_access_helper.dart

import 'package:flutter/material.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import 'subscription_manager.dart';

class PremiumAccessHelper {
  static final SubscriptionManager _subscriptionManager = SubscriptionManager();

  /// Universal premium check - shows RevenueCat paywall
  static Future<bool> requiresPremiumAccess({
    required BuildContext context,
    String feature = 'premium feature',
    String? customMessage,
  }) async {
    // Check if user already has premium access
    if (_subscriptionManager.hasPremiumAccess) {
      return true; // User has access, continue
    }

    // User needs premium - show RevenueCat paywall
    return await _showRevenueCatPaywall(
      context: context,
      feature: feature,
      customMessage: customMessage,
    );
  }

  /// Feature-specific access checks with RevenueCat paywall
  static Future<bool> requiresUnlimitedMessaging(BuildContext context) async {
    if (_subscriptionManager.canAccessUnlimitedMessaging) return true;

    return await _showRevenueCatPaywall(
      context: context,
      feature: 'unlimited messaging',
      customMessage: 'Send unlimited messages to your matchmaker.',
    );
  }

  static Future<bool> requiresPersonalMatchmaker(BuildContext context) async {
    if (_subscriptionManager.canAccessPersonalMatchmaker) return true;

    return await _showRevenueCatPaywall(
      context: context,
      feature: 'personal matchmaker',
      customMessage:
          'Get your dedicated matchmaker with Concierge or Executive plans.',
    );
  }

  static Future<bool> requiresDateCoaching(BuildContext context) async {
    if (_subscriptionManager.canAccessDateCoaching) return true;

    return await _showRevenueCatPaywall(
      context: context,
      feature: 'date coaching',
      customMessage:
          'Access expert date coaching with Concierge or Executive plans.',
    );
  }

  static Future<bool> requiresVipAccess(BuildContext context) async {
    if (_subscriptionManager.canAccessVipEvents) return true;

    return await _showRevenueCatPaywall(
      context: context,
      feature: 'VIP events',
      customMessage: 'Join exclusive VIP events with the Executive plan.',
    );
  }

  /// Show RevenueCat native paywall
  static Future<bool> _showRevenueCatPaywall({
    required BuildContext context,
    required String feature,
    String? customMessage,
  }) async {
    try {
      // First show a feature explanation dialog
      final shouldShowPaywall = await _showFeatureExplanation(
        context: context,
        feature: feature,
        customMessage: customMessage,
      );

      if (!shouldShowPaywall) return false;

      // Show RevenueCat paywall
      final paywallResult = await RevenueCatUI.presentPaywall();

      // Check the result
      switch (paywallResult) {
        case PaywallResult.purchased:
          // Refresh subscription status
          await _subscriptionManager.refresh();

          // Show success message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.celebration, color: AppColors.cream),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Welcome to Premium! $feature unlocked! 🎉',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.cream,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.primarySageGreen,
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return true;

        case PaywallResult.cancelled:
          // User cancelled, no action needed
          return false;

        case PaywallResult.restored:
          // Refresh subscription status
          await _subscriptionManager.refresh();

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Subscription restored! $feature is now available.',
                ),
                backgroundColor: AppColors.primarySageGreen,
              ),
            );
          }
          return _subscriptionManager.hasPremiumAccess;

        case PaywallResult.error:
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Something went wrong. Please try again.'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return false;

        default:
          return false;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to load subscription options: ${e.toString()}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    }
  }

  /// Show feature explanation before paywall
  static Future<bool> _showFeatureExplanation({
    required BuildContext context,
    required String feature,
    String? customMessage,
  }) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGold,
                          AppColors.primarySageGreen,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: AppColors.backgroundDark,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Premium Feature',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.primaryAccent,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customMessage ??
                        'Access to $feature requires a premium subscription. Upgrade now to unlock this feature and find your person faster.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primarySageGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primarySageGreen.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primarySageGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Secure payment powered by RevenueCat',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primarySageGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Maybe Later',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.textMedium,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.primaryGradient,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      'View Plans',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.cream,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Quick access to subscription info for UI display
  static String get currentPlanName => _subscriptionManager.currentTierName;
  static bool get isPremiumUser => _subscriptionManager.hasPremiumAccess;
  static int get weeklyMatchLimit => _subscriptionManager.weeklyMatchQuota;

  /// Subscription status stream for reactive UI
  static Stream get subscriptionStream =>
      _subscriptionManager.customerInfoStream;

  /// Direct paywall presentation (for buttons, etc.)
  static Future<bool> showPaywall(BuildContext context) async {
    try {
      final paywallResult = await RevenueCatUI.presentPaywall();

      switch (paywallResult) {
        case PaywallResult.purchased:
        case PaywallResult.restored:
          await _subscriptionManager.refresh();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome to Premium! 🎉'),
                backgroundColor: AppColors.primarySageGreen,
              ),
            );
          }
          return true;
        default:
          return false;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to load subscription options'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    }
  }
}
