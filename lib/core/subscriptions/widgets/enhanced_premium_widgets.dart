// lib/features/subscriptions/widgets/enhanced_premium_widgets.dart

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

import '../subscription_manager.dart';
import '../subscription_sheet.dart';

// ==========================================================================
// INLINE PREMIUM UPGRADE CARD - Insert anywhere
// ==========================================================================

class InlinePremiumUpgradeCard extends StatelessWidget {
  final String feature;
  final String description;
  final IconData icon;
  final VoidCallback? onUpgrade;

  const InlinePremiumUpgradeCard({
    super.key,
    required this.feature,
    required this.description,
    required this.icon,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGold.withValues(alpha: 0.1),
            AppColors.primarySageGreen.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onUpgrade ?? () => _showUpgradeSheet(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryGold, AppColors.primarySageGreen],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.backgroundDark, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          feature,
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.primaryAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'PREMIUM',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.backgroundDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primaryGold,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showUpgradeSheet(BuildContext context) async {
    await SubscriptionBottomSheet.show(
      context,
      onSubscriptionSelected: (plan) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome to $plan! Enjoy $feature.'),
            backgroundColor: AppColors.primarySageGreen,
          ),
        );
      },
    );
  }
}

// ==========================================================================
// PREMIUM FEATURE GATE - Wraps any widget
// ==========================================================================

class PremiumFeatureGate extends StatelessWidget {
  final Widget child;
  final Widget? lockedChild;
  final String featureName;
  final bool requiresElite;
  final bool requiresVip;

  const PremiumFeatureGate({
    super.key,
    required this.child,
    this.lockedChild,
    required this.featureName,
    this.requiresElite = false,
    this.requiresVip = false,
  });

  @override
  Widget build(BuildContext context) {
    final subscription = SubscriptionManager();

    // Check access level
    bool hasAccess = false;
    if (requiresVip) {
      hasAccess = subscription.hasVipAccess;
    } else if (requiresElite) {
      hasAccess = subscription.hasEliteAccess;
    } else {
      hasAccess = subscription.hasPremiumAccess;
    }

    if (hasAccess) {
      return child;
    }

    // Show locked version
    return lockedChild ?? _buildDefaultLockedWidget(context);
  }

  Widget _buildDefaultLockedWidget(BuildContext context) {
    String tierRequired =
        requiresVip
            ? 'Executive'
            : requiresElite
            ? 'Concierge'
            : 'Intentional';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
      ),
      child: Stack(
        children: [
          // Blurred/disabled content
          Opacity(opacity: 0.3, child: IgnorePointer(child: child)),

          // Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundDark.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, color: AppColors.primaryGold, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      '$tierRequired Required',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Unlock $featureName',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _showUpgradeSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: AppColors.backgroundDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('Upgrade'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showUpgradeSheet(BuildContext context) async {
    await SubscriptionBottomSheet.show(
      context,
      onSubscriptionSelected: (plan) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$featureName unlocked! Welcome to $plan.'),
            backgroundColor: AppColors.primarySageGreen,
          ),
        );
      },
    );
  }
}

// ==========================================================================
// QUOTA PROGRESS CARD - Show usage limits
// ==========================================================================

class QuotaProgressCard extends StatelessWidget {
  final String title;
  final int current;
  final int limit;
  final IconData icon;
  final String upgradeMessage;

  const QuotaProgressCard({
    super.key,
    required this.title,
    required this.current,
    required this.limit,
    required this.icon,
    required this.upgradeMessage,
  });

  @override
  Widget build(BuildContext context) {
    final progress = limit > 0 ? (current / limit).clamp(0.0, 1.0) : 0.0;
    final isNearLimit = progress > 0.8;
    final isAtLimit = current >= limit;

    return Card(
      color: AppColors.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryGold, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primaryAccent,
                  ),
                ),
                const Spacer(),
                Text(
                  '$current/$limit',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color:
                        isNearLimit
                            ? AppColors.primaryGold
                            : AppColors.textMedium,
                    fontWeight:
                        isNearLimit ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.textLight.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(
                isAtLimit
                    ? Colors.red
                    : isNearLimit
                    ? AppColors.primaryGold
                    : AppColors.primarySageGreen,
              ),
              borderRadius: BorderRadius.circular(4),
            ),

            if (isNearLimit) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: AppColors.primaryGold,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isAtLimit ? 'Limit reached' : 'Approaching limit',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showUpgradeOptions(context),
                    child: Text(
                      'Upgrade',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showUpgradeOptions(BuildContext context) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: Text(
              'Upgrade for More',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.primaryAccent,
              ),
            ),
            content: Text(
              upgradeMessage,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMedium,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Later'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  SubscriptionBottomSheet.show(
                    context,
                    onSubscriptionSelected: (plan) {
                      Navigator.pop(context);
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: AppColors.backgroundDark,
                ),
                child: Text('View Plans'),
              ),
            ],
          ),
    );
  }
}

// ==========================================================================
// QUICK ACCESS PREMIUM BUTTON - Floating action
// ==========================================================================

class PremiumFloatingButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const PremiumFloatingButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: SubscriptionManager().customerInfoStream,
      builder: (context, snapshot) {
        if (SubscriptionManager().hasPremiumAccess) {
          return const SizedBox.shrink(); // Hide if already premium
        }

        return FloatingActionButton.extended(
          onPressed: onPressed ?? () => _showUpgradeSheet(context),
          backgroundColor: AppColors.primaryGold,
          foregroundColor: AppColors.backgroundDark,
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Upgrade'),
        );
      },
    );
  }

  Future<void> _showUpgradeSheet(BuildContext context) async {
    await SubscriptionBottomSheet.show(
      context,
      onSubscriptionSelected: (plan) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome to $plan! 🎉'),
            backgroundColor: AppColors.primarySageGreen,
          ),
        );
      },
    );
  }
}


// lib/features/premium/widgets/premium_feature_card.dart

 