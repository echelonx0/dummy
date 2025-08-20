// lib/features/dashboard/widgets/insights_tab.dart (UPDATED)
import 'package:flutter/material.dart';
import '../../../admin/feature_flags/feature_flag_builder.dart';
import '../../../constants/app_colors.dart';
import '../../../core/models/user_insights.dart';
import '../../../app/dashboard/dashboard_empty_states.dart';
import '../widgets/insights_widgets.dart';
import '../../../core/subscriptions/widgets/premium_unlock_card.dart';
import 'psych_preview_card.dart';

class InsightsTab extends StatelessWidget {
  final bool isLoadingInsights;
  final String? insightsError;
  final UserInsights? userInsights;
  final VoidCallback onRetry;
  final String? userFirstName;
  final bool isInModal;
  final VoidCallback? onUnlockPremium;

  const InsightsTab({
    super.key,
    required this.isLoadingInsights,
    required this.insightsError,
    required this.userInsights,
    required this.onRetry,
    this.userFirstName,
    this.isInModal = false,
    this.onUnlockPremium,
  });

  @override
  Widget build(BuildContext context) {
    // Modal version - no scroll, no padding
    if (isInModal) {
      return Column(
        children: [
          if (isLoadingInsights)
            DashboardEmptyStates.loadingSkeleton()
          else if (insightsError != null)
            InsightsErrorCard(
              title: 'Unable to Load Insights',
              message: insightsError!,
              onRetry: onRetry,
            )
          else if (userInsights == null || !userInsights!.hasData)
            DashboardEmptyStates.emptyInsights(onRetry: onRetry)
          else
            _buildInsightsContent(),
        ],
      );
    }

    // Original version for tab view
    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      color: AppColors.primarySageGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (isLoadingInsights)
              DashboardEmptyStates.loadingSkeleton()
            else if (insightsError != null)
              InsightsErrorCard(
                title: 'Unable to Load Insights',
                message: insightsError!,
                onRetry: onRetry,
              )
            else if (userInsights == null || !userInsights!.hasData)
              DashboardEmptyStates.emptyInsights(onRetry: onRetry)
            else
              _buildInsightsContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsContent() {
    return Column(
      children: [
        const SizedBox(height: 16),

        // Relationship Readiness Card
        InsightsAnimatedCard(
          delay: 100,
          child: RelationshipReadinessCard(
            userInsights: userInsights!,
            userFirstName: userFirstName,
          ),
        ),

        const SizedBox(height: 16),

        // Strengths Card
        if (userInsights!.strengths.isNotEmpty)
          InsightsAnimatedCard(
            delay: 200,
            child: StrengthsCard(
              strengths: userInsights!.strengths,
              userFirstName: userFirstName,
            ),
          ),

        const SizedBox(height: 16),

        // Growth Areas Card
        if (userInsights!.growthAreas.isNotEmpty)
          InsightsAnimatedCard(
            delay: 300,
            child: GrowthAreasCard(
              growthAreas: userInsights!.growthAreas,
              userFirstName: userFirstName,
            ),
          ),

        const SizedBox(height: 16),

        // ✅ NEW: Psychological Depths Card - Prime real estate!
        PsychologicalInsightsWidget(userInsights: userInsights),
        const SizedBox(height: 32),
        // Premium Unlock Card (existing)
        FeatureFlagBuilder(
          flagId: 'show_premium_banner',
          child: InsightsAnimatedCard(
            delay: 400,
            child: PremiumUnlockCard(
              userInsights: userInsights,
              userFirstName: userFirstName,
            ),
          ),
        ),
      ],
    );
  }
}
