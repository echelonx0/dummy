// lib/features/dashboard/widgets/premium_unlock_widgets.dart

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../models/user_insights.dart';

// ==========================================================================
// SHIMMER EFFECT COMPONENT
// ==========================================================================

class PremiumShimmerEffect extends StatelessWidget {
  final AnimationController controller;
  final double shimmerValue;

  const PremiumShimmerEffect({
    super.key,
    required this.controller,
    required this.shimmerValue,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.transparent,
                AppColors.primaryGold.withValues(
                  alpha: (0.1 * shimmerValue).clamp(0.0, 1.0),
                ),
                Colors.transparent,
              ],
              stops: [
                (shimmerValue - 0.3).clamp(0.0, 1.0),
                shimmerValue.clamp(0.0, 1.0),
                (shimmerValue + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==========================================================================
// PREMIUM CARD HEADER
// ==========================================================================

class PremiumCardHeader extends StatelessWidget {
  final bool hasUsedFreeView;

  const PremiumCardHeader({super.key, required this.hasUsedFreeView});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryGold, AppColors.primarySageGreen],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.auto_awesome,
            color: AppColors.backgroundDark,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'PREMIUM',
                      style: AppTextStyles.caption.copyWith(
                        color: Color(0xff03A6A1),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (!hasUsedFreeView)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySageGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'FREE PREVIEW',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Deep Psychological Insights',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================================================
// PREMIUM PREVIEW CONTENT
// ==========================================================================

class PremiumPreviewContent extends StatelessWidget {
  final UserInsights userInsights;

  const PremiumPreviewContent({super.key, required this.userInsights});

  @override
  Widget build(BuildContext context) {
    if (userInsights.intellectualAssessment != null) {
      return _buildPreviewInsight(
        '🧠 Intellectual Assessment',
        'IQ: ${userInsights.intellectualAssessment!.estimatedIQ} (${userInsights.intellectualAssessment!.iqRange})',
        userInsights.intellectualAssessment!.reasoning,
      );
    } else if (userInsights.astrologicalProfile != null) {
      return _buildPreviewInsight(
        '✨ Astrological Profile',
        userInsights.astrologicalProfile!.fullAstroDescription,
        userInsights
            .astrologicalProfile!
            .relationshipAstrology
            .loveLanguageConnection,
      );
    } else {
      return _buildPreviewInsight(
        '💎 Enhanced Analysis',
        'Advanced personality insights available',
        'Discover deeper patterns in your communication style, emotional intelligence, and relationship compatibility.',
      );
    }
  }

  Widget _buildPreviewInsight(
    String title,
    String subtitle,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGold.withValues(alpha: 0.1),
            AppColors.primarySageGreen.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryButtonText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primaryAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description.length > 120
                ? '${description.substring(0, 120)}...'
                : description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMedium,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// PREMIUM ACTION BUTTON
// ==========================================================================

class PremiumActionButton extends StatelessWidget {
  final bool canAccessPremium;
  final bool hasUsedFreeView;
  final int referralCount;
  final int communityCredits;
  final VoidCallback onPressed;

  const PremiumActionButton({
    super.key,
    required this.canAccessPremium,
    required this.hasUsedFreeView,
    required this.referralCount,
    required this.communityCredits,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              canAccessPremium ? AppColors.primaryGold : Color(0xffFFB3B3),
          foregroundColor: AppColors.backgroundDark,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(canAccessPremium ? Icons.lock_open : Icons.lock, size: 20),
            const SizedBox(width: 8),
            Text(
              _getButtonText(),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color:
                    canAccessPremium
                        ? AppColors.backgroundDark
                        : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getButtonText() {
    if (!hasUsedFreeView) return 'View Premium Insights FREE';
    if (referralCount >= 3) return 'Access Premium (Referrals Unlocked)';
    if (communityCredits >= 50) return 'Access Premium (Credits Unlocked)';
    return 'Unlock Premium Insights';
  }
}

// ==========================================================================
// PREMIUM PROGRESS INDICATORS
// ==========================================================================

class PremiumProgressIndicators extends StatelessWidget {
  final int referralCount;
  final int communityCredits;

  const PremiumProgressIndicators({
    super.key,
    required this.referralCount,
    required this.communityCredits,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildProgressRow(
          'Invite Friends',
          referralCount,
          3,
          '👥',
          AppColors.primarySageGreen,
        ),
        const SizedBox(height: 8),
        _buildProgressRow(
          'Community Credits',
          communityCredits,
          50,
          '⭐',
          AppColors.primaryGold,
        ),
      ],
    );
  }

  Widget _buildProgressRow(
    String label,
    int current,
    int target,
    String emoji,
    Color color,
  ) {
    final progress = (current / target).clamp(0.0, 1.0);

    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$current/$target',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(color),
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================================================
// PREMIUM MODAL HEADER
// ==========================================================================

class PremiumModalHeader extends StatelessWidget {
  const PremiumModalHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryGold, AppColors.primarySageGreen],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.auto_awesome,
            color: AppColors.backgroundDark,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unlock Premium Insights',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Choose your path to deeper understanding',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================================================
// COMMUNITY CREDITS DIALOG - STANDALONE COMPONENT
// ==========================================================================

class CommunityCreditsDialog extends StatelessWidget {
  const CommunityCreditsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.volunteer_activism, color: AppColors.primaryGold),
          const SizedBox(width: 8),
          Text(
            'Community Credits',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.primaryAccent,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earn premium access by contributing to your community!',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),
          ),
          const SizedBox(height: 16),
          _buildCreditFeature('🌱', 'Community cleanups'),
          _buildCreditFeature('📚', 'School assistance'),
          _buildCreditFeature('👥', 'Elder care support'),
          _buildCreditFeature('🏗️', 'Neighborhood improvement'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryGold.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              '50 credits = Premium access for 1 month\n₦404 per hour of community service',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryGold,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Coming Soon!',
            style: TextStyle(color: AppColors.primarySageGreen),
          ),
        ),
      ],
    );
  }

  Widget _buildCreditFeature(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textDark),
          ),
        ],
      ),
    );
  }
}
