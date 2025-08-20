// lib/features/courtship/widgets/trust_score_widget.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';
import '../models/courtship_models.dart';

class TrustScoreWidget extends StatelessWidget {
  final TrustScore? trustScore;
  final bool isLoading;

  const TrustScoreWidget({super.key, this.trustScore, required this.isLoading});

  static const Color _coralPink = Color(0xFFFF6B9D);
  static const Color _electricBlue = Color(0xFF4ECDC4);
  static const Color _mintGreen = Color(0xFF95E1A3);
  static const Color _sunsetOrange = Color(0xFFFFE66D);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingCard();
    }

    if (trustScore == null) {
      return _buildErrorCard();
    }

    return _buildTrustScoreCard();
  }

  Widget _buildLoadingCard() {
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
      child: Row(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_electricBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Calculating your trust score...',
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
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
        children: [
          Icon(Icons.error_outline, color: _coralPink, size: 48),
          const SizedBox(height: 12),
          Text(
            'Trust Score Unavailable',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.primaryDarkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete more courtships to build your trust score',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMedium,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrustScoreCard() {
    final score = trustScore!.overallScore.toInt();
    final color = _getScoreColor(score);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.verified_user,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trust Score',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.primaryDarkBlue,
                      ),
                    ),
                    Text(
                      _getScoreDescription(score),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$score/100',
                  style: AppTextStyles.heading3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // FIXED: Use SingleChildScrollView for metrics to prevent overflow
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildMetricItem(
                  'Completion Rate',
                  '${(trustScore!.completionRate * 100).toInt()}%',
                  Icons.task_alt,
                ),
                const SizedBox(width: 16),
                _buildMetricItem(
                  'Average Rating',
                  '${trustScore!.averageRating.toStringAsFixed(1)}/5',
                  Icons.star,
                ),
                const SizedBox(width: 16),
                _buildMetricItem(
                  'Response Time',
                  _getResponseTimeText(trustScore!.responseTime),
                  Icons.speed,
                ),
              ],
            ),
          ),

          if (trustScore!.trend == 'improving') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _mintGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up, color: _mintGreen, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your trust score is improving! 📈',
                      style: AppTextStyles.caption.copyWith(
                        color: _mintGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return SizedBox(
      width: 100, // Fixed width to prevent overflow
      child: Column(
        children: [
          Icon(icon, color: AppColors.textMedium, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textMedium),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return _mintGreen;
    if (score >= 60) return _sunsetOrange;
    return _coralPink;
  }

  String _getScoreDescription(int score) {
    if (score >= 80) return 'Excellent standing';
    if (score >= 60) return 'Good standing';
    if (score >= 40) return 'Fair standing';
    return 'Needs improvement';
  }

  String _getResponseTimeText(double responseTime) {
    if (responseTime < 2) return 'Fast';
    if (responseTime < 6) return 'Good';
    return 'Slow';
  }
}
