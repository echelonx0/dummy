// lib/features/courtship/widgets/premium_psychological_depths_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

class PsychologicalDepthsCard extends StatefulWidget {
  final VoidCallback? onUnlockJourney;

  const PsychologicalDepthsCard({super.key, this.onUnlockJourney});

  @override
  State<PsychologicalDepthsCard> createState() =>
      _PsychologicalDepthsCardState();
}

class _PsychologicalDepthsCardState extends State<PsychologicalDepthsCard>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _floatingController;
  late AnimationController _glowController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _floatingController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _floatingAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _floatingController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Deep premium gradient background
            _buildPremiumBackground(),

            // Floating depth elements
            _buildDepthElements(),

            // Main content
            _buildMainContent(),

            // Subtle premium glow overlay
            _buildPremiumGlowOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBackground() {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryDarkBlue,
                AppColors.primaryGold.withValues(alpha: 0.9),
                AppColors.primarySageGreen.withValues(alpha: 0.8),
                AppColors.primaryDarkBlue.withValues(alpha: 0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.0,
                0.3 + (_breathingAnimation.value * 0.1),
                0.7 + (_breathingAnimation.value * 0.1),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDepthElements() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Stack(
          children: [
            // Mysterious circle - top right
            Positioned(
              top: 25 + _floatingAnimation.value,
              right: 35,
              child: Transform.rotate(
                angle: _floatingAnimation.value * 0.05,
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryAccent.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.psychology_outlined,
                    color: AppColors.primaryAccent.withValues(alpha: 0.8),
                    size: 18,
                  ),
                ),
              ),
            ),

            // Depth layers - bottom left
            Positioned(
              bottom: 50 - _floatingAnimation.value,
              left: 25,
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.primarySageGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primarySageGreen.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
              ),
            ),

            // Insight diamond - middle right
            Positioned(
              top: 110 + (_floatingAnimation.value * 0.3),
              right: 15,
              child: Transform.rotate(
                angle: _breathingAnimation.value * 0.1,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            // Subtle geometric elements
            Positioned(
              top: 80,
              right: 50,
              child: Transform.translate(
                offset: Offset(0, _floatingAnimation.value * 0.5),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Premium badge and hero section
          Row(
            children: [
              // Exclusive badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primarySageGreen,
                      AppColors.primaryAccent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'PREMIUM ONLY',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryDarkBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              // Breathing icon
              AnimatedBuilder(
                animation: _breathingController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _breathingAnimation.value,
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryAccent.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.auto_awesome_outlined,
                        color: AppColors.primaryAccent,
                        size: 22,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Main headline
          Text(
            'Unlock Your Psychological Depths',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.primaryAccent,
              fontWeight: FontWeight.w700,
              fontSize: 22,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Professional-grade self-discovery',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primaryAccent.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          // Premium features - sophisticated
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPremiumFeatureChip(
                'Shadow Work',
                Icons.psychology,
                AppColors.primarySageGreen,
              ),
              _buildPremiumFeatureChip(
                '1-on-1 Coaching',
                Icons.person,
                AppColors.primaryAccent,
              ),
              _buildPremiumFeatureChip(
                'Pattern Analysis',
                Icons.insights,
                AppColors.primaryGold,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Description - professional and transformative
          Expanded(
            child: Text(
              'Dive deep into your relationship patterns, unconscious behaviors, and attachment wounds with certified therapists. Uncover your psychological blueprint.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryAccent.withValues(alpha: 0.9),
                height: 1.5,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 16),

          // Premium CTA with pricing hint
          _buildPremiumCTA(),
        ],
      ),
    );
  }

  Widget _buildPremiumFeatureChip(
    String text,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accentColor, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primaryAccent,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCTA() {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primarySageGreen,
                AppColors.primaryAccent.withValues(alpha: 0.9),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primarySageGreen.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                widget.onUnlockJourney?.call();
              },
              borderRadius: BorderRadius.circular(24),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Unlock Journey',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.primaryDarkBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$49/mo',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryDarkBlue.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Transform.scale(
                      scale: _breathingAnimation.value * 0.1 + 0.9,
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.primaryDarkBlue,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumGlowOverlay() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.primarySageGreen.withValues(
                    alpha: _glowAnimation.value * 0.1,
                  ),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
                begin: Alignment(-1.0 + (_glowAnimation.value * 0.5), -1.0),
                end: Alignment(1.0 + (_glowAnimation.value * 0.5), 1.0),
              ),
            ),
          ),
        );
      },
    );
  }
}
