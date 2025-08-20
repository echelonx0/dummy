// lib/shared/widgets/glassmorphic_card.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../constants/app_dimensions.dart';

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double blurAmount;
  final Color tintColor;
  final double tintOpacity;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = AppDimensions.radiusL,
    this.padding = const EdgeInsets.all(AppDimensions.paddingL),
    this.margin = EdgeInsets.zero,
    this.blurAmount = 10.0,
    this.tintColor = Colors.white,
    this.tintOpacity = 0.2,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: tintColor.withOpacity(tintOpacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border:
                  border ??
                  Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
