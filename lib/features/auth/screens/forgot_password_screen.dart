// lib/features/auth/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/locator.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/shared/widgets/custom_button.dart';
import '../../../core/shared/widgets/custom_text_field.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_dimensions.dart';
import '../../../constants/app_text_styles.dart';
import '../../../generated/l10n.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = locator<AuthService>();

  bool _isLoading = false;
  String? _errorMessage;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ✅ FIXED: Pass context for localized error messages
      await _authService.sendPasswordResetEmail(
        _emailController.text.trim(),
        context,
      );

      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDark),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 450),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon
                    Icon(
                      _emailSent ? Icons.check_circle : Icons.lock_reset,
                      size: 60,
                      color:
                          _emailSent
                              ? AppColors.success
                              : AppColors.primaryDarkBlue,
                    ),
                    const SizedBox(height: AppDimensions.paddingL),

                    // ✅ FIXED: Localized title
                    Text(
                      _emailSent ? l10n.resetEmailSent : l10n.forgotPassword,
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.primaryDarkBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.paddingM),

                    // ✅ FIXED: Localized description
                    Text(
                      _emailSent
                          ? l10n.resetEmailSuccessMessage
                          : l10n.forgotPasswordInstructions,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),

                    // Error message
                    if (_errorMessage != null && !_emailSent) ...[
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusM,
                          ),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingL),
                    ],

                    if (_emailSent) ...[
                      // ✅ FIXED: Localized success message
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusM,
                          ),
                        ),
                        child: Text(
                          l10n.resetEmailMessage,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.success,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingXL),

                      // ✅ FIXED: Localized button text
                      CustomButton(
                        text: l10n.backToLogin,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        type: ButtonType.primary,
                        isFullWidth: true,
                      ),
                    ] else ...[
                      // Email field
                      CustomTextField(
                        controller: _emailController,
                        hint: l10n.email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.emailRequired;
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return l10n.invalidEmail;
                          }
                          return null;
                        },
                        onSubmitted: (_) => _sendResetEmail(),
                      ),
                      const SizedBox(height: AppDimensions.paddingXL),

                      // ✅ FIXED: Localized button text
                      CustomButton(
                        text: l10n.sendResetLink,
                        onPressed: _sendResetEmail,
                        isLoading: _isLoading,
                        type: ButtonType.primary,
                        isFullWidth: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
