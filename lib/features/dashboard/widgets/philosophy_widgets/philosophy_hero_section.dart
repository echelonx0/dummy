// lib/features/dashboard/widgets/philosophy_widgets/philosophy_hero_section.dart
import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';

class PhilosophyHeroSection extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final AnimationController floatingController;

  const PhilosophyHeroSection({
    super.key,
    required this.scaleAnimation,
    required this.floatingController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDarkBlue, // Deep charcoal
            AppColors.primaryGold, // Medium charcoal
            AppColors.surfaceContainer.withValues(alpha: 0.8), // Bronze
            AppColors.surfaceContainerLow.withValues(
              alpha: 0.2,
            ), // Cream accent
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkBlue.withValues(alpha: 0.4),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: AppColors.primarySageGreen.withValues(alpha: 0.2),
            blurRadius: 48,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Floating romantic elements
          _buildFloatingElements(),

          // Main content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated quote mark
                Transform.scale(
                  scale: scaleAnimation.value,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryAccent.withValues(alpha: 0.2),
                      border: Border.all(
                        color: AppColors.primaryAccent.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.format_quote,
                      color: AppColors.primaryAccent,
                      size: 18,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Main manifesto text with shader
                ShaderMask(
                  shaderCallback:
                      (bounds) => LinearGradient(
                        colors: [
                          AppColors.primaryAccent,
                          AppColors.primaryAccent.withValues(alpha: 0.95),
                        ],
                      ).createShader(bounds),
                  child: Text(
                    'You are a whole, sovereign, loving individual.',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primaryAccent,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -0.8,
                      height: 1.2,
                      fontSize: 24,
                      shadows: [
                        Shadow(
                          color: AppColors.primaryDarkBlue.withValues(
                            alpha: 0.5,
                          ),
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Supporting text
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    'We want to facilitate your growth and connection, not reduce you to profile pictures and bio.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryAccent.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      fontSize: 14,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingElements() {
    return AnimatedBuilder(
      animation: floatingController,
      builder: (context, child) {
        final floatingValue = floatingController.value;

        return Stack(
          children: [
            // Large floating circle
            Positioned(
              top: -30,
              right: 20,
              child: Transform.translate(
                offset: Offset(0, floatingValue * 20),
                child: Transform.scale(
                  scale: scaleAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryAccent.withValues(alpha: 0.06),
                      border: Border.all(
                        color: AppColors.primaryAccent.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Medium floating circle
            Positioned(
              bottom: -20,
              right: 60,
              child: Transform.translate(
                offset: Offset(0, floatingValue * -15),
                child: Transform.scale(
                  scale: scaleAnimation.value * 0.8,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primarySageGreen.withValues(alpha: 0.15),
                    ),
                  ),
                ),
              ),
            ),

            // Floating hearts
            Positioned(
              top: 40,
              right: 140,
              child: Transform.translate(
                offset: Offset(0, floatingValue * 10),
                child: Transform.scale(
                  scale: scaleAnimation.value,
                  child: Icon(
                    Icons.favorite,
                    color: AppColors.primarySageGreen.withValues(alpha: 0.4),
                    size: 20,
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 60,
              right: 120,
              child: Transform.translate(
                offset: Offset(0, floatingValue * -8),
                child: Transform.scale(
                  scale: scaleAnimation.value * 0.7,
                  child: Icon(
                    Icons.favorite,
                    color: AppColors.primaryAccent.withValues(alpha: 0.3),
                    size: 16,
                  ),
                ),
              ),
            ),

            // Subtle sparkles
            Positioned(
              top: 100,
              right: 40,
              child: Transform.translate(
                offset: Offset(0, floatingValue * 12),
                child: Icon(
                  Icons.auto_awesome,
                  color: AppColors.primaryAccent.withValues(alpha: 0.2),
                  size: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
