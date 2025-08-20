// Romantic particle types
import 'dart:math';

import 'package:flutter/material.dart';

// ADD: Brand color constants at the top
class RomanticParticleColors {
  static const Color warmRed = Color(0xFFFF6B8A);
  static const Color roseGold = Color(0xFFE8B4B8);
  static const Color softPink = Color(0xFFFFE1E6);
  static const Color deepBlue = Color(0xFF1A365D);
  static const Color lightBlue = Color(0xFF4ECDC4);
  static const Color successGreen = Color(0xFF95E1A3);
}

enum ParticleType { heart, sparkle, dust, glow }

class RomanticParticle {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  ParticleType type;
  double life;
  double maxLife;
  double rotation;
  double rotationSpeed;
  double opacity;
  double pulsePhase;
  double driftPhase;

  RomanticParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    required this.type,
    required this.maxLife,
    this.rotation = 0.0,
    this.rotationSpeed = 0.0,
    this.opacity = 1.0,
    this.pulsePhase = 0.0,
    this.driftPhase = 0.0,
  }) : life = maxLife;

  void update(double deltaTime) {
    // Update position with gentle drift
    final driftOffset = Offset(
      sin(driftPhase) * 0.001,
      cos(driftPhase * 0.7) * 0.0005,
    );

    position += velocity + driftOffset;

    // Update life and opacity
    life -= deltaTime;
    opacity = (life / maxLife).clamp(0.0, 1.0);

    // Update rotation and phases
    rotation += rotationSpeed * deltaTime;
    pulsePhase += deltaTime * 2;
    driftPhase += deltaTime * 0.5;

    // Wrap around screen edges with some buffer
    if (position.dx < -0.1) position = Offset(1.1, position.dy);
    if (position.dx > 1.1) position = Offset(-0.1, position.dy);
    if (position.dy < -0.1) position = Offset(position.dx, 1.1);
    if (position.dy > 1.1) position = Offset(position.dx, -0.1);
  }

  bool get isDead => life <= 0;
}

class RomanticParticleSystemPainter extends CustomPainter {
  final List<RomanticParticle> particles;
  final double animationProgress;
  final Random _random = Random();

