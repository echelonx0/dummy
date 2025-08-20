// lib/shared/widgets/animated_background.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../constants/app_colors.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool isActive;

  const AnimatedBackground({
    Key? key,
    required this.child,
    this.isActive = true,
  }) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Bubble> _bubbles;
  final int _numberOfBubbles = 6;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _bubbles = List.generate(
      _numberOfBubbles,
      (index) => Bubble(
        color: _getBubbleColor(index),
        size: _getBubbleSize(index),
        speed: _getBubbleSpeed(index),
        initialPosition: _getInitialPosition(index),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBubbleColor(int index) {
    if (index % 3 == 0) {
      return AppColors.primaryDarkBlue.withOpacity(0.04);
    } else if (index % 3 == 1) {
      return AppColors.primaryGold.withOpacity(0.04);
    } else {
      return AppColors.primarySageGreen.withOpacity(0.04);
    }
  }

  double _getBubbleSize(int index) {
    final random = math.Random(index);
    return random.nextDouble() * 200 + 100; // 100-300
  }

  double _getBubbleSpeed(int index) {
    final random = math.Random(index * 3);
    return random.nextDouble() * 0.2 + 0.1; // 0.1-0.3
  }

  Offset _getInitialPosition(int index) {
    final random = math.Random(index * 7);
    return Offset(
      random.nextDouble() * 1.5 - 0.5, // -0.5 to 1.0
      random.nextDouble() * 1.5 - 0.5, // -0.5 to 1.0
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.isActive)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: BubblePainter(
                  bubbles: _bubbles,
                  progress: _controller.value,
                ),
                size: MediaQuery.of(context).size,
              );
            },
          ),
        widget.child,
      ],
    );
  }
}

class Bubble {
  final Color color;
  final double size;
  final double speed;
  final Offset initialPosition;

  Bubble({
    required this.color,
    required this.size,
    required this.speed,
    required this.initialPosition,
  });
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final double progress;

  BubblePainter({required this.bubbles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < bubbles.length; i++) {
      final bubble = bubbles[i];
      final offset = _calculatePosition(bubble, size, progress);

      final paint =
          Paint()
            ..color = bubble.color
            ..style = PaintingStyle.fill;

      canvas.drawCircle(offset, bubble.size, paint);
    }
  }

  Offset _calculatePosition(Bubble bubble, Size size, double progress) {
    // Create a unique animation for each bubble based on its speed
    final adjustedProgress = (progress * bubble.speed) % 1.0;

    // Movement pattern
    final xOffset = math.sin(adjustedProgress * math.pi * 2) * 0.1;
    final yOffset = math.cos(adjustedProgress * math.pi * 2) * 0.1;

    // Create movement based on initial position
    final x = ((bubble.initialPosition.dx + xOffset) * size.width);
    final y = ((bubble.initialPosition.dy + yOffset) * size.height);

    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant BubblePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
