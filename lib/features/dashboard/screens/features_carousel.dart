// lib/features/dashboard/widgets/unified_features_carousel.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:khedoo/features/dashboard/widgets/feature_card.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../core/models/premium_feature.dart';
import '../../../core/models/user_insights.dart';
import '../../../core/shared/theme/premium_gradient_colors.dart';
// import '../../../core/subscriptions/subscription_manager.dart';

import '../../account/widgets/advanced_profile_modal.dart';
import '../../advanced/advanced_personalisation/utils/launcher.dart';
import '../../advanced/assessments/assessment_service.dart';
import '../../advanced/events/events_screen.dart';
import '../widgets/dashboard_modal_handlers.dart';

class UnifiedFeaturesCarousel extends StatefulWidget {
  final VoidCallback? onPhilosophyTap;
  final VoidCallback? onGrowthTap;
  final VoidCallback? onMessagingTap;
  final VoidCallback? onMatchesTap;
  final VoidCallback? onProfileOptimizationTap;
  final VoidCallback? onMatchmakerTap;
  final UserInsights? userInsights;

  const UnifiedFeaturesCarousel({
    super.key,
    this.onPhilosophyTap,
    this.onGrowthTap,
    this.onMessagingTap,
    this.onMatchesTap,
    this.onProfileOptimizationTap,
    this.onMatchmakerTap,
    this.userInsights,
  });

  @override
  State<UnifiedFeaturesCarousel> createState() =>
      _UnifiedFeaturesCarouselState();
}

