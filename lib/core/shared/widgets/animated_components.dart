// lib/shared/widgets/animated_components.dart
import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
// import '../../constants/app_dimensions.dart';

class FadeSlideTransition extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final Curve curve;

  const FadeSlideTransition({
    super.key,
    required this.child,
    this.delay = const Duration(milliseconds: 0),
    this.duration = const Duration(milliseconds: 400),
    this.offset = const Offset(0, 50),
    this.curve = Curves.easeOutQuad,
  });

  @override
  Widget build(BuildContext context) {
    return DelayedDisplay(
      delay: delay,
      slidingBeginOffset: offset,
      fadingDuration: duration,
      child: child,
    );
  }
}

class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration initialDelay;
  final Duration itemDelay;
  final Offset offset;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.initialDelay = const Duration(milliseconds: 100),
    this.itemDelay = const Duration(milliseconds: 50),
    this.offset = const Offset(0, 50),
  });

  @override
  Widget build(BuildContext context) {
    final delay = initialDelay + (itemDelay * index);

    return FadeSlideTransition(delay: delay, offset: offset, child: child);
  }
}

class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final bool repeat;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.minScale = 0.95,
    this.maxScale = 1.05,
    this.repeat = true,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: widget.maxScale),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: widget.maxScale, end: widget.minScale),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: widget.minScale, end: 1),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.repeat) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(scale: _animation.value, child: child);
      },
      child: widget.child,
    );
  }
}
