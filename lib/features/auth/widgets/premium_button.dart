// lib/shared/widgets/premium_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../utils/color_utils.dart';

enum PremiumButtonType { primary, outlined, ghost }

class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final PremiumButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? customColor;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = PremiumButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.customColor,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _resetPress();
  }

  void _onTapCancel() {
    _resetPress();
  }

  void _resetPress() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  Color get _buttonColor {
    if (widget.customColor != null) return widget.customColor!;

    switch (widget.type) {
      case PremiumButtonType.primary:
        return AppColors.primaryDarkBlue;
      case PremiumButtonType.outlined:
      case PremiumButtonType.ghost:
        return AppColors.primaryDarkBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onPressed,
            child: Container(
              width: widget.isFullWidth ? double.infinity : null,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient:
                    widget.type == PremiumButtonType.primary
                        ? LinearGradient(
                          colors: [
                            _buttonColor,
                            _buttonColor.withValues(
                              red: _buttonColor.red * 0.9,
                            ),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                        : null,
                color:
                    widget.type != PremiumButtonType.primary
                        ? Colors.transparent
                        : null,
                border:
                    widget.type == PremiumButtonType.outlined
                        ? Border.all(color: _buttonColor, width: 1.5)
                        : null,
                boxShadow:
                    isEnabled
                        ? [
                          // Subtle glow effect
                          BoxShadow(
                            color: _buttonColor.glowVariant,
                            blurRadius: 8 + (_glowAnimation.value * 4),
                            offset: const Offset(0, 2),
                          ),
                          // Enhanced glow on press
                          if (_isPressed)
                            BoxShadow(
                              color: _buttonColor.glowVariant,
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                        ]
                        : null,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient:
                      _isPressed && widget.type == PremiumButtonType.primary
                          ? LinearGradient(
                            colors: [
                              Colors.white.withAlpha(01),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                          : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Center(
                    child:
                        widget.isLoading
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.type == PremiumButtonType.primary
                                      ? Colors.white
                                      : _buttonColor,
                                ),
                              ),
                            )
                            : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.icon != null) ...[
                                  Icon(
                                    widget.icon,
                                    color:
                                        widget.type == PremiumButtonType.primary
                                            ? Colors.white
                                            : _buttonColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  widget.text,
                                  style: AppTextStyles.button.copyWith(
                                    color:
                                        widget.type == PremiumButtonType.primary
                                            ? Colors.white
                                            : _buttonColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