  RomanticParticleSystemPainter({
    required this.particles,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Update particles
    for (final particle in particles) {
      particle.update(0.016); // Assuming 60fps
    }

    // Remove dead particles and add new ones
    particles.removeWhere((particle) => particle.isDead);
    _addNewParticles(size);

    // Draw particles by type for proper layering
    _drawGlowParticles(canvas, size);
    _drawDustParticles(canvas, size);
    _drawSparkleParticles(canvas, size);
    _drawHeartParticles(canvas, size);
  }

  void _addNewParticles(Size size) {
    // Maintain particle count
    while (particles.length < 50) {
      final type = _getRandomParticleType();
      particles.add(_createParticle(type, size));
    }
  }

  ParticleType _getRandomParticleType() {
    final rand = _random.nextDouble();
    if (rand < 0.1) return ParticleType.heart;
    if (rand < 0.3) return ParticleType.sparkle;
    if (rand < 0.7) return ParticleType.dust;
    return ParticleType.glow;
  }

  RomanticParticle _createParticle(ParticleType type, Size size) {
    final startX = _random.nextDouble();
    final startY = _random.nextDouble();

    switch (type) {
      case ParticleType.heart:
        return RomanticParticle(
          position: Offset(startX, startY),
          velocity: Offset(
            (_random.nextDouble() - 0.5) * 0.0005,
            -_random.nextDouble() * 0.0008,
          ),
          size: _random.nextDouble() * 8 + 4,
          color: Color.lerp(
            RomanticParticleColors.warmRed,
            RomanticParticleColors.roseGold,
            _random.nextDouble(),
          )!.withOpacity(0.6 + _random.nextDouble() * 0.4),
          type: type,
          maxLife: 15.0 + _random.nextDouble() * 10,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.5,
          pulsePhase: _random.nextDouble() * 2 * pi,
          driftPhase: _random.nextDouble() * 2 * pi,
        );

      case ParticleType.sparkle:
        return RomanticParticle(
          position: Offset(startX, startY),
          velocity: Offset(
            (_random.nextDouble() - 0.5) * 0.001,
            (_random.nextDouble() - 0.5) * 0.001,
          ),
          size: _random.nextDouble() * 3 + 1,
          color: Color.lerp(
            RomanticParticleColors.roseGold,
            RomanticParticleColors.softPink,
            _random.nextDouble(),
          )!.withOpacity(0.8 + _random.nextDouble() * 0.2),
          type: type,
          maxLife: 3.0 + _random.nextDouble() * 4,
          rotationSpeed: _random.nextDouble() * 4 - 2,
          pulsePhase: _random.nextDouble() * 2 * pi,
          driftPhase: _random.nextDouble() * 2 * pi,
        );

      case ParticleType.dust:
        return RomanticParticle(
          position: Offset(startX, startY),
          velocity: Offset(
            (_random.nextDouble() - 0.5) * 0.0003,
            -_random.nextDouble() * 0.0002,
          ),
          size: _random.nextDouble() * 2 + 0.5,
          color: Color.lerp(
            Colors.white,
            RomanticParticleColors.softPink,
            _random.nextDouble() * 0.3,
          )!.withOpacity(0.1 + _random.nextDouble() * 0.3),
          type: type,
          maxLife: 20.0 + _random.nextDouble() * 15,
          rotationSpeed: 0,
          pulsePhase: _random.nextDouble() * 2 * pi,
          driftPhase: _random.nextDouble() * 2 * pi,
        );

      case ParticleType.glow:
        return RomanticParticle(
          position: Offset(startX, startY),
          velocity: Offset(
            (_random.nextDouble() - 0.5) * 0.0001,
            -_random.nextDouble() * 0.0001,
          ),
          size: _random.nextDouble() * 20 + 10,
          color: Color.lerp(
            RomanticParticleColors.warmRed,
            RomanticParticleColors.softPink,
            _random.nextDouble(),
          )!.withOpacity(0.05 + _random.nextDouble() * 0.1),
          type: type,
          maxLife: 25.0 + _random.nextDouble() * 20,
          rotationSpeed: 0,
          pulsePhase: _random.nextDouble() * 2 * pi,
          driftPhase: _random.nextDouble() * 2 * pi,
        );
    }
  }

  void _drawGlowParticles(Canvas canvas, Size size) {
    final glowPaint =
        Paint()
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    for (final particle in particles) {
      if (particle.type != ParticleType.glow) continue;

      final pulse = sin(particle.pulsePhase) * 0.3 + 0.7;
      final currentSize = particle.size * pulse;

      glowPaint.color = particle.color.withOpacity(
        particle.opacity * 0.5 * pulse,
      );

      canvas.drawCircle(
        Offset(
          particle.position.dx * size.width,
          particle.position.dy * size.height,
        ),
        currentSize,
        glowPaint,
      );
    }
  }

  void _drawDustParticles(Canvas canvas, Size size) {
    final dustPaint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      if (particle.type != ParticleType.dust) continue;

      final pulse = sin(particle.pulsePhase) * 0.2 + 0.8;
      dustPaint.color = particle.color.withOpacity(particle.opacity * pulse);

      canvas.drawCircle(
        Offset(
          particle.position.dx * size.width,
          particle.position.dy * size.height,
        ),
        particle.size,
        dustPaint,
      );
    }
  }

  void _drawSparkleParticles(Canvas canvas, Size size) {
    final sparklePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;

    for (final particle in particles) {
      if (particle.type != ParticleType.sparkle) continue;

      final center = Offset(
        particle.position.dx * size.width,
        particle.position.dy * size.height,
      );

      final pulse = sin(particle.pulsePhase * 3) * 0.4 + 0.6;
      final sparkleSize = particle.size * pulse;

      sparklePaint.color = particle.color.withOpacity(particle.opacity * pulse);

      // Draw sparkle as crossing lines
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(particle.rotation);

      // Vertical line
      canvas.drawLine(
        Offset(0, -sparkleSize),
        Offset(0, sparkleSize),
        sparklePaint,
      );

      // Horizontal line
      canvas.drawLine(
        Offset(-sparkleSize, 0),
        Offset(sparkleSize, 0),
        sparklePaint,
      );

      // Diagonal lines for extra sparkle
      final diagonalSize = sparkleSize * 0.7;
      canvas.drawLine(
        Offset(-diagonalSize * 0.7, -diagonalSize * 0.7),
        Offset(diagonalSize * 0.7, diagonalSize * 0.7),
        sparklePaint..strokeWidth = 1,
      );
      canvas.drawLine(
        Offset(diagonalSize * 0.7, -diagonalSize * 0.7),
        Offset(-diagonalSize * 0.7, diagonalSize * 0.7),
        sparklePaint,
      );

      canvas.restore();
    }
  }

