// lib/features/dashboard/widgets/dashboard_modal_handler.dart
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../core/models/user_insights.dart';
import '../../../core/utils/navigation_utils.dart';

import '../../insights/screens/insights_dashboard.dart';
import '../../growth/screens/growth_journey.dart';
import '../widgets/philosophy_modal.dart';

class DashboardModalHandler {
  static void showPhilosophyModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.95,
      ),
      builder:
          (context) => Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primarySageGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Our Philosophy',
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.primaryDarkBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          color: AppColors.textMedium,
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      child: PhilosophyModalContent(),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  static void showInsightsModal(
    BuildContext context, {
    required bool isLoadingInsights,
    required String? insightsError,
    required UserInsights? userInsights,
    required VoidCallback onRetry,
    required String userFirstName,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.95,
      ),
      builder:
          (context) => Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primarySageGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.psychology,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Personality Analysis',
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.primaryDarkBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          color: AppColors.textMedium,
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      child: InsightsTab(
                        isLoadingInsights: isLoadingInsights,
                        insightsError: insightsError,
                        userInsights: userInsights,
                        onRetry: onRetry,
                        userFirstName: userFirstName,
                        isInModal: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  static void showGrowthModal(BuildContext context) {
    NavigationUtils.showCustomModal(
      context: context,
      title: 'Growth Journey',
      content: EnhancedGrowthJourneyScreen(),
    );
  }

  static void showJournalModal(BuildContext context) {
    NavigationUtils.showCustomModal(
      context: context,
      title: 'Growth Journal',
      content: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_note, color: AppColors.primaryGold, size: 64),
            const SizedBox(height: 16),
            Text(
              'Start Your Daily Reflection',
              style: AppTextStyles.heading3.copyWith(color: AppColors.textDark),
            ),
            const SizedBox(height: 12),
            Text(
              'Journaling helps build self-awareness and relationship readiness. Coming soon!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMedium,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static void showPremiumPsychologyModal(BuildContext context) {
    NavigationUtils.showCustomModal(
      context: context,
      title: 'Premium Psychology',
      content: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.psychology_outlined,
              color: AppColors.primarySageGreen,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Unlock Deeper Insights',
              style: AppTextStyles.heading3.copyWith(color: AppColors.textDark),
            ),
            const SizedBox(height: 12),
            Text(
              'Get professional-grade psychological analysis, shadow work sessions, and 1-on-1 coaching. Premium feature coming soon!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMedium,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
