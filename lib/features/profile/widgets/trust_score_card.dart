// lib/features/profile/widgets/trust_score_card.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

class TrustScoreCard extends StatefulWidget {
  final double trustScore;
  final VoidCallback? onViewDetails;
  final bool showAnimations;

  const TrustScoreCard({
    super.key,
    required this.trustScore,
    this.onViewDetails,
    this.showAnimations = true,
  });

  @override
  State<TrustScoreCard> createState() => _TrustScoreCardState();
}

class _TrustScoreCardState extends State<TrustScoreCard>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sparkleAnimation;

  // Vibrant colors based on trust score
  static const Color _excellentColor = Color(0xFF10B981); // Emerald green
  static const Color _goodColor = Color(0xFF3B82F6); // Bright blue
  static const Color _fairColor = Color(0xFFEAB308); // Golden yellow
  static const Color _needsImprovementColor = Color(0xFFF97316); // Orange
  static const Color _lowColor = Color(0xFFEF4444); // Red

  @override
  void initState() {
    super.initState();
    if (widget.showAnimations) {
      _initializeAnimations();
    }
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.trustScore / 100,
    ).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutBack),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.linear),
    );

    // Start animations
    _progressController.forward();
    _pulseController.repeat(reverse: true);
    _sparkleController.repeat();
  }

  @override
  void dispose() {
    if (widget.showAnimations) {
      _progressController.dispose();
      _pulseController.dispose();
      _sparkleController.dispose();
    }
    super.dispose();
  }

  Color get _primaryColor {
    if (widget.trustScore >= 90) return _excellentColor;
    if (widget.trustScore >= 80) return _goodColor;
    if (widget.trustScore >= 60) return _fairColor;
    if (widget.trustScore >= 40) return _needsImprovementColor;
    return _lowColor;
  }

  String get _scoreDescription {
    if (widget.trustScore >= 90) return 'Excellent standing';
    if (widget.trustScore >= 80) return 'Good standing';
    if (widget.trustScore >= 60) return 'Fair standing';
    if (widget.trustScore >= 40) return 'Needs improvement';
    return 'Low standing';
  }

  IconData get _scoreIcon {
    if (widget.trustScore >= 90) return Icons.verified_user;
    if (widget.trustScore >= 80) return Icons.shield_outlined;
    if (widget.trustScore >= 60) return Icons.security;
    if (widget.trustScore >= 40) return Icons.warning_amber_outlined;
    return Icons.error_outline;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showAnimations) {
      return _buildStaticCard();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_progressController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: _buildAnimatedCard(),
        );
      },
    );
  }

  Widget _buildStaticCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, _primaryColor.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _buildContent(),
    );
  }

  Widget _buildAnimatedCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, _primaryColor.withValues(alpha: 0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _primaryColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.2),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(children: [_buildSparkles(), _buildContent()]),
    );
  }

  Widget _buildSparkles() {
    if (!widget.showAnimations) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: SparklesPainter(
              animation: _sparkleAnimation.value,
              color: _primaryColor,
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Row(
      children: [
        // Circular Progress Score
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            children: [
              // Background circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _primaryColor.withValues(alpha: 0.1),
                ),
              ),

              // Progress circle
              if (widget.showAnimations)
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: _progressAnimation.value,
                        strokeWidth: 4,
                        backgroundColor: _primaryColor.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _primaryColor,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    );
                  },
                )
              else
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: widget.trustScore / 100,
                    strokeWidth: 4,
                    backgroundColor: _primaryColor.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),

              // Score text
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.trustScore.toInt().toString(),
                      style: AppTextStyles.heading2.copyWith(
                        color: _primaryColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      'Trust',
                      style: AppTextStyles.caption.copyWith(
                        color: _primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 20),

        // Score info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_scoreIcon, color: _primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Feedback Score',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _scoreDescription,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildScoreBreakdown(),
            ],
          ),
        ),

        // Action button
        if (widget.onViewDetails != null)
          Container(
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: widget.onViewDetails,
              icon: Icon(
                Icons.arrow_forward_ios,
                color: _primaryColor,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildScoreBreakdown() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildMiniStat('Response', '98%'),
          const SizedBox(width: 16),
          _buildMiniStat('Respect', '100%'),
          const SizedBox(width: 16),
          _buildMiniStat('Honesty', '96%'),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: _primaryColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMedium,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class SparklesPainter extends CustomPainter {
  final double animation;
  final Color color;

  SparklesPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color.withValues(alpha: 0.6)
          ..style = PaintingStyle.fill;

    // Create sparkles at different positions
    final sparkles = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.9, size.height * 0.7),
      Offset(size.width * 0.1, size.height * 0.8),
    ];

    for (int i = 0; i < sparkles.length; i++) {
      final sparkleAnimation = (animation + i * 0.25) % 1.0;
      final sparkleSize = 2 + (math.sin(sparkleAnimation * math.pi * 2) * 2);

      if (sparkleSize > 0) {
        canvas.drawCircle(
          sparkles[i],
          sparkleSize,
          paint..color = color.withValues(alpha: sparkleAnimation * 0.6),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
