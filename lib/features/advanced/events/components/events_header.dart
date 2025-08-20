// Enhanced Events Header with Gradient and Particles
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';

class EnhancedEventsHeader extends StatefulWidget {
  final TabController tabController;
  final VoidCallback onSearchPressed;
  final Widget? categoryFilter;

  const EnhancedEventsHeader({
    super.key,
    required this.tabController,
    required this.onSearchPressed,
    this.categoryFilter,
  });

  @override
  State<EnhancedEventsHeader> createState() => _EnhancedEventsHeaderState();
}

class _EnhancedEventsHeaderState extends State<EnhancedEventsHeader>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Particle> _particles = [];
  final int _particleCount = 15;

  @override
  void initState() {
    super.initState();

    // Particle animation controller
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Fade in animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // Initialize particles
    _initializeParticles();

    // Start animations
    _fadeController.forward();
  }

  void _initializeParticles() {
    _particles.clear();
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(Particle());
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primarySageGreen,
            AppColors.primarySageGreen.withValues(alpha: 0.8),
            AppColors.primaryAccent.withValues(alpha: 0.6),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySageGreen.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated particles background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(
                    particles: _particles,
                    animationValue: _particleController.value,
                  ),
                );
              },
            ),
          ),

          // Gradient overlay for better text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),

          // Header content
          FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Navigation and title row
                  Row(
                    children: [
                      // Enhanced back button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Title section with animation
                      Expanded(
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _fadeController,
                              curve: Curves.easeOut,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Events',
                                style: AppTextStyles.heading2.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Connect, learn, and find your person',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w500,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Enhanced search button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          onPressed: widget.onSearchPressed,
                          icon: const Icon(
                            Icons.search_rounded,
                            color: Colors.white,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Category filter (for All Events tab)
                  if (widget.categoryFilter != null &&
                      widget.tabController.index == 0) ...[
                    const SizedBox(height: 20),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _fadeController,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: widget.categoryFilter!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Particle class for animation
class Particle {
  late double x;
  late double y;
  late double size;
  late double speedX;
  late double speedY;
  late double opacity;
  late Color color;

  Particle() {
    reset();
  }

  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    size = math.Random().nextDouble() * 4 + 1;
    speedX = (math.Random().nextDouble() - 0.5) * 0.002;
    speedY = (math.Random().nextDouble() - 0.5) * 0.002;
    opacity = math.Random().nextDouble() * 0.6 + 0.2;

    // Random white/light colors for particles
    final colorValue = math.Random().nextDouble() * 0.3 + 0.7;
    color = Color.fromRGBO(
      (255 * colorValue).round(),
      (255 * colorValue).round(),
      (255 * colorValue).round(),
      opacity,
    );
  }

  void update() {
    x += speedX;
    y += speedY;

    // Wrap around screen
    if (x > 1.0) x = 0.0;
    if (x < 0.0) x = 1.0;
    if (y > 1.0) y = 0.0;
    if (y < 0.0) y = 1.0;

    // Slightly vary opacity for twinkling effect
    opacity = math.max(
      0.1,
      math.min(0.8, opacity + (math.Random().nextDouble() - 0.5) * 0.1),
    );
  }
}

// Custom painter for particles
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter({required this.particles, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.update();

      final paint =
          Paint()
            ..color = particle.color.withValues(alpha: particle.opacity)
            ..style = PaintingStyle.fill;

      final position = Offset(
        particle.x * size.width,
        particle.y * size.height,
      );

      // Draw particle as a circle with slight glow effect
      canvas.drawCircle(position, particle.size, paint);

      // Add subtle glow
      final glowPaint =
          Paint()
            ..color = particle.color.withValues(alpha: particle.opacity * 0.3)
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(position, particle.size * 2, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
