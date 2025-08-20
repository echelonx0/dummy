// lib/features/onboarding/widgets/language_selection_modal.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../core/services/localization_service.dart';

class LanguageSelectionModal extends StatefulWidget {
  final String selectedLanguage;
  final Function(String) onLanguageSelected;

  const LanguageSelectionModal({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  @override
  State<LanguageSelectionModal> createState() => _LanguageSelectionModalState();
}

class _LanguageSelectionModalState extends State<LanguageSelectionModal>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _itemController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _itemAnimation;

  String _tempSelectedLanguage = '';
  List<Map<String, String>> _languages = [];

  @override
  void initState() {
    super.initState();
    _tempSelectedLanguage = widget.selectedLanguage;
    _languages = LocalizationService.getSupportedLanguages();

    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _itemController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _itemAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _itemController, curve: Curves.easeOutBack),
    );
  }

  void _startAnimations() async {
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _itemController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _itemController.dispose();
    super.dispose();
  }

  void _selectLanguage(String languageCode) {
    if (_tempSelectedLanguage == languageCode) return;

    HapticFeedback.selectionClick();
    setState(() {
      _tempSelectedLanguage = languageCode;
    });
  }

  void _confirmSelection() async {
    HapticFeedback.mediumImpact();

    // Animate out
    await _slideController.reverse();
    _fadeController.reverse();

    if (mounted) {
      widget.onLanguageSelected(_tempSelectedLanguage);
      Navigator.of(context).pop();
    }
  }

  void _closeModal() async {
    HapticFeedback.lightImpact();

    // Animate out
    await _slideController.reverse();
    _fadeController.reverse();

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return GestureDetector(
                onTap: _closeModal,
                child: Container(
                  color: Colors.black.withValues(
                    alpha: 0.7 * _fadeAnimation.value,
                  ),
                ),
              );
            },
          ),

          // Modal content
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    MediaQuery.of(context).size.height *
                        _slideAnimation.value.dy,
                  ),
                  child: _buildModalContent(context),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalContent(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A365D), // Deep navy to match your theme
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF1A365D).withValues(alpha: 0.95),
                  const Color(0xFF0F1419).withValues(alpha: 0.98),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModalHeader(),
                _buildLanguageList(),
                _buildModalFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 24),

          // Title
          AnimatedBuilder(
            animation: _itemAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * _itemAnimation.value.clamp(0.0, 1.0)),
                child: Opacity(
                  opacity: _itemAnimation.value.clamp(
                    0.0,
                    1.0,
                  ), // FIXED: Clamped opacity
                  child: Text(
                    _getHeaderText(),
                    style: AppTextStyles.heading2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 28,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          AnimatedBuilder(
            animation: _itemAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  0,
                  20 * (1 - _itemAnimation.value.clamp(0.0, 1.0)),
                ),
                child: Opacity(
                  opacity: _itemAnimation.value.clamp(
                    0.0,
                    1.0,
                  ), // FIXED: Clamped opacity
                  child: Text(
                    _getSubtitleText(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageList() {
    return Flexible(
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final language = _languages[index];
          final isSelected = _tempSelectedLanguage == language['code'];

          return AnimatedBuilder(
            animation: _itemAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  0,
                  30 * (1 - _itemAnimation.value.clamp(0.0, 1.0)),
                ),
                child: Opacity(
                  opacity: _itemAnimation.value.clamp(
                    0.0,
                    1.0,
                  ), // FIXED: Clamped opacity
                  child: _buildLanguageOption(language, isSelected, index),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLanguageOption(
    Map<String, String> language,
    bool isSelected,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectLanguage(language['code']!),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    isSelected
                        ? [
                          AppColors.primaryGold.withValues(alpha: 0.3),
                          AppColors.primaryGold.withValues(alpha: 0.1),
                        ]
                        : [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.05),
                        ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    isSelected
                        ? AppColors.primaryGold
                        : Colors.white.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: AppColors.primaryGold.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                      : [],
            ),
            child: Row(
              children: [
                // Flag
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isSelected
                            ? AppColors.primaryGold.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: Text(
                      _getLanguageFlag(language['code']!),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Language info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language['name']!,
                        style: AppTextStyles.heading3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getLanguageNativeName(language['code']!),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Selection indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isSelected ? AppColors.primaryGold : Colors.transparent,
                    border: Border.all(
                      color:
                          isSelected
                              ? AppColors.primaryGold
                              : Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child:
                      isSelected
                          ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                          : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalFooter() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: AnimatedBuilder(
        animation: _itemAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - _itemAnimation.value.clamp(0.0, 1.0))),
            child: Opacity(
              opacity: _itemAnimation.value.clamp(
                0.0,
                1.0,
              ), // FIXED: Clamped opacity
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGold,
                        AppColors.primaryGold.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGold.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _confirmSelection,
                      borderRadius: BorderRadius.circular(28),
                      child: Center(
                        child: Text(
                          _getConfirmButtonText(),
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
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

  // Helper methods
  String _getHeaderText() {
    switch (_tempSelectedLanguage) {
      case 'fr':
        return 'Choisissez votre langue';
      case 'sw':
        return 'Chagua lugha yako';
      case 'en':
      default:
        return 'Choose your language';
    }
  }

  String _getSubtitleText() {
    switch (_tempSelectedLanguage) {
      case 'fr':
        return 'Sélectionnez votre langue préférée';
      case 'sw':
        return 'Chagua lugha unayopendelea';
      case 'en':
      default:
        return 'Select your preferred language';
    }
  }

  String _getConfirmButtonText() {
    switch (_tempSelectedLanguage) {
      case 'fr':
        return 'Confirmer';
      case 'sw':
        return 'Thibitisha';
      case 'en':
      default:
        return 'Confirm Selection';
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

  String _getLanguageNativeName(String languageCode) {
    switch (languageCode) {
      case 'fr':
        return 'Français';
      case 'sw':
        return 'Kiswahili';
      case 'en':
      default:
        return 'English';
    }
  }
}
