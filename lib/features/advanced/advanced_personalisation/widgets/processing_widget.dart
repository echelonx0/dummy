// lib/features/advanced_personalization/widgets/processing_widget.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_dimensions.dart';
import '../../../../constants/app_text_styles.dart';

class ProcessingWidget extends StatefulWidget {
  const ProcessingWidget({super.key});

  @override
  State<ProcessingWidget> createState() => _ProcessingWidgetState();
}

class _ProcessingWidgetState extends State<ProcessingWidget>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _dotsController;
  late Animation<double> _spinAnimation;

  @override
  void initState() {
    super.initState();

    _spinController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _spinAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _spinController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _spinController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Spinning loader
        AnimatedBuilder(
          animation: _spinAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _spinAnimation.value * 2 * 3.14159,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      AppColors.primarySageGreen, // Bronze
                      AppColors.primaryAccent, // Cream
                      AppColors.warmRed, // Bronze alternative
                      AppColors.primarySageGreen, // Bronze
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDark,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.psychology,
                    size: 32,
                    color: AppColors.primarySageGreen,
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: AppDimensions.paddingXL),

        Text(
          'Analyzing Your Preferences',
          style: AppTextStyles.heading2.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppDimensions.paddingM),

        Text(
          'Our AI is creating your advanced compatibility profile...',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textMedium),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppDimensions.paddingXL),

        // Animated dots
        AnimatedBuilder(
          animation: _dotsController,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final delay = index * 0.3;
                final animValue = (_dotsController.value - delay).clamp(
                  0.0,
                  1.0,
                );
                final scale = (sin(animValue * 3.14159) * 0.5 + 0.5);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Transform.scale(
                    scale: 0.5 + scale * 0.5,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primarySageGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}
