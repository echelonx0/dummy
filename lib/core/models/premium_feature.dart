// lib/core/models/premium_feature.dart
import 'package:flutter/widgets.dart';

class PremiumFeature {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final SubscriptionTier requiredTier;
  final PremiumFeatureAction action;
  final String ctaText;

  const PremiumFeature({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.requiredTier,
    required this.action,
    required this.ctaText,
  });
}

// UPDATED: Added FREE tier
enum SubscriptionTier {
  free, // NEW: Completely free features
  intentional, // Premium subscription
  concierge, // Elite tier
  executive, // VIP tier
}

enum SubscriptionPlan { premium, elite, vip }

// UPDATED: Added FREE actions
enum PremiumFeatureAction {
  // FREE ACTIONS
  philosophy, // View dating philosophy
  basicInsights, // Basic personality insights
  profileBuilder, // Basic profile creation
  limitedMessaging, // 3 messages per day
  // PREMIUM ACTIONS
  messaging,
  matches,
  profileOptimization,
  matchmaker,
  coaching,
  priorityMatching,
  verification,
  vipEvents,
  founderAccess,
  surprise,
  deepDive,
  events,
  assessment,
}
