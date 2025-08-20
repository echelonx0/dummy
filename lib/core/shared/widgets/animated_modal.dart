// lib/shared/widgets/animated_modal.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_dimensions.dart';
import '../../../constants/app_text_styles.dart';
import 'package:delayed_display/delayed_display.dart';

enum ModalType { success, error, info, warning }

class AnimatedModal {
  static void show({
    required BuildContext context,
    required String message,
    String? title,
    ModalType type = ModalType.info,
    VoidCallback? onDismiss,
    Duration duration = const Duration(seconds: 3),
    Widget? actionButton,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      builder:
          (context) => _AnimatedModalContent(
            message: message,
            title: title,
            type: type,
            onDismiss: onDismiss,
            duration: duration,
            actionButton: actionButton,
          ),
    );
  }
}

class _AnimatedModalContent extends StatefulWidget {
  final String message;
  final String? title;
  final ModalType type;
  final VoidCallback? onDismiss;
  final Duration duration;
  final Widget? actionButton;

  const _AnimatedModalContent({
    required this.message,
    this.title,
    required this.type,
    this.onDismiss,
    required this.duration,
    this.actionButton,
  });

  @override
  _AnimatedModalContentState createState() => _AnimatedModalContentState();
}

class _AnimatedModalContentState extends State<_AnimatedModalContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    if (widget.duration != Duration.zero) {
      Future.delayed(widget.duration, _startCloseAnimation);
    }
  }

  void _startCloseAnimation() {
    if (mounted && !_isClosing) {
      setState(() => _isClosing = true);
      _controller.reverse().then((_) {
        Navigator.of(context).pop();
        if (widget.onDismiss != null) {
          widget.onDismiss!();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColorForType() {
    switch (widget.type) {
      case ModalType.success:
        return AppColors.success;
      case ModalType.error:
        return AppColors.error;
      case ModalType.warning:
        return AppColors.warning;
      case ModalType.info:
        return AppColors.info;
    }
  }

  IconData _getIconForType() {
    switch (widget.type) {
      case ModalType.success:
        return Icons.check_circle_outline;
      case ModalType.error:
        return Icons.error_outline;
      case ModalType.warning:
        return Icons.warning_amber_outlined;
      case ModalType.info:
        return Icons.info_outline;
    }
  }

  String _getTitleForType() {
    if (widget.title != null) return widget.title!;

    switch (widget.type) {
      case ModalType.success:
        return 'Success';
      case ModalType.error:
        return 'Error';
      case ModalType.warning:
        return 'Warning';
      case ModalType.info:
        return 'Information';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForType();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _animation.value) * 100),
          child: Opacity(opacity: _animation.value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.radiusL),
                    topRight: Radius.circular(AppDimensions.radiusL),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIconForType(),
                      color: color,
                      size: AppDimensions.iconSizeM,
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                    Expanded(
                      child: DelayedDisplay(
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          _getTitleForType(),
                          style: AppTextStyles.heading3.copyWith(
                            color: color,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _startCloseAnimation,
                      color: AppColors.textMedium,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: DelayedDisplay(
                  delay: const Duration(milliseconds: 300),
                  child: Text(widget.message, style: AppTextStyles.bodyMedium),
                ),
              ),
              if (widget.actionButton != null)
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppDimensions.paddingL,
                    right: AppDimensions.paddingL,
                    bottom: AppDimensions.paddingL,
                  ),
                  child: DelayedDisplay(
                    delay: const Duration(milliseconds: 400),
                    child: widget.actionButton!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
