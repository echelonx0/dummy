// lib/shared/widgets/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_dimensions.dart';
import '../../../constants/app_text_styles.dart';
import 'package:delayed_display/delayed_display.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final IconData? prefixIcon;
  final Widget? suffix;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final bool readOnly;
  final EdgeInsets? contentPadding;
  final Duration? delayDuration;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.validator,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.prefixIcon,
    this.suffix,
    this.focusNode,
    this.onTap,
    this.readOnly = false,
    this.contentPadding,
    this.delayDuration,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update internal state when widget properties change
    if (oldWidget.obscureText != widget.obscureText) {
      _obscureText = widget.obscureText;
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textField = _buildTextField();

    if (widget.delayDuration != null) {
      return DelayedDisplay(delay: widget.delayDuration!, child: textField);
    }

    return textField;
  }

  Widget _buildTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTextStyles.label),
          const SizedBox(height: AppDimensions.paddingS),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon:
                widget.prefixIcon != null
                    ? Icon(
                      widget.prefixIcon,
                      color: AppColors.textMedium,
                      size: 20,
                    )
                    : null,
            suffixIcon: _buildSuffix(),
            contentPadding:
                widget.contentPadding ??
                const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingM,
                ),
            filled: true,
            fillColor:
                widget.enabled
                    ? AppColors.inputBackground
                    : AppColors.inputBackground.withOpacity(0.5),
          ),
          style: AppTextStyles.bodyMedium.copyWith(
            color: widget.enabled ? AppColors.textOnDark : AppColors.textDark,
          ),
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.textCapitalization,
          maxLines: _obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          validator: widget.validator,
          inputFormatters: widget.inputFormatters,
          onTap: widget.onTap,
          readOnly: widget.readOnly,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
        ),
      ],
    );
  }

  Widget? _buildSuffix() {
    // First priority: use provided suffix widget
    if (widget.suffix != null) {
      return widget.suffix;
    }

    // Second priority: provide visibility toggle for password fields
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppColors.textMedium,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    // Otherwise, no suffix
    return null;
  }
}
