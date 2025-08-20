// lib/features/auth/screens/register_screen.dart
import 'package:flutter/material.dart';
import '../../../app/locator.dart';
import '../../../constants/app_dimensions.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/auth_router_service.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../generated/l10n.dart';
import '../../../core/shared/theme/gradient_theme_system.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_text_field.dart';
import 'modern_login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = locator<AuthService>();
  final _authRouterService = locator<AuthRouterService>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  bool _agreeToTerms = false;

  // Premium auth colors
  static const Color _primaryBlue = Color(0xFF1A365D);

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      setState(() {
        _errorMessage = 'You must agree to the Terms & Privacy Policy';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        context,
      );

      if (!mounted) return;
      await _authRouterService.routeAfterRegistration(context);
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
        decoration: BoxDecoration(gradient: AppGradients.registerGradient),
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
                    child: Column(
                      children: [
                        // Header Section
                        _buildHeader(l10n),
                        const SizedBox(height: 32),

                        // Main Form Card
                        _buildFormCard(l10n),
                      ],
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
                color: Colors.white.withValues(alpha: 0.2),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
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
        // App Icon
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.15),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.favorite_rounded,
            size: 32,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          'Create Your Account',
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
          'Begin your journey to meaningful connections',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormCard(AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive width calculation
        final isTablet = constraints.maxWidth > 600;
        final cardWidth =
            isTablet
                ? constraints.maxWidth *
                    0.6 // 60% on tablets
                : double.infinity; // Full width on phones

        final cardPadding =
            isTablet
                ? AppDimensions
                    .paddingXXL // 48px on tablets
                : AppDimensions.paddingL; // 24px on phones

        return Center(
          child: Container(
            width: cardWidth,
            constraints: BoxConstraints(
              maxWidth: isTablet ? 500 : AppDimensions.maxFormWidth,
              minWidth: 300,
            ),
            padding: EdgeInsets.all(cardPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                isTablet ? AppDimensions.radiusXL : AppDimensions.radiusL,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isTablet ? 0.15 : 0.1),
                  blurRadius: isTablet ? 30 : 20,
                  offset: Offset(0, isTablet ? 12 : 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Your existing form content...
                  _buildFormContent(l10n, isTablet),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Extract form content for cleaner code:
  Widget _buildFormContent(AppLocalizations l10n, bool isTablet) {
    final fieldSpacing =
        isTablet ? AppDimensions.paddingL : AppDimensions.paddingM;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Error Message
        if (_errorMessage != null) ...[
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                isTablet ? AppDimensions.radiusM : AppDimensions.radiusS,
              ),
              border: Border.all(color: AppColors.error, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: isTablet ? 24 : 20,
                ),
                SizedBox(width: isTablet ? 12 : 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                      fontSize: isTablet ? 14 : 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: fieldSpacing),
        ],

        // Name Fields
        Row(
          children: [
            Expanded(
              child: PremiumTextField(
                controller: _firstNameController,
                hint: l10n.firstName,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.person_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.firstNameRequired;
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: isTablet ? 16 : 12),
            Expanded(
              child: PremiumTextField(
                controller: _lastNameController,
                hint: l10n.lastName,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.person_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.lastNameRequired;
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        SizedBox(height: fieldSpacing),

        // Email Field
        PremiumTextField(
          controller: _emailController,
          hint: l10n.email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          prefixIcon: Icons.email_rounded,

          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.emailRequired;
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return l10n.invalidEmail;
            }
            return null;
          },
        ),
        SizedBox(height: fieldSpacing),

        // Password Field
        PremiumTextField(
          controller: _passwordController,
          hint: l10n.password,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          prefixIcon: Icons.key_rounded,
          suffix: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: AppColors.textMedium,
              size: isTablet ? 24 : 20,
            ),
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.passwordRequired;
            }
            if (value.length < 8) {
              return l10n.passwordTooShort;
            }
            return null;
          },
        ),
        SizedBox(height: fieldSpacing),

        // Confirm Password Field
        PremiumTextField(
          controller: _confirmPasswordController,
          hint: l10n.confirmPassword,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          prefixIcon: Icons.key_rounded,
          suffix: IconButton(
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: AppColors.textMedium,
              size: isTablet ? 24 : 20,
            ),
            onPressed: () {
              setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              );
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.confirmPasswordRequired;
            }
            if (value != _passwordController.text) {
              return l10n.passwordsDontMatch;
            }
            return null;
          },
          onSubmitted: (_) => _register(),
        ),
        SizedBox(height: fieldSpacing),

        // Terms Checkbox
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.scale(
              scale: isTablet ? 1.2 : 1.0,
              child: Checkbox(
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() => _agreeToTerms = value ?? false);
                },
                activeColor: const Color(0xFF1A365D),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            SizedBox(width: isTablet ? 12 : 8),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _agreeToTerms = !_agreeToTerms);
                },
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMedium,
                      height: 1.4,
                      fontSize: isTablet ? 16 : 12,
                    ),
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: const Color(0xFF1A365D),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: _primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: fieldSpacing * 1.5),

        // Create Account Button
        PremiumButton(
          text: l10n.createAccount,
          onPressed: _register,
          isLoading: _isLoading,
          type: PremiumButtonType.primary,
          isFullWidth: true,
          customColor: const Color(0xFFFF6B8A),
        ),
        SizedBox(height: fieldSpacing),

        // Divider
        Row(
          children: [
            Expanded(child: Container(height: 1, color: AppColors.divider)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
              child: Text(
                l10n.or,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMedium,
                  fontWeight: FontWeight.w500,
                  fontSize: isTablet ? 14 : 12,
                ),
              ),
            ),
            Expanded(child: Container(height: 1, color: AppColors.divider)),
          ],
        ),

        SizedBox(height: fieldSpacing),

        // Sign In Button
        PremiumButton(
          text: l10n.login,
          onPressed: () {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        const LoginScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 800),
              ),
            );
          },
          isLoading: _isLoading,
          type: PremiumButtonType.outlined,
          isFullWidth: true,
        ),
      ],
    );
  }
}
