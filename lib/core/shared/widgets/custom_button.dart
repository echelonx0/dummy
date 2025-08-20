// lib/shared/widgets/custom_button.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_dimensions.dart';
import '../../../constants/app_text_styles.dart';

enum ButtonType { primary, secondary, outlined, text, danger }

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final IconData? icon;
  final double? width;
  final double? height;
  final bool isFullWidth;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.icon,
    this.width,
    this.height,
    this.isFullWidth = false,
    this.isLoading = false,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final buttonHeight = widget.height ?? AppDimensions.buttonHeightM;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: GestureDetector(
        onTapDown: widget.isLoading ? null : _handleTapDown,
        onTapUp: widget.isLoading ? null : _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Container(
          width: widget.isFullWidth ? double.infinity : widget.width,
          height: buttonHeight,
          decoration: _getButtonDecoration(),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(buttonHeight / 2),
              splashColor: _getSplashColor(),
              highlightColor: Colors.transparent,
              child: Center(
                child:
                    widget.isLoading
                        ? _buildLoadingIndicator()
                        : _buildButtonContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    final textStyle = _getTextStyle();
    final iconColor = _getIconColor();

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null && widget.type == ButtonType.primary) ...[
          Icon(widget.icon, color: iconColor, size: 20),
          const SizedBox(width: AppDimensions.paddingS),
        ],

        Text(widget.text, style: textStyle),

        if (widget.icon != null && widget.type != ButtonType.primary) ...[
          const SizedBox(width: AppDimensions.paddingS),
          Icon(widget.icon, color: iconColor, size: 20),
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    final Color color;

    switch (widget.type) {
      case ButtonType.primary:
        color = Colors.white;
        break;
      case ButtonType.secondary:
        color = AppColors.primaryDarkBlue;
        break;
      case ButtonType.outlined:
        color = AppColors.primaryDarkBlue;
        break;
      case ButtonType.text:
        color = AppColors.primaryDarkBlue;
        break;
      case ButtonType.danger:
        color = Colors.redAccent;
    }

    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  BoxDecoration _getButtonDecoration() {
    final double borderRadius =
        widget.height != null
            ? widget.height! / 2
            : AppDimensions.buttonHeightM / 2;

    switch (widget.type) {
      case ButtonType.primary:
        return BoxDecoration(
          gradient: LinearGradient(
            colors:
                _isPressed
                    ? [AppColors.primaryDarkBlue, AppColors.primaryDarkBlue]
                    : [
                      AppColors.primaryDarkBlue,
                      Color.lerp(
                        AppColors.primaryDarkBlue,
                        const Color(0xFF2A4A7D),
                        0.5,
                      )!,
                    ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow:
              _isPressed
                  ? []
                  : [
                    BoxShadow(
                      color: AppColors.primaryDarkBlue.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
        );

      case ButtonType.danger:
        return BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow:
              _isPressed
                  ? []
                  : [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
        );

      case ButtonType.secondary:
        return BoxDecoration(
          color: AppColors.primaryGold.withOpacity(_isPressed ? 0.8 : 1.0),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow:
              _isPressed
                  ? []
                  : [
                    BoxShadow(
                      color: AppColors.primaryGold.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
        );

      case ButtonType.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppColors.primaryDarkBlue, width: 1.5),
        );

      case ButtonType.text:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (widget.type) {
      case ButtonType.primary:
        return AppTextStyles.button.copyWith(
          color: Colors.white,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w600,
        );

      case ButtonType.secondary:
        return AppTextStyles.button.copyWith(
          color: AppColors.primaryDarkBlue,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w600,
        );

      case ButtonType.outlined:
        return AppTextStyles.button.copyWith(
          color: AppColors.primaryDarkBlue,
          letterSpacing: 0.5,
        );

      case ButtonType.text:
        return AppTextStyles.button.copyWith(color: AppColors.primaryDarkBlue);
      case ButtonType.danger:
        return AppTextStyles.button.copyWith(
          color: AppColors.textLight,
          letterSpacing: 0.5,
        );
    }
  }

  Color _getIconColor() {
    switch (widget.type) {
      case ButtonType.primary:
        return Colors.white;
      case ButtonType.secondary:
      case ButtonType.outlined:
      case ButtonType.text:
        return AppColors.primaryDarkBlue;
      case ButtonType.danger:
        return AppColors.textLight;
    }
  }

  Color _getSplashColor() {
    switch (widget.type) {
      case ButtonType.primary:
        return Colors.white.withOpacity(0.1);
      case ButtonType.secondary:
        return AppColors.primaryDarkBlue.withOpacity(0.1);
      case ButtonType.outlined:
        return AppColors.primaryDarkBlue.withOpacity(0.05);
      case ButtonType.text:
        return AppColors.primaryDarkBlue.withOpacity(0.05);
      case ButtonType.danger:
        return Colors.white.withOpacity(0.1);
    }
  }
}
