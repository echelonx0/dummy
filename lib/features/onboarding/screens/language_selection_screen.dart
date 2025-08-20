// lib/features/onboarding/screens/language_selection_screen.dart

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khedoo/features/auth/screens/modern_register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../core/services/localization_service.dart';
import '../widgets/language_modal.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _floatingController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatingAnimation;

  String _selectedLanguage = 'en';
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
    _setupSystemUI();
  }

  void _setupSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF222831),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _floatingAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _slideController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final languages = LocalizationService.getSupportedLanguages();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Subtle romantic background elements
          _buildBackgroundElements(size),

          // Main content
          SafeArea(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _fadeController,
                _slideController,
                _scaleController,
              ]),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value.dy * 50),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Spacer(flex: 2),

                          // Logo section
                          _buildLogoSection(),

                          const SizedBox(height: 60),

                          // Language selection card
                          Transform.scale(
                            scale: _scaleAnimation.value,
                            child: _buildLanguageSelectionCard(languages),
                          ),

                          const Spacer(flex: 3),

                          // Continue button
                          _buildContinueButton(),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundElements(Size size) {
    return Stack(
      children: [
        // Top gradient circle
        Positioned(
          top: -100,
          right: -100,
          child: AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  _floatingAnimation.value * 0.5,
                  _floatingAnimation.value * 0.3,
                ),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primarySageGreen.withValues(alpha: 0.1),
                        AppColors.primarySageGreen.withValues(alpha: 0.02),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Bottom gradient circle
        Positioned(
          bottom: -150,
          left: -150,
          child: AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  -_floatingAnimation.value * 0.3,
                  -_floatingAnimation.value * 0.5,
                ),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryAccent.withValues(alpha: 0.08),
                        AppColors.primaryAccent.withValues(alpha: 0.01),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Subtle floating dots
        Positioned(
          top: size.height * 0.2,
          right: 30,
          child: AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatingAnimation.value * 0.8),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryGold.withValues(alpha: 0.3),
                  ),
                ),
              );
            },
          ),
        ),

        Positioned(
          top: size.height * 0.4,
          left: 50,
          child: AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -_floatingAnimation.value * 0.6),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryAccent.withValues(alpha: 0.4),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // App logo with elegant styling
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primarySageGreen, AppColors.primaryAccent],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primarySageGreen.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.favorite, color: Colors.white, size: 36),
        ),

        const SizedBox(height: 24),

        // Welcome text
        Text(
          'Welcome to Khedoo',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        Text(
          _getLocalizedLanguageText(),
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textMedium,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLanguageSelectionCard(List<Map<String, String>> languages) {
    final selectedLanguage = languages.firstWhere(
      (lang) => lang['code'] == _selectedLanguage,
      orElse: () => {'name': 'English', 'code': 'en'},
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardBackground,
            AppColors.primaryGold.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primarySageGreen.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkBlue.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openLanguageModal,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // Language flag circle
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primarySageGreen.withValues(alpha: 0.2),
                        AppColors.primaryAccent.withValues(alpha: 0.1),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.primarySageGreen.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getLanguageFlag(_selectedLanguage),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                // Language info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedLanguage['name']!,
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _getLocalizedTapToChangeText(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),

                // Elegant arrow
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primarySageGreen.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppColors.primarySageGreen.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primarySageGreen,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primarySageGreen, AppColors.primaryAccent],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySageGreen.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isTransitioning ? null : _confirmLanguage,
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child:
                _isTransitioning
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getLocalizedContinueText(),
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  void _openLanguageModal() {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder:
          (context) => LanguageSelectionModal(
            selectedLanguage: _selectedLanguage,
            onLanguageSelected: (String languageCode) {
              setState(() {
                _selectedLanguage = languageCode;
              });
            },
          ),
    );
  }

  void _confirmLanguage() async {
    if (_isTransitioning) return;

    setState(() {
      _isTransitioning = true;
    });

    HapticFeedback.mediumImpact();

    try {
      // Set the locale
      await LocalizationService.setLocale(_selectedLanguage);

      // Set the language selection flag
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_selected_language', true);

      log(
        '[LanguageSelection] Language set to $_selectedLanguage and flag updated',
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) =>
                  const RegisterScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
    } catch (error) {
      print('[LanguageSelection] Error setting language: $error');
      setState(() {
        _isTransitioning = false;
      });
    }
  }

  // Localization helpers
  String _getLocalizedLanguageText() {
    switch (_selectedLanguage) {
      case 'fr':
        return 'Pour commencer, choisissez votre langue préférée';
      case 'sw':
        return 'Ili kuanza, chagua lugha unayopendelea';
      case 'en':
      default:
        return 'To begin, choose your preferred language';
    }
  }

  String _getLocalizedTapToChangeText() {
    switch (_selectedLanguage) {
      case 'fr':
        return 'Touchez pour voir toutes les langues';
      case 'sw':
        return 'Gusa kuona lugha zote';
      case 'en':
      default:
        return 'Tap to see all languages';
    }
  }

  String _getLocalizedContinueText() {
    switch (_selectedLanguage) {
      case 'fr':
        return 'Commencer';
      case 'sw':
        return 'Anza';
      case 'en':
      default:
        return 'Continue';
    }
  }

  String _getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'fr':
        return '🇫🇷';
      case 'sw':
        return '🇰🇪';
      case 'en':
      default:
        return '🇺🇸';
    }
  }
}
