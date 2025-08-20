// ================================
// PHASE 3: EXCLUSIVE COMMUNITY WELCOME
// ================================
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../core/shared/widgets/custom_button.dart';
import '../../../generated/l10n.dart';
import '../../profile/screens/profile_creation_screen.dart';

class WelcomeToExclusiveCommunityScreen extends StatelessWidget {
  const WelcomeToExclusiveCommunityScreen({super.key});

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
                  const SizedBox(height: 60),
                  // Exclusive welcome
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGold,
                          AppColors.primaryAccent,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.verified,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    l10n.welcomeExclusiveCommunity,
                    style: AppTextStyles.heading1.copyWith(
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    l10n.acceptedCommunityMessage,
                    style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Set expectations for the premium experience
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.whatHappensNext,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildExpectationItem(l10n.expectationStep1),
                        _buildExpectationItem(l10n.expectationStep2),
                        _buildExpectationItem(l10n.expectationStep3),
                        _buildExpectationItem(l10n.expectationStep4),
                      ],
                    ),
                  ),

                  const Spacer(),

                  CustomButton(
                    text: l10n.createPremiumProfile,
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileCreationScreen(),
                          ),
                        ),
                    type: ButtonType.primary,
                    icon: Icons.arrow_forward,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    l10n.averageTimeAndSatisfaction,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMedium,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpectationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}
