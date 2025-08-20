// lib/features/assessments/services/assessment_modal_service.dart

import 'package:flutter/material.dart';

import '../../../core/shared/widgets/action_modal_widget.dart';
import '../assessment_trigger.dart';

class AssessmentModalService {
  // 🎯 Primary method: Shows assessment selection using Action Modal System
  static void showAssessmentChoice(
    BuildContext context, {
    VoidCallback? onComplete,
    bool showPremiumUpgrade = false,
  }) {
    ActionModalController.show(
      context: context,
      style: ActionModalStyle.center,
      type: ActionModalType.feature,
      data: ActionModalData(
        headline: 'Discover Your Match Profile',
        subheadline: 'Choose your path to deeper connections',
        ctaText: 'Start Assessment',
        onAction: () => _showDetailedAssessmentModal(context, onComplete),
        badge: 'Free for all users',
        gradientColors: [const Color(0xFF6B73FF), const Color(0xFF9C27B0)],
        illustration: _buildAssessmentIllustration(),
      ),
    );
  }

  // 🎨 Shows the detailed assessment gateway modal
  static Future<void> _showDetailedAssessmentModal(
    BuildContext context,
    VoidCallback? onComplete,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => AssessmentGatewayModal(onClose: onComplete),
    );
  }

  // 🚀 Direct psychology assessment trigger
  static Future<void> showPsychologyAssessment(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder:
          (context) =>
              AssessmentGatewayModal(initialType: AssessmentType.psychology),
    );
  }

  // 🌍 Direct worldview assessment trigger
  static Future<void> showWorldviewAssessment(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder:
          (context) =>
              AssessmentGatewayModal(initialType: AssessmentType.worldview),
    );
  }

  // 💰 Premium upsell version
  static void showPremiumAssessmentPrompt(BuildContext context) {
    ActionModalController.show(
      context: context,
      style: ActionModalStyle.card,
      type: ActionModalType.premium,
      data: ActionModalData(
        headline: 'Unlock Advanced Assessments',
        subheadline:
            'Get deeper insights and compatibility scores with premium assessments',
        ctaText: 'Upgrade to Premium',
        onAction: () => _navigateToPremium(context),
        onDismiss: () => showAssessmentChoice(context),
        badge: 'Premium Feature',
        gradientColors: [const Color(0xFFFFD700), const Color(0xFFFFA500)],
      ),
    );
  }

  // 🎯 Post-completion success modal
  static void showAssessmentComplete(
    BuildContext context, {
    required String assessmentType,
    VoidCallback? onViewResults,
  }) {
    ActionModalController.show(
      context: context,
      style: ActionModalStyle.card,
      type: ActionModalType.achievement,
      data: ActionModalData(
        headline: '$assessmentType Complete!',
        subheadline:
            'Your profile is now more attractive to compatible matches',
        ctaText: 'View Your Results',
        onAction: () {
          Navigator.of(context).pop();
          onViewResults?.call();
        },
        badge: 'Profile Enhanced',
        illustration: _buildSuccessIllustration(),
      ),
    );
  }

  // 📱 Context-aware triggers
  static void showContextualAssessmentPrompt(
    BuildContext context,
    String triggerContext,
  ) {
    String headline;
    String subheadline;

    switch (triggerContext) {
      case 'profile_completion':
        headline = 'Complete Your Profile';
        subheadline = 'Add assessment data to get 3x more quality matches';
        break;
      case 'low_matches':
        headline = 'Improve Your Matches';
        subheadline = 'Assessment data helps us find your perfect match type';
        break;
      case 'first_week':
        headline = 'Week 1 Bonus';
        subheadline = 'Complete assessments to unlock premium features';
        break;
      default:
        headline = 'Discover Your Match Profile';
        subheadline = 'Take assessments to improve compatibility';
    }

    ActionModalController.show(
      context: context,
      style: ActionModalStyle.card,
      type: ActionModalType.onboarding,
      data: ActionModalData(
        headline: headline,
        subheadline: subheadline,
        ctaText: 'Start Assessment',
        onAction: () => showAssessmentChoice(context),
        isDismissible: triggerContext != 'profile_completion',
      ),
    );
  }

  // 🎨 Helper: Assessment illustration
  static Widget _buildAssessmentIllustration() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6B73FF).withValues(alpha: 0.2),
            const Color(0xFF9C27B0).withValues(alpha: 0.1),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.psychology_alt,
        size: 60,
        color: Color(0xFF6B73FF),
      ),
    );
  }

  // 🎉 Helper: Success illustration
  static Widget _buildSuccessIllustration() {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        color: Color(0xFF4CAF50),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_circle_outline,
        size: 50,
        color: Colors.white,
      ),
    );
  }

  // 🔄 Helper: Premium navigation
  static void _navigateToPremium(BuildContext context) {
    Navigator.of(context).pushNamed('/premium-subscription');
  }
}

// 🎯 Extension for easy context-based triggering
extension AssessmentTriggers on BuildContext {
  void showAssessmentModal() =>
      AssessmentModalService.showAssessmentChoice(this);

  void showPsychologyAssessment() =>
      AssessmentModalService.showPsychologyAssessment(this);

  void showWorldviewAssessment() =>
      AssessmentModalService.showWorldviewAssessment(this);
}
