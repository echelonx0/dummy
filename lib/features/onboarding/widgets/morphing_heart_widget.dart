// lib/shared/widgets/morphing_heart_widget.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class MorphingHeartWidget extends StatefulWidget {
  final double size;
  final Color primaryColor;
  final Color glowColor;
  final Duration animationDuration;

  const MorphingHeartWidget({
    super.key,
    this.size = 160,
    this.primaryColor = const Color(0xFFFF6B9D), // Coral pink
    this.glowColor = const Color(0xFFFFE66D), // Sunset orange
    this.animationDuration = const Duration(seconds: 3),
  });

  @override
  State<MorphingHeartWidget> createState() => _MorphingHeartWidgetState();
}

class _MorphingHeartWidgetState extends State<MorphingHeartWidget>
    with TickerProviderStateMixin {
  late AnimationController _heartController;
  late AnimationController _particleController;
  
  late Animation<double> _heartMorph;
  late Animation<double> _heartGlow;
  late Animation<double> _heartPulse;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _heartController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Heart morphing from outline to filled
    _heartMorph = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    // Glow intensity
    _heartGlow = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    // Pulse animation
    _heartPulse = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _heartController.forward();
    
    // Start pulse animation after heart is formed
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        _particleController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _heartController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_heartController, _particleController]),
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Transform.scale(
            scale: _heartPulse.value,
            child: CustomPaint(
              painter: MorphingHeartPainter(
                morphProgress: _heartMorph.value,
                glowIntensity: _heartGlow.value,
                primaryColor: widget.primaryColor,
                glowColor: widget.glowColor,
                pulseProgress: _particleController.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

class MorphingHeartPainter extends CustomPainter {
  final double morphProgress;
  final double glowIntensity;
  final double pulseProgress;
  final Color primaryColor;
  final Color glowColor;

  MorphingHeartPainter({
    required this.morphProgress,
    required this.glowIntensity,
    required this.pulseProgress,
    required this.primaryColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final heartSize = size.width * 0.4;

    // Draw glow effect
    if (glowIntensity > 0) {
      _drawGlow(canvas, center, heartSize);
    }

    // Draw floating particles
    if (pulseProgress > 0.5) {
      _drawParticles(canvas, center, heartSize);
    }

    // Draw the main heart
    _drawHeart(canvas, center, heartSize);
  }

  void _drawGlow(Canvas canvas, Offset center, double heartSize) {
    final glowPaint = Paint()
      ..color = glowColor.withOpacity(0.3 * glowIntensity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15 * glowIntensity);

    final glowPath = _createHeartPath(center, heartSize * (1 + glowIntensity * 0.2));
    canvas.drawPath(glowPath, glowPaint);
  }

  void _drawParticles(Canvas canvas, Offset center, double heartSize) {
    final particlePaint = Paint()
      ..color = primaryColor.withOpacity(0.6);

    // Draw small hearts floating around
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60.0 + pulseProgress * 360) * math.pi / 180;
      final radius = heartSize * (0.8 + pulseProgress * 0.3);
      final particleCenter = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );

      final particlePath = _createHeartPath(particleCenter, heartSize * 0.15);
      canvas.drawPath(particlePath, particlePaint);
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double heartSize) {
    final heartPath = _createHeartPath(center, heartSize);

    // Outline paint
    final outlinePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Fill paint
    final fillPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withOpacity(0.8),
          primaryColor.withOpacity(0.4),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: heartSize));

    // Draw based on morph progress
    if (morphProgress < 1.0) {
      // Animated outline drawing
      final pathMetrics = heartPath.computeMetrics();
      final pathMetric = pathMetrics.first;
      final animatedPath = pathMetric.extractPath(0, pathMetric.length * morphProgress);
      
      canvas.drawPath(animatedPath, outlinePaint);
    } else {
      // Full heart with fill
      canvas.drawPath(heartPath, fillPaint);
      canvas.drawPath(heartPath, outlinePaint);
    }
  }

  Path _createHeartPath(Offset center, double size) {
    final path = Path();
    
    // Heart shape using cubic bezier curves
    final width = size;
    final height = size * 0.8;
    
    // Start at the bottom point of the heart
    path.moveTo(center.dx, center.dy + height * 0.3);
    
    // Left side of heart
    path.cubicTo(
      center.dx - width * 0.5, center.dy - height * 0.1,
      center.dx - width * 0.5, center.dy - height * 0.5,
      center.dx - width * 0.25, center.dy - height * 0.5,
    );
    
    // Left top curve
    path.cubicTo(
      center.dx - width * 0.1, center.dy - height * 0.6,
      center.dx + width * 0.1, center.dy - height * 0.6,
      center.dx + width * 0.25, center.dy - height * 0.5,
    );
    
    // Right side of heart  
    path.cubicTo(
      center.dx + width * 0.5, center.dy - height * 0.5,
      center.dx + width * 0.5, center.dy - height * 0.1,
      center.dx, center.dy + height * 0.3,
    );
    
    path.close();
    
    return path;
  }

  @override
  bool shouldRepaint(covariant MorphingHeartPainter oldDelegate) {
    return oldDelegate.morphProgress != morphProgress ||
           oldDelegate.glowIntensity != glowIntensity ||
           oldDelegate.pulseProgress != pulseProgress;
  }
}

// Extension for easy usage
extension MorphingHeartWidgetExtension on Widget {
  Widget withMorphingHeart({
    double size = 160,
    Color primaryColor = const Color(0xFFFF6B9D),
    Color glowColor = const Color(0xFFFFE66D),
  }) {
    return MorphingHeartWidget(
      size: size,
      primaryColor: primaryColor,
      glowColor: glowColor,
    );
  }
}