// lib/features/profile/widgets/profile_cards.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../services/profile_management_screen.dart';
import 'matchmaker_persona_card.dart';

class ProfileTrustScoreCard extends StatelessWidget {
  final double trustScore;
  final String trustScoreDescription;
  final VoidCallback onViewDetails;

  const ProfileTrustScoreCard({
    super.key,
    required this.trustScore,
    required this.trustScoreDescription,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primarySageGreen,
                    AppColors.primaryAccent.withValues(alpha: 0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primarySageGreen.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      trustScore.toInt().toString(),
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.primaryDarkBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Trust',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryDarkBlue,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feedback Score',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trustScoreDescription,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primarySageGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onViewDetails();
                },
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primarySageGreen,
                  size: 16,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Combined widget that includes the matchmaker card
class ProfileOverviewCards extends StatelessWidget {
  final ProfileData profileData;
  final String? currentPersona;
  final VoidCallback onViewTrustScoreDetails;
  final VoidCallback onImproveProfile;
  final VoidCallback? onPersonaChanged;

  const ProfileOverviewCards({
    super.key,
    required this.profileData,
    this.currentPersona,
    required this.onViewTrustScoreDetails,
    required this.onImproveProfile,
    this.onPersonaChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Matchmaker Persona Card (colorful, at the top)
        MatchmakerPersonaCard(
          currentPersona: currentPersona,
          onPersonaChanged: onPersonaChanged,
        ),

        // Trust Score Card
        ProfileTrustScoreCard(
          trustScore: profileData.trustScore,
          trustScoreDescription: _getTrustScoreDescription(
            profileData.trustScore,
          ),
          onViewDetails: onViewTrustScoreDetails,
        ),

        const SizedBox(height: 16),

        // Profile Completion Card
        ProfileCompletionCard(
          profileData: profileData,
          onImproveProfile: onImproveProfile,
        ),
      ],
    );
  }

  String _getTrustScoreDescription(double score) {
    if (score >= 80) return 'Excellent credibility with strong feedback';
    if (score >= 60) return 'Good reputation with positive references';
    if (score >= 40) return 'Building trust through authentic interactions';
    return 'New profile - establish credibility with feedback';
  }
}

class ProfileCard extends StatelessWidget {
  final Widget child;

  const ProfileCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primarySageGreen.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkBlue.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.primarySageGreen.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ProfileCompletionCard extends StatelessWidget {
  final ProfileData profileData;
  final VoidCallback onImproveProfile;

  const ProfileCompletionCard({
    super.key,
    required this.profileData,
    required this.onImproveProfile,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          profileData.isComplete
                              ? [
                                AppColors.success,
                                AppColors.success.withValues(alpha: 0.8),
                              ]
                              : [
                                AppColors.warning,
                                AppColors.warning.withValues(alpha: 0.8),
                              ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (profileData.isComplete
                                ? AppColors.success
                                : AppColors.warning)
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    profileData.isComplete ? Icons.check_circle : Icons.pending,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Completion',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profileData.isComplete
                            ? 'Your profile is complete! 🎉'
                            : '${profileData.completionPercentage.toInt()}% complete',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 🎯 FIXED: Progress bar with proper completion logic
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                // ✅ FIX: Show 100% if profile is complete, otherwise show actual percentage
                widthFactor:
                    profileData.isComplete
                        ? 1.0
                        : (profileData.completionPercentage / 100).clamp(
                          0.0,
                          1.0,
                        ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          profileData.isComplete
                              ? [
                                AppColors.success,
                                AppColors.success.withValues(alpha: 0.8),
                              ]
                              : [
                                AppColors.primarySageGreen,
                                AppColors.primaryAccent,
                              ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            if (!profileData.isComplete) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primarySageGreen.withValues(alpha: 0.1),
                        AppColors.primaryAccent.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primarySageGreen.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      onImproveProfile();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primarySageGreen,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_fix_high,
                          size: 18,
                          color: AppColors.primarySageGreen,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Improve Profile',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