  void _drawHeartParticles(Canvas canvas, Size size) {
    final heartPaint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      if (particle.type != ParticleType.heart) continue;

      final center = Offset(
        particle.position.dx * size.width,
        particle.position.dy * size.height,
      );

      final pulse = sin(particle.pulsePhase) * 0.2 + 0.8;
      final heartSize = particle.size * pulse;

      heartPaint.color = particle.color.withOpacity(particle.opacity * pulse);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(particle.rotation);
      canvas.scale(heartSize / 10); // Normalize to unit size

      // Draw heart shape
      final path = Path();
      path.moveTo(0, 3);

      // Left curve
      path.cubicTo(-5, -2, -8, 0, -4, 2);
      path.cubicTo(-2, 3, 0, 5, 0, 3);

      // Right curve
      path.cubicTo(0, 5, 2, 3, 4, 2);
      path.cubicTo(8, 0, 5, -2, 0, 3);

      canvas.drawPath(path, heartPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant RomanticParticleSystemPainter oldDelegate) =>
      true;
}

// Morphing heart painter
class MorphingHeartPainter extends CustomPainter {
  final double morphProgress;
  final double glowIntensity;
  final double pulseProgress;

  MorphingHeartPainter({
    required this.morphProgress,
    required this.glowIntensity,
    required this.pulseProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    // Animated pulse
    final pulseRadius = radius * (1 + sin(pulseProgress * 2 * pi) * 0.1);

    // Glow effect
    final glowPaint =
        Paint()
          ..color = RomanticParticleColors.warmRed.withValues(
            alpha: glowIntensity * 0.3,
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, pulseRadius * 1.5, glowPaint);

    // Main heart shape
    final heartPaint =
        Paint()
          ..shader = RadialGradient(
            colors: [
              RomanticParticleColors.warmRed,
              RomanticParticleColors.roseGold,
              RomanticParticleColors.softPink.withValues(alpha: 0.8),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: pulseRadius));

    // Draw morphing heart shape
    final path = Path();

    // Heart shape with morphing
    final heartWidth = pulseRadius * morphProgress;
    final heartHeight = pulseRadius * morphProgress;

    if (morphProgress > 0) {
      // Simplified heart shape
      path.moveTo(center.dx, center.dy + heartHeight * 0.3);

      // Left curve
      path.quadraticBezierTo(
        center.dx - heartWidth * 0.8,
        center.dy - heartHeight * 0.5,
        center.dx - heartWidth * 0.3,
        center.dy - heartHeight * 0.2,
      );

      // Top left
      path.quadraticBezierTo(
        center.dx - heartWidth * 0.1,
        center.dy - heartHeight * 0.7,
        center.dx,
        center.dy - heartHeight * 0.3,
      );

      // Top right
      path.quadraticBezierTo(
        center.dx + heartWidth * 0.1,
        center.dy - heartHeight * 0.7,
        center.dx + heartWidth * 0.3,
        center.dy - heartHeight * 0.2,
      );

      // Right curve
      path.quadraticBezierTo(
        center.dx + heartWidth * 0.8,
        center.dy - heartHeight * 0.5,
        center.dx,
        center.dy + heartHeight * 0.3,
      );

      canvas.drawPath(path, heartPaint);
    } else {
      // Start as a circle
      canvas.drawCircle(center, pulseRadius, heartPaint);
    }
  }

  @override
  bool shouldRepaint(covariant MorphingHeartPainter oldDelegate) {
    return oldDelegate.morphProgress != morphProgress ||
        oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.pulseProgress != pulseProgress;
  }
}
