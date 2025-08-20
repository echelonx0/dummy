// lib/features/profile/widgets/profile_photo_display.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

// lib/features/profile/widgets/trust_score_display.dart
class TrustScoreDisplay extends StatelessWidget {
  final double trustScore;
  final String trustTrend;
  final VoidCallback onViewDetails;

  const TrustScoreDisplay({
    super.key,
    required this.trustScore,
    required this.trustTrend,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final Color scoreColor = _getScoreColor(trustScore);
    final String scoreLabel = _getScoreLabel(trustScore);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scoreColor.withValues(alpha: 0.1),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    trustScore.toInt().toString(),
                    style: AppTextStyles.heading3.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Trust',
                    style: AppTextStyles.caption.copyWith(
                      color: scoreColor,
                      fontSize: 10,
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
                  'Trust Score',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  scoreLabel,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onViewDetails,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.arrow_forward_ios, color: scoreColor, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return const Color(0xFF95E1A3); // Mint green
    if (score >= 60) return const Color(0xFFFFE66D); // Sunset orange
    return const Color(0xFFFF6B9D); // Coral pink
  }

  String _getScoreLabel(double score) {
    if (score >= 90) return 'Excellent standing';
    if (score >= 80) return 'Good standing';
    if (score >= 60) return 'Fair standing';
    if (score >= 40) return 'Needs improvement';
    return 'Low standing';
  }
}
