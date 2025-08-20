// lib/features/onboarding/screens/premium_onboarding_screen.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../generated/l10n.dart';
import '../../../core/shared/widgets/custom_button.dart';

import 'readiness_assessment_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  48,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Exclusive positioning
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGold,
                          AppColors.primaryAccent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.invitationOnlyPremium,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Hero message focused on outcome, not features
                  Text(
                    l10n.mainHeadline,
                    style: AppTextStyles.heading1.copyWith(
                      fontWeight: FontWeight.w300,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Social proof with specific metrics
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.socialProofMessage,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.memberDescription,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMedium,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Create anticipation, not explanation
                  CustomButton(
                    text: l10n.beginExclusiveJourney,
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const ReadinessAssessmentScreen(),
                          ),
                        ),
                    type: ButtonType.primary,
                    icon: Icons.arrow_forward,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    l10n.processDisclaimer,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMedium,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ReadinessQuestion {
  final String question;
  final List<String> options;
  final bool filteringQuestion;

  ReadinessQuestion(
    this.question,
    this.options, {
    this.filteringQuestion = false,
  });
}