class _UnifiedFeaturesCarouselState extends State<UnifiedFeaturesCarousel>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  // final _subscriptionManager = SubscriptionManager();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  // 🎲 RANDOMIZED FEATURES - Shuffled each build
  List<PremiumFeature> get _allFeatures {
    final features = _createAllFeatures();
    features.shuffle(Random());
    return features;
  }

  // 📊 BASE FEATURE DEFINITIONS
  List<PremiumFeature> _createAllFeatures() => [
    // 💎 ELITE TIER - Highest revenue potential
    PremiumFeature(
      id: 'personal_matchmaker',
      title: 'Personal\nMatchmaker',
      subtitle: '1:1 expert guidance',
      icon: Icons.psychology_alt,
      gradient: PremiumFeatureColors.inkBlack,
      requiredTier: SubscriptionTier.concierge,
      action: PremiumFeatureAction.matchmaker,
      ctaText: 'Book Session',
    ),

    // 🆓 FREE TIER - User acquisition & engagement
    PremiumFeature(
      id: 'philosophy',
      title: 'Dating\nPhilosophy',
      subtitle: 'Your values guide',
      icon: Icons.favorite_border,
      gradient: PremiumFeatureColors.charcoalBronze,
      requiredTier: SubscriptionTier.free,
      action: PremiumFeatureAction.philosophy,
      ctaText: 'Explore Values',
    ),

    PremiumFeature(
      id: 'basic_insights',
      title: 'Your\nInsights',
      subtitle: _getInsightsSubtitle(),
      icon: Icons.psychology_outlined,
      gradient: PremiumFeatureColors.charcoalBronze,
      requiredTier: SubscriptionTier.free,
      action: PremiumFeatureAction.basicInsights,
      ctaText: _getInsightsCTA(),
    ),

    PremiumFeature(
      id: 'advanced_profile',
      title: 'Advanced\nProfile',
      subtitle: 'Social links & authenticity',
      icon: Icons.person_add_alt_1,
      gradient: PremiumFeatureColors.graphiteSteel,
      requiredTier: SubscriptionTier.free,
      action: PremiumFeatureAction.profileBuilder,
      ctaText: 'Add Links',
    ),

    PremiumFeature(
      id: 'limited_messaging',
      title: '3 Daily\nMessages',
      subtitle: 'Start conversations',
      icon: Icons.chat_bubble_outline,
      gradient: PremiumFeatureColors.charcoalBronze,
      requiredTier: SubscriptionTier.free,
      action: PremiumFeatureAction.limitedMessaging,
      ctaText: 'Send Message',
    ),

    PremiumFeature(
      id: 'events',
      title: 'Dating\nEvents',
      subtitle: 'Meet in real life',
      icon: Icons.event,
      gradient: PremiumFeatureColors.charcoalBronze,
      requiredTier: SubscriptionTier.free,
      action: PremiumFeatureAction.events,
      ctaText: 'Browse Events',
    ),

    PremiumFeature(
      id: 'assessment_choice',
      title: 'Find Your\nType',
      subtitle: 'Psychology & worldview',
      icon: Icons.psychology_alt,
      gradient: PremiumFeatureColors.charcoalBronze,
      requiredTier: SubscriptionTier.free,
      action: PremiumFeatureAction.assessment,
      ctaText: 'Take Assessment',
    ),

    PremiumFeature(
      id: 'curated_matches',
      title: 'Enhanced Matching',
      subtitle: 'Quality over quantity',
      icon: Icons.favorite,
      gradient: PremiumFeatureColors.charcoalBronze,
      requiredTier: SubscriptionTier.free,
      action: PremiumFeatureAction.matches,
      ctaText: 'Enhance your matches',
    ),
  ];

  // 📱 DYNAMIC CONTENT BASED ON USER STATE
  String _getInsightsSubtitle() {
    if (widget.userInsights?.hasData == true) {
      return 'AI generated insights about you';
    }
    return 'Discover your patterns';
  }

  String _getInsightsCTA() {
    if (widget.userInsights?.hasData == true) {
      return 'View Insights';
    }
    return 'Generate Insights';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🏷️ Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore Features',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 🎠 RANDOMIZED FEATURES CAROUSEL
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _allFeatures.length,
            itemBuilder: (context, index) {
              final feature = _allFeatures[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index == _allFeatures.length - 1 ? 0 : 16,
                ),
                child: GestureDetector(
                  onTap: () => _handleFeatureTap(feature),
                  child: FeatureCard(
                    feature: feature,
                    pulseController: _pulseController,
                    shimmerController: _shimmerController,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  // 🎯 FEATURE TAP HANDLING (unchanged core logic)
  void _handleFeatureTap(PremiumFeature feature) {
    switch (feature.action) {
      case PremiumFeatureAction.philosophy:
        DashboardModalHandler.showPhilosophyModal(context);
        break;

      case PremiumFeatureAction.basicInsights:
        _showBasicInsights();
        break;

      case PremiumFeatureAction.profileBuilder:
        _showAdvancedProfileModal();
        break;

      case PremiumFeatureAction.limitedMessaging:
        _navigateToMessaging();
        break;

      case PremiumFeatureAction.events:
        _navigateToEvents();
        break;
      case PremiumFeatureAction.assessment:
        AssessmentModalService.showAssessmentChoice(context);
        break;
      case PremiumFeatureAction.matches:
        PersonalizationLauncher.launch(context);
      default:
        // Premium features handled by FeatureCard
        break;
    }
  }

  void _showBasicInsights() {
    DashboardModalHandler.showInsightsModal(
      context,
      isLoadingInsights: false,
      insightsError: null,
      userInsights: widget.userInsights,
      onRetry: () {
        if (context.mounted) {
          // Retrigger loading via dashboard controller
        }
      },
      userFirstName: '',
    );
  }

  void _showAdvancedProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => AdvancedProfileModal(
            onLinksUpdated: () {
              if (mounted) {
                setState(() {
                  // Refresh profile completion indicators
                });
              }
            },
          ),
    );
  }

  void _navigateToMessaging() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('3 messages remaining today! 💬'),
        backgroundColor: AppColors.primarySageGreen,
      ),
    );
  }

  void _navigateToEvents() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const EventsScreen()));
  }

  // 🏷️ ACCESS INDICATOR BUILDER (unchanged)
}
