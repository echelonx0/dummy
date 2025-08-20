// lib/features/advanced_personalization/widgets/results_widget.dart

import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_dimensions.dart';
import '../../../../constants/app_text_styles.dart';

class ResultsWidget extends StatefulWidget {
  final bool isClubEligible;
  final String clubName;
  final String userGender;
  final VoidCallback onClubApplication;
  final bool isLoading;

  const ResultsWidget({
    super.key,
    required this.isClubEligible,
    required this.clubName,
    required this.userGender,
    required this.onClubApplication,
    required this.isLoading,
  });

  @override
  State<ResultsWidget> createState() => _ResultsWidgetState();
}

class _ResultsWidgetState extends State<ResultsWidget>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _badgeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _badgeScaleAnimation;

  @override
  void initState() {
    super.initState();

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _badgeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );

    _badgeScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.elasticOut),
    );

    _celebrationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _badgeController.forward();
    });
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  LinearGradient get _clubGradient {
    if (widget.userGender == 'female') {
      return LinearGradient(
        colors: [AppColors.primaryAccent, AppColors.warmRed],
      );
    } else {
      return LinearGradient(
        colors: [AppColors.primaryDarkBlue, AppColors.primarySageGreen],
      );
    }
  }

  Color get _clubAccentColor {
    return widget.userGender == 'female'
        ? AppColors.primaryAccent
        : AppColors.primaryDarkBlue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.isClubEligible)
          _buildClubEligibleContent()
        else
          _buildStandardContent(),

        const Spacer(),

        _buildActionButtons(),
      ],
    );
  }

  Widget _buildClubEligibleContent() {
    return Column(
      children: [
        // Crown icon with animation
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: _clubGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _clubAccentColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.emoji_events,
              size: 48,
              color: AppColors.primaryAccent,
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.paddingL),

        Text(
          'Congratulations!',
          style: AppTextStyles.heading1.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppDimensions.paddingM),

        // Club badge
        ScaleTransition(
          scale: _badgeScaleAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
              vertical: AppDimensions.paddingM,
            ),
            decoration: BoxDecoration(
              gradient: _clubGradient,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              boxShadow: [
                BoxShadow(
                  color: _clubAccentColor.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              '${widget.clubName} Invitation',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryAccent,
              ),
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.paddingL),

        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textMedium,
              height: 1.6,
            ),
            children: [
              TextSpan(
                text:
                    'Based on your profile, you\'ve been invited to apply for ',
              ),
              TextSpan(
                text: widget.clubName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _clubAccentColor,
                ),
              ),
              TextSpan(
                text:
                    widget.userGender == 'female'
                        ? ' - an exclusive community of sophisticated women who value depth, success, and meaningful connection.'
                        : ' - an elite network of accomplished individuals building extraordinary relationships.',
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.paddingL),

        // Process explanation
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.security, color: AppColors.warning, size: 20),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invitation Process',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    Text(
                      'This invitation allows you to submit an application. Our team will manually review your profile, and qualified candidates may be invited for a brief human screening call.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMedium,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.paddingL),

        // Stats
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStat(
              'Only ${widget.userGender == 'female' ? '12%' : '15%'} invited',
              Icons.group,
            ),
            Container(
              width: 1,
              height: 32,
              color: AppColors.divider,
              margin: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
              ),
            ),
            _buildStat('Manual review', Icons.verified_user),
          ],
        ),
      ],
    );
  }

  Widget _buildStandardContent() {
    return Column(
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.success, AppColors.primarySageGreen],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, size: 40, color: AppColors.primaryAccent),
          ),
        ),

        const SizedBox(height: AppDimensions.paddingL),

        Text(
          'Advanced Matching Activated',
          style: AppTextStyles.heading2.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppDimensions.paddingL),

        Text(
          'Your preferences have been saved and our AI will now use this information to find even more compatible matches for you.',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textMedium,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppDimensions.paddingL),

        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: AppColors.primarySageGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          child: Text(
            'You\'ll see improved match quality in your next recommendations!',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primarySageGreen,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textLight),
        const SizedBox(width: AppDimensions.paddingS),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (widget.isClubEligible) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onClubApplication,
              style: ElevatedButton.styleFrom(
                backgroundColor: _clubAccentColor,
                foregroundColor: AppColors.primaryAccent,
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingL,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
                elevation: 4,
              ),
              child:
                  widget.isLoading
                      ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryAccent,
                          ),
                          strokeWidth: 2,
                        ),
                      )
                      : Text(
                        'Apply to ${widget.clubName}',
                        style: AppTextStyles.button.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),

          const SizedBox(height: AppDimensions.paddingM),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingL,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
                side: BorderSide(color: AppColors.divider),
              ),
              child: Text(
                'Continue to Regular Matching',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textMedium,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primarySageGreen,
            foregroundColor: AppColors.primaryAccent,
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.paddingL,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
            elevation: 4,
          ),
          child: Text(
            'Continue to Enhanced Matching',
            style: AppTextStyles.button.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }
}
