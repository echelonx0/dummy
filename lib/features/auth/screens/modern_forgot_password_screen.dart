// lib/features/auth/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/locator.dart';
import '../../../core/services/auth_service.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../generated/l10n.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_text_field.dart';

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

  // Premium auth colors
  static const Color _primaryBlue = Color(0xFF1A365D);
  static const Color _accentGold = Color(0xFFC9A959);
  static const Color _successGreen = Color(0xFF95E1A3);
  static const Color _softBlue = Color(0xFF4ECDC4);

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
      await _authService.sendPasswordResetEmail(_emailController.text.trim());

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _emailSent
                  ? _successGreen.withValues(green: _successGreen.green * 0.8)
                  : _softBlue.withValues(blue: _softBlue.blue * 0.8),
              _primaryBlue.withAlpha(0.9 as int),
              _primaryBlue,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              _buildAppBar(),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),

                          // Header Section
                          _buildHeader(l10n),
                          const SizedBox(height: 40),

                          // Main Content Card
                          _buildContentCard(l10n),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(0.2 as int),
                border: Border.all(
                  color: Colors.white.withAlpha(0.3 as int),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        // Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withAlpha(0.15 as int),
            border: Border.all(
              color: Colors.white.withAlpha(0.3 as int),
              width: 1,
            ),
          ),
          child: Icon(
            _emailSent ? Icons.check_circle_rounded : Icons.lock_reset_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),

        // Title
        Text(
          _emailSent ? 'Reset Email Sent' : 'Reset Password',
          style: AppTextStyles.heading2.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          _emailSent
              ? 'Please check your email for reset instructions'
              : 'Enter your email to receive reset instructions',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white.withAlpha(0.9 as int),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContentCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(0.1 as int),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _emailSent ? _buildSuccessContent(l10n) : _buildFormContent(l10n),
    );
  }

  Widget _buildFormContent(AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Error Message
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _softBlue, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: _softBlue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'We\'ll send password reset instructions to your email address.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _softBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Email Field
          PremiumTextField(
            controller: _emailController,
            hint: l10n.email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.email_rounded,
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
          const SizedBox(height: 24),

          // Send Reset Link Button
          PremiumButton(
            text: 'Send Reset Link',
            onPressed: _sendResetEmail,
            isLoading: _isLoading,
            type: PremiumButtonType.primary,
            isFullWidth: true,
            customColor: _softBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success Message
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _successGreen,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _successGreen, width: 1),
          ),
          child: Column(
            children: [
              Icon(
                Icons.mark_email_read_rounded,
                color: _successGreen,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                'Reset email sent successfully!',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _successGreen,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'If an account exists with this email, you will receive password reset instructions within a few minutes.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: _successGreen,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Instructions
        Text(
          'Didn\'t receive the email?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '• Check your spam folder\n• Make sure the email address is correct\n• Wait a few minutes for delivery',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMedium,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Back to Login Button
        PremiumButton(
          text: 'Back to Login',
          onPressed: () => Navigator.of(context).pop(),
          type: PremiumButtonType.primary,
          isFullWidth: true,
          customColor: _primaryBlue,
        ),
        const SizedBox(height: 12),

        // Resend Email Button
        PremiumButton(
          text: 'Resend Email',
          onPressed: () {
            setState(() {
              _emailSent = false;
              _errorMessage = null;
            });
          },
          type: PremiumButtonType.outlined,
          isFullWidth: true,
          customColor: _accentGold,
        ),
      ],
    );
  }
}
