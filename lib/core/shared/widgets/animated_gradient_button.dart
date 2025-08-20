// lib/shared/widgets/animated_gradient_button.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_dimensions.dart';
import '../../../constants/app_text_styles.dart';

class AnimatedGradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double height;
  final bool isFullWidth;
  final IconData? icon;
  final bool isLoading;

  const AnimatedGradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height = 56.0,
    this.isFullWidth = false,
    this.icon,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<AnimatedGradientButton> createState() => _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<AnimatedGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Alignment> _alignmentBeginAnimation;
  late Animation<Alignment> _alignmentEndAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _alignmentBeginAnimation = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.bottomLeft,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _alignmentEndAnimation = Tween<Alignment>(
      begin: Alignment.topRight,
      end: Alignment.bottomRight,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animController.reverse();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading ? null : _handleTapDown,
      onTapUp: widget.isLoading ? null : _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                width: widget.isFullWidth ? double.infinity : widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: _alignmentBeginAnimation.value,
                    end: _alignmentEndAnimation.value,
                    colors: [
                      AppColors.primaryDarkBlue,
                      Color.lerp(
                        AppColors.primaryDarkBlue,
                        const Color(0xFF2A4A7D),
                        0.7,
                      )!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(widget.height / 2),
                  boxShadow:
                      _isPressed
                          ? []
                          : [
                            BoxShadow(
                              color: AppColors.primaryDarkBlue.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                              spreadRadius: -2,
                            ),
                          ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Center(
                    child:
                        widget.isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 2.5,
                              ),
                            )
                            : Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.icon != null) ...[
                                  Icon(
                                    widget.icon,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppDimensions.paddingM),
                                ],
                                Text(
                                  widget.text,
                                  style: AppTextStyles.button.copyWith(
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
