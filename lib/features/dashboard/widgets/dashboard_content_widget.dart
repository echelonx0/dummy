// lib/features/dashboard/widgets/dashboard_content.dart
import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';

import '../../../core/models/user_insights.dart';

import '../../courtship/widgets/psychological_readiness.dart';

import '../screens/features_carousel.dart';
import 'app_dashboard_header.dart';
import '../widgets/personal_growth_carousel_widget.dart';
import 'dashboard_action_handlers.dart';

class DashboardContent extends StatelessWidget {
  final String? userName;
  final String? userProfileImage;
  final bool hasNotifications;
  final bool isLoadingUserData;
  final bool isLoadingInsights;
  final UserInsights? userInsights;
  final String? insightsError;
  final VoidCallback onRetryInsights;

  const DashboardContent({
    super.key,
    required this.userName,
    required this.userProfileImage,
    required this.hasNotifications,
    required this.isLoadingUserData,
    required this.isLoadingInsights,
    required this.userInsights,
    required this.insightsError,
    required this.onRetryInsights,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // Enhanced Header
        DelayedDisplay(
          delay: const Duration(milliseconds: 100),
          child: _buildEnhancedHeader(context),
        ),

        // Premium Features Carousel
        const SizedBox(height: 24),

        !isLoadingInsights && userInsights!.hasData
            ? UnifiedFeaturesCarousel(userInsights: userInsights)
            : SizedBox.shrink(),
        const SizedBox(height: 24),

        // Personal Growth Carousel
        DelayedDisplay(
          delay: const Duration(milliseconds: 400),
          child: PersonalGrowthMediaCarousel(
            onLinkedInConnect:
                () => DashboardActionHandlers.handleLinkedInConnect(context),
            onJournalStart:
                () => DashboardActionHandlers.handleJournalStart(context),
            onCharacterSelect:
                () => DashboardActionHandlers.handleCharacterSelect(context),
          ),
        ),

        const SizedBox(height: 32),

        // Psychological Depths Card
        DelayedDisplay(
          delay: const Duration(milliseconds: 500),
          child: PsychologicalDepthsCard(
            onUnlockJourney:
                () =>
                    DashboardActionHandlers.handlePremiumPsychologyTap(context),
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildEnhancedHeader(BuildContext context) {
    if (isLoadingUserData) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return EnhancedDashboardHeader(
      userName: userName,
      userProfileImage: userProfileImage,
      hasNotifications: hasNotifications,
    );
  }
}
