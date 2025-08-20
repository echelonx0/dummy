// lib/features/courtship/widgets/courtship_status_card.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';
import '../../../core/shared/widgets/custom_button.dart';
import '../models/courtship_models.dart';

class CourtshipStatusCard extends StatelessWidget {
  final UserCourtshipStatus? courtshipStatus;
  final bool isLoading;
  final Function(CourtshipAction, [String?]) onAction;

  const CourtshipStatusCard({
    super.key,
    this.courtshipStatus,
    required this.isLoading,
    required this.onAction,
  });

  static const Color _coralPink = Color(0xFFFF6B9D);
  static const Color _electricBlue = Color(0xFF4ECDC4);
  static const Color _sunsetOrange = Color(0xFFFFE66D);
  static const Color _mintGreen = Color(0xFF95E1A3);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingCard();
    }

    if (courtshipStatus?.isInCourtship == true) {
      return _buildActiveCourtshipCard();
    }

    return _buildAvailableCard();
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
            valueColor: AlwaysStoppedAnimation<Color>(_coralPink),
          ),
          const SizedBox(width: 16),
          Text(
            'Loading your courtship status...',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCourtshipCard() {
    final currentCourtship = courtshipStatus!.currentCourtshipId;
    final stage = 'In Progress'; // FIXED: Simplified stage display
    final daysRemaining = _calculateDaysRemaining();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _coralPink.withValues(alpha: 0.1),
            _sunsetOrange.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: _coralPink.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: _coralPink.withValues(alpha: 0.1),
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
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _coralPink,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _coralPink.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Courtship',
                      style: AppTextStyles.heading3.copyWith(
                        color: _coralPink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Stage: $stage',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _mintGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$daysRemaining days left',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            _getStageDescription(stage),
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: CustomButton(
                  text: 'Continue Journey',
                  onPressed:
                      () => onAction(
                        CourtshipAction.continueCourtship,
                        currentCourtship,
                      ),
                  type: ButtonType.primary,
                  icon: Icons.arrow_forward,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Exit',
                  onPressed:
                      () => onAction(
                        CourtshipAction.exitCourtship,
                        currentCourtship,
                      ),
                  type: ButtonType.outlined,
                  icon: Icons.exit_to_app,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableCard() {
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
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _electricBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.search, color: _electricBlue, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready for Courtship',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.primaryDarkBlue,
                      ),
                    ),
                    Text(
                      'Find your perfect match',
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

          Text(
            'You\'re available to begin a new courtship journey. Browse your recommended matches below and start meaningful connections.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),
          ),

          if (courtshipStatus?.availableDate != null &&
              courtshipStatus!.availableDate!.isAfter(DateTime.now())) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: AppColors.warning, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Available from ${_formatDate(courtshipStatus!.availableDate!)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.warning,
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

  String _getStageDescription(String stage) {
    switch (stage) {
      case 'Getting to Know Each Other':
        return 'Share your core values and build initial connection through guided conversations.';
      case 'Exploring Compatibility':
        return 'Discover how your lifestyles and daily routines complement each other.';
      case 'Deep Discovery':
        return 'Meet in person and explore deeper life vision alignment.';
      case 'Making Decisions':
        return 'Decide if you want to pursue a relationship together.';
      default:
        return 'Continue your guided courtship journey with meaningful conversations.';
    }
  }

  int _calculateDaysRemaining() {
    // TODO: Calculate based on actual courtship data
    // For now, return a placeholder
    return 7;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
