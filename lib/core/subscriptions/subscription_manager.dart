import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:async';
import 'dart:developer';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../models/premium_feature.dart';
import 'subscription_sheet.dart';

class SubscriptionManager {
  static final SubscriptionManager _instance = SubscriptionManager._internal();
  factory SubscriptionManager() => _instance;
  SubscriptionManager._internal();

  CustomerInfo? _customerInfo;
  StreamController<CustomerInfo>? _customerInfoController;

  // Stream for listening to subscription changes
  Stream<CustomerInfo> get customerInfoStream {
    _customerInfoController ??= StreamController<CustomerInfo>.broadcast();
    return _customerInfoController!.stream;
  }

  Future<void> init() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();

      // Setup listener for changes
      Purchases.addCustomerInfoUpdateListener((info) {
        _customerInfo = info;
        _customerInfoController?.add(info);
      });

      log('Subscription manager initialized. Subscribed: $isSubscribed');
    } catch (e) {
      log('Failed to initialize subscription manager: $e');
    }
  }

  void dispose() {
    _customerInfoController?.close();
  }

  /// Check if user has any active subscription
  bool get isSubscribed {
    return _customerInfo?.entitlements.active.isNotEmpty ?? false;
  }

  /// Check if user has access to a specific entitlement
  bool hasAccess(String entitlement) {
    return _customerInfo?.entitlements.active[entitlement] != null;
  }

  /// Get user-friendly tier name
  String get currentTierName {
    switch (currentTier) {
      case SubscriptionPlan.premium:
        return 'Intentional';
      case SubscriptionPlan.elite:
        return 'Concierge';
      case SubscriptionPlan.vip:
        return 'Executive';
      case null:
        return 'Free';
    }
  }

  /// Check if user has premium features (any paid tier)
  bool get hasPremiumAccess {
    return currentTier != null;
  }

  /// Check if user has elite features (Elite or VIP)
  bool get hasEliteAccess {
    return currentTier == SubscriptionPlan.elite ||
        currentTier == SubscriptionPlan.vip;
  }

  /// Check if user has VIP features
  bool get hasVipAccess {
    return currentTier == SubscriptionPlan.vip;
  }

  /// Feature-specific access checks
  bool get canAccessUnlimitedMessaging => hasPremiumAccess;
  bool get canAccessPersonalMatchmaker => hasEliteAccess;
  bool get canAccessDateCoaching => hasEliteAccess;
  bool get canAccessPriorityMatching => hasEliteAccess;
  bool get canAccessBackgroundVerification => hasVipAccess;
  bool get canAccessVipEvents => hasVipAccess;
  bool get canAccessDirectFounderAccess => hasVipAccess;

  /// Get match quota based on tier
  int get weeklyMatchQuota {
    switch (currentTier) {
      case SubscriptionPlan.premium:
        return 15; // 10-15 matches
      case SubscriptionPlan.elite:
        return 20; // Premium features + priority
      case SubscriptionPlan.vip:
        return 25; // Unlimited-like experience
      case null:
        return 3; // Free tier limit
    }
  }

  /// Refresh customer info from RevenueCat
  Future<void> refresh() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      if (_customerInfo != null) {
        _customerInfoController?.add(_customerInfo!);
      }
      log('Customer info refreshed. Current tier: $currentTierName');
    } catch (e) {
      log('Failed to refresh customer info: $e');
    }
  }

  SubscriptionPlan? get currentTier {
    if (_customerInfo == null) return null;

    // Check for VIP tier first (highest)
    if (hasAccess('unfold_vip')) {
      return SubscriptionPlan.vip;
    }

    // Check for Elite tier
    if (hasAccess('unfold_elite')) {
      return SubscriptionPlan.elite;
    }

    // Check for Premium tier
    if (hasAccess('unfold_premium')) {
      return SubscriptionPlan.premium;
    }

    return null;
  }

  /// Show subscription bottom sheet
  Future<bool> showSubscriptionSheet(BuildContext context) async {
    bool subscriptionPurchased = false;

    await SubscriptionBottomSheet.show(
      context,
      onSubscriptionSelected: (tierString) {
        subscriptionPurchased = true;
        log('Subscription selected: $tierString');
      },
    );

    // Refresh customer info after potential purchase
    await refresh();

    return subscriptionPurchased;
  }

  /// Force show subscription for feature access
  Future<bool> requireSubscription(
    BuildContext context, {
    String? featureName,
    String? message,
  }) async {
    final defaultMessage =
        featureName != null
            ? 'Access to $featureName requires a subscription'
            : 'This feature requires a subscription';

    // Show a dialog first explaining the requirement
    final shouldShowPaywall = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Subscription Required',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textDark),
          ),
          content: Text(
            message ?? defaultMessage,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMedium,
            ),
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
                  style: AppTextStyles.button.copyWith(color: AppColors.cream),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldShowPaywall == true) {
      return await showSubscriptionSheet(context);
    }

    return false;
  }

  bool hasAccessToTier(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return true; // Everyone has free access
      case SubscriptionTier.intentional:
        return hasPremiumAccess;
      case SubscriptionTier.concierge:
        return hasEliteAccess;
      case SubscriptionTier.executive:
        return hasVipAccess;
    }
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      _customerInfo = customerInfo;
      _customerInfoController?.add(customerInfo);

      log('Purchases restored. Has subscription: $isSubscribed');
      return isSubscribed;
    } catch (e) {
      log('Failed to restore purchases: $e');
      return false;
    }
  }

  /// Helper method to parse ISO date string to DateTime
  DateTime? _parseExpiryDate(String? expiryDateString) {
    if (expiryDateString == null || expiryDateString.isEmpty) {
      return null;
    }

    try {
      // RevenueCat returns ISO 8601 format strings
      return DateTime.parse(expiryDateString);
    } catch (e) {
      log('Failed to parse expiry date: $expiryDateString, error: $e');
      return null;
    }
  }

  /// Get subscription expiry date
  DateTime? get subscriptionExpiryDate {
    final activeEntitlements = _customerInfo?.entitlements.active;
    if (activeEntitlements?.isEmpty ?? true) return null;

    // Get the latest expiry date from all active entitlements
    DateTime? latestExpiry;
    for (final entitlement in activeEntitlements!.values) {
      final expiryDate = _parseExpiryDate(entitlement.expirationDate);
      if (expiryDate != null) {
        if (latestExpiry == null || expiryDate.isAfter(latestExpiry)) {
          latestExpiry = expiryDate;
        }
      }
    }

    return latestExpiry;
  }

  /// Check if subscription is about to expire (within 3 days)
  bool get isSubscriptionExpiringSoon {
    final expiryDate = subscriptionExpiryDate;
    if (expiryDate == null) return false;

    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 3 && daysUntilExpiry >= 0;
  }

  /// Get days until subscription expires
  int? get daysUntilExpiry {
    final expiryDate = subscriptionExpiryDate;
    if (expiryDate == null) return null;

    final days = expiryDate.difference(DateTime.now()).inDays;
    return days > 0 ? days : 0;
  }

  /// Check if user is in free trial
  bool get isInFreeTrial {
    final activeEntitlements = _customerInfo?.entitlements.active;
    if (activeEntitlements?.isEmpty ?? true) return false;

    return activeEntitlements!.values.any(
      (entitlement) => entitlement.periodType == PeriodType.trial,
    );
  }

  /// Get formatted expiry date for display
  String? get formattedExpiryDate {
    final expiryDate = subscriptionExpiryDate;
    if (expiryDate == null) return null;

    // Format as "MMM dd, yyyy"
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[expiryDate.month]} ${expiryDate.day.toString().padLeft(2, '0')}, ${expiryDate.year}';
  }

  /// Check if subscription has expired
  bool get hasSubscriptionExpired {
    final expiryDate = subscriptionExpiryDate;
    if (expiryDate == null) return false;

    return DateTime.now().isAfter(expiryDate);
  }

  /// Get subscription status for UI display
  String get subscriptionStatus {
    if (!isSubscribed) return 'No active subscription';
    if (isInFreeTrial) return 'Free trial active';
    if (hasSubscriptionExpired) return 'Subscription expired';
    if (isSubscriptionExpiringSoon) return 'Expires soon';
    return 'Active subscription';
  }

  /// Analytics helper - get subscription status for tracking
  Map<String, dynamic> get subscriptionAnalyticsData {
    return {
      'is_subscribed': isSubscribed,
      'current_tier': currentTierName.toLowerCase(),
      'has_premium_access': hasPremiumAccess,
      'has_elite_access': hasEliteAccess,
      'has_vip_access': hasVipAccess,
      'is_in_trial': isInFreeTrial,
      'days_until_expiry': daysUntilExpiry,
      'weekly_match_quota': weeklyMatchQuota,
      'subscription_status': subscriptionStatus,
      'expiry_date': subscriptionExpiryDate?.toIso8601String(),
      'is_expiring_soon': isSubscriptionExpiringSoon,
      'has_expired': hasSubscriptionExpired,
    };
  }
}

