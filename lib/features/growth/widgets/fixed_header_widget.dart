// lib/features/growth/widgets/romantic_header_content.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';
import '../providers/growth_provider.dart';

class RomanticHeaderContent extends StatelessWidget {
  const RomanticHeaderContent({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available width for proper layout
        final availableWidth = constraints.maxWidth;
        final iconWidth = 64.0;
        final spacingWidth = AppDimensions.paddingL;
        final badgeWidth = 80.0; // Fixed width for badge
        final textWidth =
            availableWidth -
            iconWidth -
            spacingWidth -
            badgeWidth -
            AppDimensions.paddingM;

        return Row(
          children: [
            // Animated Icon Container
            _buildAnimatedIcon(),

            const SizedBox(width: AppDimensions.paddingL),

            // Text Content - Fixed width to prevent overflow
            SizedBox(width: textWidth, child: _buildTextContent()),

            const SizedBox(width: AppDimensions.paddingM),

            // Growth Level Badge - Fixed width
            SizedBox(width: badgeWidth, child: _buildGrowthLevelBadge()),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        final clampedValue = value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: clampedValue,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 32),
          ),
        );
      },
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main Title
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
          builder: (context, value, child) {
            final opacity = value.clamp(0.0, 1.0);
            return Transform.translate(
              offset: Offset(40 * (1 - value), 0),
              child: Opacity(
                opacity: opacity,
                child: Text(
                  'Your Love Journey',
                  style: AppTextStyles.heading2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 4),

        // Subtitle with Provider
        Consumer<GrowthProvider>(
          builder: (context, provider, child) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
              builder: (context, value, child) {
                final opacity = value.clamp(0.0, 1.0);
                return Transform.translate(
                  offset: Offset(40 * (1 - value), 0),
                  child: Opacity(
                    opacity: opacity,
                    child: Text(
                      provider.encouragingMessage,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildGrowthLevelBadge() {
    return Consumer<GrowthProvider>(
      builder: (context, provider, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1400),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            final clampedValue = value.clamp(0.0, 1.0);
            return Transform.scale(
              scale: clampedValue,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  provider.growthLevel,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Extension to safely access provider properties
extension GrowthProviderSafeAccess on GrowthProvider {
  String get safeEncouragingMessage =>
      encouragingMessage.isNotEmpty ? encouragingMessage : 'Keep growing! 🌱';

  String get safeGrowthLevel =>
      growthLevel.isNotEmpty ? growthLevel : 'Beginner';
}
