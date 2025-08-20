// lib/features/premium/utils/premium_unlock_helper.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../core/models/user_insights.dart';
import '../../features/insights/screens/premium_insights_dashboard.dart';
import '../shared/widgets/action_modal_widget.dart';

class PremiumUnlockHelper {
  /// Shows premium unlock modal for psychological insights
  static void showPsychologicalUnlock({
    required BuildContext context,
    UserInsights? userInsights,
    String? userFirstName,
  }) {
    ActionModalController.show(
      context: context,
      style: ActionModalStyle.card,
      type: ActionModalType.premium,
      data: ActionModalData(
        headline: 'Unlock Your Complete Psychological Profile',
        subheadline:
            'Professional-grade analysis including IQ assessment, attachment patterns, and relationship compatibility factors',
        ctaText: 'Start Premium Analysis',
        badge: 'DEEP INSIGHTS',
        onAction: () {
          if (userInsights != null && userInsights.hasEnhancedData) {
            // User already has premium insights - show them
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => PremiumInsightsDashboard(
                      userInsights: userInsights,
                      userFirstName: userFirstName,
                    ),
              ),
            );
          } else {
            // Navigate to subscription flow or premium onboarding
            _showSubscriptionFlow(context);
          }
        },
        onDismiss: () {
          // Track dismissal for analytics
          _trackPremiumDismissal('psychological_insights');
        },
        gradientColors: [
          AppColors.primarySageGreen,
          AppColors.primaryGold,
          AppColors.primarySageGreen.withValues(alpha: 0.8),
        ],
        illustration: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.psychology_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }

  /// Shows premium unlock for courtship features
  static void showCourtshipUnlock({
    required BuildContext context,
    String? userFirstName,
  }) {
    ActionModalController.show(
      context: context,
      style: ActionModalStyle.fullOverlay,
      type: ActionModalType.premium,
      data: ActionModalData(
        headline: 'Unlock AI-Guided Courtship',
        subheadline:
            'Experience our revolutionary 14-day structured dating journey with professional relationship coaching',
        ctaText: 'Start Courtship Journey',
        badge: 'EXCLUSIVE FEATURE',
        onAction: () {
          _showSubscriptionFlow(context, feature: 'courtship');
        },
        gradientColors: [
          AppColors.primaryDarkBlue,
          AppColors.primarySageGreen,
          AppColors.primaryGold,
        ],
        illustration: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_outlined,
                size: 80,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(height: 16),
              Text(
                '14-Day Journey',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows general premium upgrade modal
  static void showGeneralUpgrade({
    required BuildContext context,
    String? userFirstName,
    String? customHeadline,
    String? customSubheadline,
  }) {
    ActionModalController.show(
      context: context,
      style: ActionModalStyle.card,
      type: ActionModalType.premium,
      data: ActionModalData(
        headline: customHeadline ?? 'Upgrade to Premium',
        subheadline:
            customSubheadline ??
            'Unlock advanced features and personalized coaching to accelerate your journey to meaningful relationships',
        ctaText: 'See Premium Features',
        onAction: () {
          _showSubscriptionFlow(context);
        },
        gradientColors: [AppColors.primaryGold, AppColors.primarySageGreen],
        illustration: Icon(
          Icons.auto_awesome,
          size: 72,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  /// Navigate to subscription flow
  static void _showSubscriptionFlow(BuildContext context, {String? feature}) {
    // TODO: Replace with your actual subscription screen
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Premium Coming Soon!',
              style: TextStyle(color: AppColors.textDark),
            ),
            content: Text(
              'Premium psychological insights and courtship features are launching soon. You\'ll be notified when they\'re available!',
              style: TextStyle(color: AppColors.textMedium),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Got It',
                  style: TextStyle(color: AppColors.primarySageGreen),
                ),
              ),
            ],
          ),
    );

    // Track subscription flow entry
    _trackSubscriptionFlow(feature ?? 'general');
  }

  /// Track premium dismissal for analytics
  static void _trackPremiumDismissal(String feature) {
    // TODO: Add your analytics tracking
    print('Premium dismissed: $feature');
  }

  /// Track subscription flow entry
  static void _trackSubscriptionFlow(String feature) {
    // TODO: Add your analytics tracking
    print('Subscription flow entered: $feature');
  }

  /// Check if user has premium access
  static bool hasValidPremiumSubscription() {
    // TODO: Implement actual premium check
    return false;
  }

  /// Get premium features based on subscription tier
  static List<String> getPremiumFeatures() {
    return [
      'Complete psychological analysis',
      'IQ and cognitive assessment',
      'Attachment style deep dive',
      'Astrological compatibility',
      'AI-guided courtship journey',
      'Professional relationship coaching',
      'Advanced matching algorithms',
      'Priority customer support',
    ];
  }

  /// Show premium features list
  static void showPremiumFeatures(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textMedium,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Premium Features',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Features list
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children:
                        getPremiumFeatures().map((feature) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primaryGold.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGold,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: TextStyle(
                                      color: AppColors.textDark,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),

                // CTA
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showSubscriptionFlow(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primarySageGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Get Premium Access',
                        style: TextStyle(
                          color: AppColors.primaryAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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
