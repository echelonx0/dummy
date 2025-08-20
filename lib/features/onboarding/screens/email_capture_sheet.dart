// Email capture component for future outreach
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_dimensions.dart';
import '../../../constants/app_text_styles.dart';
import '../../../core/shared/widgets/custom_button.dart';
import '../../../generated/l10n.dart';

class EmailCaptureBottomSheet extends StatefulWidget {
  final Function(String) onEmailSubmitted;

  const EmailCaptureBottomSheet({super.key, required this.onEmailSubmitted});

  @override
  State<EmailCaptureBottomSheet> createState() =>
      _EmailCaptureBottomSheetState();
}

class _EmailCaptureBottomSheetState extends State<EmailCaptureBottomSheet> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).viewInsets.bottom + AppDimensions.paddingL,
        left: AppDimensions.paddingL,
        right: AppDimensions.paddingL,
        top: AppDimensions.paddingL,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusL),
          topRight: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingL),

                Text(
                  l10n.stayConnected,
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingM),

                Text(
                  l10n.emailCaptureDescription,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMedium,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDimensions.paddingL),

                // Email input
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.emailAddress,
                    hintText: l10n.emailPlaceholder,
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppColors.primarySageGreen,
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return l10n.pleaseEnterEmail;
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value!)) {
                      return l10n.pleaseEnterValidEmail;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.paddingL),

                // ✅ FIXED: Primary "Set Reminder" button (full width, on top)
                _isSubmitting
                    ? Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primarySageGreen.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryAccent,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.paddingM),
                            Text(
                              l10n.saving,
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.primaryAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : CustomButton(
                      text: l10n.setReminder,
                      onPressed: _submitEmail,
                      type: ButtonType.primary,
                      isFullWidth: true,
                    ),

                const SizedBox(height: AppDimensions.paddingM),

                // ✅ FIXED: Secondary "Cancel" button (full width, below)
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(
                      color: AppColors.textMedium.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap:
                          _isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.textMedium,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    widget.onEmailSubmitted(_emailController.text.trim());

    Navigator.of(context).pop();
  }
}