// Extension for easy access in widgets
extension SubscriptionManagerContext on BuildContext {
  SubscriptionManager get subscription => SubscriptionManager();

  /// Quick access to subscription status
  bool get isSubscribed => SubscriptionManager().isSubscribed;
  bool get hasPremiumAccess => SubscriptionManager().hasPremiumAccess;
  bool get hasEliteAccess => SubscriptionManager().hasEliteAccess;
  bool get hasVipAccess => SubscriptionManager().hasVipAccess;

  /// Quick feature checks
  bool get canAccessUnlimitedMessaging =>
      SubscriptionManager().canAccessUnlimitedMessaging;
  bool get canAccessPersonalMatchmaker =>
      SubscriptionManager().canAccessPersonalMatchmaker;
  bool get canAccessDateCoaching => SubscriptionManager().canAccessDateCoaching;
  bool get canAccessPriorityMatching =>
      SubscriptionManager().canAccessPriorityMatching;
  bool get canAccessBackgroundVerification =>
      SubscriptionManager().canAccessBackgroundVerification;
  bool get canAccessVipEvents => SubscriptionManager().canAccessVipEvents;
}

// Enhanced usage example widget
class SubscriptionStatusWidget extends StatelessWidget {
  const SubscriptionStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CustomerInfo>(
      stream: SubscriptionManager().customerInfoStream,
      builder: (context, snapshot) {
        final manager = SubscriptionManager();

        if (!manager.isSubscribed) {
          return Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderPrimary),
            ),
            child: Column(
              children: [
                Text('Unlock Premium Features', style: AppTextStyles.heading3),
                const SizedBox(height: 8),
                Text(
                  'Get unlimited matches and personal matchmaker support',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => manager.showSubscriptionSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primarySageGreen,
                  ),
                  child: Text(
                    'View Plans',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.cream,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Show subscription details for active subscribers
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.primaryGradient),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.verified, color: AppColors.cream, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${manager.currentTierName} Member',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.cream,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          manager.subscriptionStatus,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.cream.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Show expiry warning if needed
              if (manager.isSubscriptionExpiringSoon) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Subscription expires in ${manager.daysUntilExpiry} days',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.cream,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Show expiry date if available
              if (manager.formattedExpiryDate != null &&
                  !manager.isSubscriptionExpiringSoon) ...[
                const SizedBox(height: 8),
                Text(
                  'Renews ${manager.formattedExpiryDate}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.cream.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
