// lib/features/courtship/widgets/match_recommendation_card.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';
import '../../../core/shared/widgets/custom_button.dart';
import '../models/courtship_models.dart';

class MatchRecommendationCard extends StatelessWidget {
  final MatchRecommendation match;
  final VoidCallback onInitiateCourtship;
  final bool showTrustScore;

  const MatchRecommendationCard({
    super.key,
    required this.match,
    required this.onInitiateCourtship,
    this.showTrustScore = false,
  });

  static const Color _coralPink = Color(0xFFFF6B9D);
  static const Color _electricBlue = Color(0xFF4ECDC4);
  static const Color _sunsetOrange = Color(0xFFFFE66D);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: _electricBlue.withValues(alpha: 0.2),
                backgroundImage: _getProfileImage(),
                child:
                    _getProfileImage() == null
                        ? Text(
                          match.name.substring(0, 1).toUpperCase(),
                          style: AppTextStyles.heading3.copyWith(
                            color: _electricBlue,
                          ),
                        )
                        : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          match.name,
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.primaryDarkBlue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getScoreColor(
                              match.compatibilityScore.toInt(),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${match.compatibilityScore.toInt()}% match',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${match.age} • ${match.city}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMedium,
                      ),
                    ),
                    if (showTrustScore && match.trustScore != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.verified_user,
                            size: 16,
                            color: _getTrustScoreColor(
                              match.trustScore!.overallScore.toInt(),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Trust Score: ${match.trustScore!.overallScore.toInt()}/100',
                            style: AppTextStyles.caption.copyWith(
                              color: _getTrustScoreColor(
                                match.trustScore!.overallScore.toInt(),
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _sunsetOrange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Upgrade to see Trust Score',
                          style: AppTextStyles.caption.copyWith(
                            color: _sunsetOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'Shared Values',
            style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                match.sharedValues.map((value) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySageGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primarySageGreen.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Text(
                      value,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primarySageGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
          ),

          const SizedBox(height: 16),

          Text(
            'Compatible values and life goals make for meaningful connections.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDark,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Start Courtship',
              onPressed: onInitiateCourtship,
              type: ButtonType.primary,
              icon: Icons.favorite,
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: Safe method to get profile image
  ImageProvider? _getProfileImage() {
    if (match.photos.isNotEmpty && match.photos.first.isNotEmpty) {
      return NetworkImage(match.photos.first);
    }
    return null;
  }

  Color _getScoreColor(int score) {
    if (score >= 85) return const Color(0xFF4CAF50); // Green
    if (score >= 70) return _sunsetOrange; // Orange
    return _coralPink; // Pink
  }

  Color _getTrustScoreColor(int trustScore) {
    if (trustScore >= 80) return const Color(0xFF4CAF50); // Green
    if (trustScore >= 60) return _sunsetOrange; // Orange
    return _coralPink; // Pink
  }
}
