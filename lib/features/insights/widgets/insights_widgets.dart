// ==========================================================================
// ANIMATED CARD WRAPPER
// ==========================================================================

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../core/models/user_insights.dart';

class InsightsAnimatedCard extends StatelessWidget {
  final int delay;
  final Widget child;

  const InsightsAnimatedCard({
    super.key,
    required this.delay,
    required this.child,
  });

  double _safeOpacity(double? value) {
    if (value == null || value.isNaN || value.isInfinite) return 0.0;
    return value.clamp(0.0, 1.0);
  }

  double _safeOffset(double? value) {
    if (value == null || value.isNaN || value.isInfinite) return 0.0;
    return value.clamp(-200.0, 200.0);
  }

  double _safeScale(double? value) {
    if (value == null || value.isNaN || value.isInfinite) return 1.0;
    return value.clamp(0.1, 2.0);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: (600 + delay).clamp(300, 3000)),
      curve: Curves.elasticOut,
      builder: (context, animationValue, _) {
        final safeValue = _safeOpacity(animationValue);
        final safeOffset = _safeOffset(50 * (1 - safeValue));
        final safeScale = _safeScale(0.8 + (0.2 * safeValue));

        return Transform.translate(
          offset: Offset(0, safeOffset),
          child: Transform.scale(
            scale: safeScale,
            child: Opacity(
              opacity: safeValue,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground, // Dark theme
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primarySageGreen.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDarkBlue.withValues(alpha: 0.15),
                      blurRadius: 25,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: AppColors.primarySageGreen.withValues(alpha: 0.05),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==========================================================================
// RELATIONSHIP READINESS CARD
// ==========================================================================

class RelationshipReadinessCard extends StatelessWidget {
  final UserInsights userInsights;
  final String? userFirstName;

  const RelationshipReadinessCard({
    super.key,
    required this.userInsights,
    this.userFirstName,
  });

  double _safePercent(double? value) {
    if (value == null || value.isNaN || value.isInfinite) return 0.0;
    return value.clamp(0.0, 1.0);
  }

  int _safePercentDisplay(double? value) {
    if (value == null || value.isNaN || value.isInfinite) return 0;
    return (value * 100).clamp(0.0, 100.0).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final safeReadiness = _safePercent(userInsights.relationshipReadiness);
    final readinessLevel = userInsights.readinessLevel;

    return Column(
      children: [
        Text(
          'Relationship Readiness 💝',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.primaryAccent, // Cream
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.justify,
        ),

        const SizedBox(height: 20),

        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: safeReadiness),
          duration: const Duration(milliseconds: 2000),
          curve: Curves.elasticOut,
          builder: (context, animationValue, child) {
            final safeValue = _safePercent(animationValue);

            return CircularPercentIndicator(
              radius: 90.0,
              lineWidth: 15.0,
              animation: false,
              percent: safeValue,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_safePercentDisplay(safeValue)}%',
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.primarySageGreen, // Bronze
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    readinessLevel,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: AppColors.primarySageGreen, // Bronze
              backgroundColor: AppColors.primarySageGreen.withValues(
                alpha: 0.1,
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        Text(
          userInsights.readinessExplanation,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textDark, // Cream text
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}

// ==========================================================================
// STRENGTHS CARD
// ==========================================================================

class StrengthsCard extends StatelessWidget {
  final List<Map<String, String>> strengths;
  final String? userFirstName;

  const StrengthsCard({super.key, required this.strengths, this.userFirstName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InsightsSectionHeader(
          icon: Icons.star_outlined,
          title: 'Your Strengths ✨',
          color: AppColors.primaryAccent, // Cream
        ),

        const SizedBox(height: 20),

        ...strengths.asMap().entries.map((entry) {
          final index = entry.key;
          final strength = entry.value;
          final title = strength['title'] ?? 'Strength ${index + 1}';
          final description =
              strength['description'] ?? 'Details not available';

          return InsightAnimatedItem(
            title: title,
            description: description,
            color: AppColors.primaryAccent, // Cream
            delay: index * 100,
          );
        }),
      ],
    );
  }
}

// ==========================================================================
// GROWTH AREAS CARD
// ==========================================================================

class GrowthAreasCard extends StatelessWidget {
  final List<Map<String, String>> growthAreas;
  final String? userFirstName;

  const GrowthAreasCard({
    super.key,
    required this.growthAreas,
    this.userFirstName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InsightsSectionHeader(
          icon: Icons.trending_up_outlined,
          title: 'Growth Opportunities 🌱',
          color: AppColors.primarySageGreen, // Medium charcoal accent
        ),

        const SizedBox(height: 20),

        ...growthAreas.asMap().entries.map((entry) {
          final index = entry.key;
          final growthArea = entry.value;
          final title = growthArea['title'] ?? 'Growth Area ${index + 1}';
          final description =
              growthArea['description'] ?? 'Details not available';

          return InsightAnimatedItem(
            title: title,
            description: description,
            color: AppColors.primarySageGreen, // Medium charcoal accent
            delay: index * 100,
          );
        }),
      ],
    );
  }
}

// ==========================================================================
// SECTION HEADER WIDGET
// ==========================================================================

class InsightsSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const InsightsSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primarySageGreen, // Bronze
                AppColors.primarySageGreen.withValues(alpha: 0.8),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primaryAccent, // Cream icon
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.heading3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}

// ==========================================================================
// ANIMATED INSIGHT ITEM
// ==========================================================================

class InsightAnimatedItem extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final int delay;

  const InsightAnimatedItem({
    super.key,
    required this.title,
    required this.description,
    required this.color,
    required this.delay,
  });

  double _safeOpacity(double? value) {
    if (value == null || value.isNaN || value.isInfinite) return 0.0;
    return value.clamp(0.0, 1.0);
  }

  double _safeOffset(double? value) {
    if (value == null || value.isNaN || value.isInfinite) return 0.0;
    return value.clamp(-200.0, 200.0);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: (400 + delay).clamp(200, 2000)),
      curve: Curves.easeOut,
      builder: (context, animationValue, child) {
        final safeValue = _safeOpacity(animationValue);
        final safeOffset = _safeOffset(30 * (1 - safeValue));

        return Transform.translate(
          offset: Offset(safeOffset, 0),
          child: Opacity(
            opacity: safeValue,
            child: InsightItem(
              title: title,
              description: description,
              color: color,
            ),
          ),
        );
      },
    );
  }
}

// ==========================================================================
// INSIGHT ITEM WIDGET
// ==========================================================================

class InsightItem extends StatelessWidget {
  final String title;
  final String description;
  final Color color;

  const InsightItem({
    super.key,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.isEmpty ? 'Insight' : title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 8),
          Text(
            description.isEmpty ? 'Description not available' : description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDark, // Cream text
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// ERROR CARD WIDGET
// ==========================================================================

class InsightsErrorCard extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const InsightsErrorCard({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground, // Dark theme
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkBlue.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, color: AppColors.error, size: 48),
          ),

          const SizedBox(height: 16),

          Text(
            title,
            style: AppTextStyles.heading3.copyWith(color: AppColors.error),
            textAlign: TextAlign.justify,
          ),

          const SizedBox(height: 12),

          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDark, // Cream text
            ),
            textAlign: TextAlign.justify,
          ),

          const SizedBox(height: 20),

          InsightsActionButton(
            text: 'Try Again 🔄',
            onPressed: onRetry,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// ACTION BUTTON WIDGET
// ==========================================================================

class InsightsActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final bool isSecondary;

  const InsightsActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.color,
    this.isSecondary = false,
  });

  double _safeOpacity(double? value) {
    if (value == null || value.isNaN || value.isInfinite) return 0.0;
    return value.clamp(0.0, 1.0);
  }

  double _safeScale(double? value) {
    if (value == null || value.isNaN || value.isInfinite) return 1.0;
    return value.clamp(0.1, 2.0);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, animationValue, child) {
        final safeValue = _safeOpacity(animationValue);
        final safeScale = _safeScale(0.9 + (0.1 * safeValue));

        return Transform.scale(
          scale: safeScale,
          child: GestureDetector(
            onTap: onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient:
                    isSecondary
                        ? null
                        : LinearGradient(
                          colors: [color, color.withValues(alpha: 0.8)],
                        ),
                color: isSecondary ? color.withValues(alpha: 0.1) : null,
                borderRadius: BorderRadius.circular(16),
                border:
                    isSecondary ? Border.all(color: color, width: 1.5) : null,
                boxShadow:
                    isSecondary
                        ? null
                        : [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
              ),
              child: Center(
                child: Text(
                  text,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSecondary ? color : AppColors.primaryAccent,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
