// lib/features/onboarding/screens/feedback_style_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';
import '../../../constants/app_constants.dart';
import '../../../generated/l10n.dart';
import '../../../core/shared/widgets/custom_button.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/auth_service.dart';
import '../../locator.dart';

import '../../app_nav.dart';

// TODO - add localization support for all strings
// TODO - add error handling for network issues
// TODO - add analytics tracking for user selections
// TODO - add to profile screen
class FeedbackStyleSelectionScreen extends StatefulWidget {
  const FeedbackStyleSelectionScreen({super.key});

  @override
  State<FeedbackStyleSelectionScreen> createState() =>
      _FeedbackStyleSelectionScreenState();
}

class _FeedbackStyleSelectionScreenState
    extends State<FeedbackStyleSelectionScreen> {
  final _authService = locator<AuthService>();
  final _firebaseService = locator<FirebaseService>();

  String? _selectedTone;
  String? _selectedStyle;
  String? _selectedFrequency;
  bool _isSaving = false;

  List<FeedbackOption> _toneOptions = [];
  List<FeedbackOption> _styleOptions = [];
  List<FeedbackOption> _frequencyOptions = [];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Initialize options with localized text
    _initializeOptions(l10n);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.personalizeExperience),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        automaticallyImplyLeading:
            false, // Disable back button as this is mandatory
      ),
      body: SafeArea(
        child:
            _isSaving
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Introduction
                      Text(
                        l10n.customizeFeedback,
                        style: AppTextStyles.heading2,
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      Text(
                        l10n.feedbackIntroduction,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textMedium,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingXL),

                      // Tone Selection
                      _buildSectionTitle(l10n.chooseTone, '1'),
                      ..._toneOptions.map(
                        (option) => _buildSelectionCard(
                          option,
                          isSelected: _selectedTone == option.id,
                          onTap: () {
                            setState(() {
                              _selectedTone = option.id;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingXL),

                      // Style Selection
                      _buildSectionTitle(l10n.chooseStyle, '2'),
                      ..._styleOptions.map(
                        (option) => _buildSelectionCard(
                          option,
                          isSelected: _selectedStyle == option.id,
                          onTap: () {
                            setState(() {
                              _selectedStyle = option.id;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingXL),

                      // Frequency Selection
                      _buildSectionTitle(l10n.chooseFrequency, '3'),
                      ..._frequencyOptions.map(
                        (option) => _buildSelectionCard(
                          option,
                          isSelected: _selectedFrequency == option.id,
                          onTap: () {
                            setState(() {
                              _selectedFrequency = option.id;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingXXL),

                      // Continue Button
                      Center(
                        child: CustomButton(
                          text: l10n.saveAndContinue,
                          onPressed: () => _savePreferencesAndContinue(l10n),
                          type: ButtonType.primary,
                          icon: Icons.check,
                          isFullWidth: true,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingL),

                      // Note about changing later
                      Center(
                        child: Text(
                          l10n.canChangePreferences,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMedium,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  void _initializeOptions(AppLocalizations l10n) {
    _toneOptions = [
      FeedbackOption(
        id: 'direct',
        title: l10n.directToneTitle,
        description: l10n.directToneDescription,
        icon: Icons.arrow_forward,
      ),
      FeedbackOption(
        id: 'balanced',
        title: l10n.balancedToneTitle,
        description: l10n.balancedToneDescription,
        icon: Icons.balance,
      ),
      FeedbackOption(
        id: 'gentle',
        title: l10n.gentleToneTitle,
        description: l10n.gentleToneDescription,
        icon: Icons.favorite,
      ),
    ];

    _styleOptions = [
      FeedbackOption(
        id: 'analytical',
        title: l10n.analyticalStyleTitle,
        description: l10n.analyticalStyleDescription,
        icon: Icons.analytics,
      ),
      FeedbackOption(
        id: 'narrative',
        title: l10n.narrativeStyleTitle,
        description: l10n.narrativeStyleDescription,
        icon: Icons.menu_book,
      ),
      FeedbackOption(
        id: 'visual',
        title: l10n.visualStyleTitle,
        description: l10n.visualStyleDescription,
        icon: Icons.bar_chart,
      ),
    ];

    _frequencyOptions = [
      FeedbackOption(
        id: 'weekly',
        title: l10n.weeklyFrequencyTitle,
        description: l10n.weeklyFrequencyDescription,
        icon: Icons.calendar_today,
      ),
      FeedbackOption(
        id: 'biweekly',
        title: l10n.biweeklyFrequencyTitle,
        description: l10n.biweeklyFrequencyDescription,
        icon: Icons.calendar_month,
      ),
      FeedbackOption(
        id: 'monthly',
        title: l10n.monthlyFrequencyTitle,
        description: l10n.monthlyFrequencyDescription,
        icon: Icons.event,
      ),
      FeedbackOption(
        id: 'onDemand',
        title: l10n.onDemandFrequencyTitle,
        description: l10n.onDemandFrequencyDescription,
        icon: Icons.pan_tool,
      ),
    ];
  }

  Future<void> _savePreferencesAndContinue(AppLocalizations l10n) async {
    if (_selectedTone == null ||
        _selectedStyle == null ||
        _selectedFrequency == null) {
      // Show error if not all options are selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.selectAllPreferences),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.feedbackToneKey, _selectedTone!);
      await prefs.setString(AppConstants.feedbackStyleKey, _selectedStyle!);
      await prefs.setString(
        AppConstants.feedbackFrequencyKey,
        _selectedFrequency!,
      );
      await prefs.setBool(AppConstants.hasCompletedTourKey, true);

      final user = _authService.getCurrentUser();

      if (user != null) {
        // Save feedback preferences to user profile
        await _firebaseService.updateDocument('profiles', user.uid, {
          'feedbackPreferences': {
            'tone': _selectedTone,
            'style': _selectedStyle,
            'frequency': _selectedFrequency,
            'lastUpdated': DateTime.now(),
          },
          'onboardingComplete': true,
        });
      }

      // Navigate to dashboard after saving
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorSavingPreferences}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildSectionTitle(String title, String number) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Text('$number. $title', style: AppTextStyles.heading3),
    );
  }

  Widget _buildSelectionCard(
    FeedbackOption option, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primaryDarkBlue.withOpacity(0.1)
                  : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color:
                isSelected ? AppColors.primaryDarkBlue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? AppColors.primaryDarkBlue
                        : AppColors.primaryDarkBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                option.icon,
                color: isSelected ? Colors.white : AppColors.primaryDarkBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingXS),
                  Text(
                    option.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            Radio(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primaryDarkBlue,
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbackOption {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  FeedbackOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}
