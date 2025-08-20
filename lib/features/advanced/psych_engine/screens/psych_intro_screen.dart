// lib/features/psychological_profile/screens/psychology_intro_screen.dart

import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';

class PsychologyIntroScreen extends StatefulWidget {
  const PsychologyIntroScreen({super.key});

  @override
  State<PsychologyIntroScreen> createState() => _PsychologyIntroScreenState();
}

class _PsychologyIntroScreenState extends State<PsychologyIntroScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight, // ✅ Fixed: Dark background
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),

                        // Enhanced hero section with animation
                        Center(
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors
                                            .primarySageGreen, // ✅ Fixed: Bronze
                                        AppColors.primarySageGreen.withValues(
                                          alpha: 0.7,
                                        ),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primarySageGreen
                                            .withValues(alpha: 0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.psychology_alt,
                                    size: 60,
                                    color:
                                        AppColors
                                            .primaryDarkBlue, // ✅ Fixed: Dark on bronze
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Discover Your Psychological Match',
                          style: AppTextStyles.heading3.copyWith(
                            // ✅ Fixed: Better heading
                            color: AppColors.textDark, // ✅ Fixed: Cream text
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'Sometimes opposites create the most beautiful connections. Our psychological assessment reveals your core personality patterns to find someone who complements you perfectly.',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color:
                                AppColors
                                    .textMedium, // ✅ Fixed: Bronze secondary text
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 40),

                        // Enhanced features with animations
                        _buildFeature(
                          icon: Icons.quiz_outlined,
                          title: '10 Thoughtful Scenarios',
                          description:
                              'Real-life situations that reveal how you approach relationships, decisions, and life challenges.',
                          delay: 0,
                        ),

                        const SizedBox(height: 24),

                        _buildFeature(
                          icon: Icons.favorite_outline,
                          title: 'Opposite Attraction Matching',
                          description:
                              'Find someone whose strengths complement your approach to create balanced, growth-oriented relationships.',
                          delay: 200,
                        ),

                        const SizedBox(height: 24),

                        _buildFeature(
                          icon: Icons.timer_outlined,
                          title: '15 Minutes to Complete',
                          description:
                              'Each scenario takes about 90 seconds to read and respond to thoughtfully.',
                          delay: 400,
                        ),

                        const SizedBox(height: 32),

                        // Enhanced privacy note
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.surfaceContainer,
                                AppColors.surfaceContainerHigh,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primarySageGreen.withValues(
                                alpha: 0.3,
                              ),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryDarkBlue.withValues(
                                  alpha: 0.1,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySageGreen.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.shield_outlined,
                                  color:
                                      AppColors
                                          .primarySageGreen, // ✅ Fixed: Bronze
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Privacy Protected',
                                      style: AppTextStyles.label.copyWith(
                                        color: AppColors.primarySageGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Your responses are private and only used for matching. You control what you share with potential matches.',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color:
                                            AppColors
                                                .textMedium, // ✅ Fixed: Bronze text
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Premium action button with animation
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.3,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pushNamed('/psychology-assessment');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.primarySageGreen, // ✅ Fixed: Bronze
                            foregroundColor:
                                AppColors
                                    .primaryDarkBlue, // ✅ Fixed: Dark on bronze
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 6,
                            shadowColor: AppColors.primarySageGreen.withValues(
                              alpha: 0.3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.psychology_alt, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                'Start Psychology Assessment',
                                style: AppTextStyles.button.copyWith(
                                  color: AppColors.primaryDarkBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Secondary action
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                  ),
                  child: Text(
                    'Maybe Later',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMedium, // ✅ Fixed: Bronze text
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Premium upgrade hint
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warmRedAlpha10,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.warmRed.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: AppColors.warmRed, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Free assessment • Premium insights available',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.warmRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String description,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primarySageGreen.withValues(alpha: 0.2),
                        AppColors.primaryAccent.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primarySageGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primarySageGreen, // ✅ Fixed: Bronze
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.heading3.copyWith(
                          // ✅ Fixed: Better heading
                          color: AppColors.textDark, // ✅ Fixed: Cream text
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMedium, // ✅ Fixed: Bronze text
                          height: 1.5,
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
    );
  }
}
