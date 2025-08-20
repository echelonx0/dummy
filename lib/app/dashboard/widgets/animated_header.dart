// lib/features/dashboard/widgets/dashboard_header.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../core/shared/theme/color_utils.dart'; // Import our utility

class DashboardHeader extends StatelessWidget {
  final String? userName;
  final VoidCallback? onNotificationTap;
  final bool hasNotifications;

  const DashboardHeader({
    super.key,
    this.userName,
    this.onNotificationTap,
    this.hasNotifications = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDarkBlue,
            AppColors.primaryDarkBlue.alpha90,
            AppColors.primaryDarkBlue.alpha80,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkBlue.alpha30,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.primaryDarkBlue.alpha10,
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Floating background elements
          Positioned(
            top: -10,
            right: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColorAlpha.white10,
              ),
            ),
          ),
          Positioned(
            bottom: -15,
            right: 50,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColorAlpha.white05,
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 80,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColorAlpha.white15,
              ),
            ),
          ),

          // Main content
          Row(
            children: [
              const SizedBox(width: 16),

              // Enhanced Text Content with staggered animations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(30 * (1 - value), 0),
                          child: Opacity(
                            opacity: value,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShaderMask(
                                  shaderCallback:
                                      (bounds) => LinearGradient(
                                        colors: [
                                          Colors.white,
                                          Colors.white.alpha90,
                                        ],
                                      ).createShader(bounds),
                                  child: Text(
                                    'Welcome back${userName != null ? ", $userName" : ""}',
                                    style: AppTextStyles.heading2.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.5,
                                      shadows: [
                                        Shadow(
                                          color: AppColorAlpha.black30,
                                          offset: const Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColorAlpha.white20,
                                        AppColorAlpha.white10,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColorAlpha.white30,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.auto_awesome,
                                        color: AppColorAlpha.white90,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Ready to unfold?',
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              color: AppColorAlpha.white95,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
