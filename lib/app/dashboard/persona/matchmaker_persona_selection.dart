// lib/features/onboarding/screens/matchmaker_persona_selection_screen.dart
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

class MatchmakerPersonaSelectionScreen extends StatefulWidget {
  const MatchmakerPersonaSelectionScreen({super.key});

  @override
  State<MatchmakerPersonaSelectionScreen> createState() =>
      _MatchmakerPersonaSelectionScreenState();
}

class _MatchmakerPersonaSelectionScreenState
    extends State<MatchmakerPersonaSelectionScreen> {
  final _authService = locator<AuthService>();
  final _firebaseService = locator<FirebaseService>();

  String? _selectedPersona;
  String? _selectedStyle;
  String? _selectedFrequency;
  bool _isSaving = false;

  List<MatchmakerPersona> _personaOptions = [];
  List<FeedbackOption> _styleOptions = [];
  List<FeedbackOption> _frequencyOptions = [];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Initialize options with localized text
    _initializeOptions(l10n);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('Choose Your Matchmaker', style: TextStyle(fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        automaticallyImplyLeading: true,
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
                        'Meet Your AI Matchmakers',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      Text(
                        'Choose the matchmaker whose communication style resonates with you. This will personalize how you receive insights and guidance.',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textMedium,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingXL),

                      // Persona Selection
                      _buildSectionTitle('Choose Your Matchmaker', '1'),
                      ..._personaOptions.map(
                        (persona) => _buildPersonaCard(
                          persona,
                          isSelected: _selectedPersona == persona.id,
                          onTap: () {
                            setState(() {
                              _selectedPersona = persona.id;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingXL),

                      // Style Selection
                      _buildSectionTitle('Insight Style', '2'),
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
                      _buildSectionTitle('Check-in Frequency', '3'),
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
                          text: 'Save My Preferences',
                          onPressed: () => _savePreferencesAndContinue(l10n),
                          type: ButtonType.primary,
                          icon: Icons.favorite,
                          isFullWidth: true,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingL),

                      // Note about changing later
                      Center(
                        child: Text(
                          'You can change these preferences anytime in your profile settings.',
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
    _personaOptions = [
      MatchmakerPersona(
        id: 'sage',
        name: 'Sophia the Sage',
        description: 'Wise, thoughtful, and philosophical approach to love',
        sampleText:
            '"True connection happens when two people see each other\'s authentic selves. Your journey toward love is also a journey toward understanding yourself more deeply."',
        icon: Icons.auto_awesome,
        gradientColors: [
          const Color(0xFF6366F1), // Indigo
          const Color(0xFF8B5CF6), // Purple
        ],
      ),
      MatchmakerPersona(
        id: 'cheerleader',
        name: 'Maya the Cheerleader',
        description: 'Encouraging, optimistic, and motivational guidance',
        sampleText:
            '"You\'re absolutely amazing and the right person is going to be so lucky to find you! Let\'s work on showing your incredible personality even more clearly. You\'ve got this! 💫"',
        icon: Icons.celebration,
        gradientColors: [
          const Color(0xFFEC4899), // Pink
          const Color(0xFFF97316), // Orange
        ],
      ),
      MatchmakerPersona(
        id: 'strategist',
        name: 'Alex the Strategist',
        description: 'Direct, analytical, and results-focused approach',
        sampleText:
            '"Based on your profile analysis, here are three specific areas to improve your match compatibility. Focus on these actionable steps to increase your success rate by 40%."',
        icon: Icons.psychology,
        gradientColors: [
          const Color(0xFF059669), // Emerald
          const Color(0xFF0891B2), // Cyan
        ],
      ),
      MatchmakerPersona(
        id: 'empath',
        name: 'Luna the Empath',
        description: 'Gentle, understanding, and emotionally supportive',
        sampleText:
            '"I sense that dating might feel overwhelming sometimes. That\'s completely normal. Let\'s take this one gentle step at a time, honoring your feelings along the way."',
        icon: Icons.favorite_border,
        gradientColors: [
          const Color(0xFFA855F7), // Purple
          const Color(0xFFEC4899), // Pink
        ],
      ),
    ];

    _styleOptions = [
      FeedbackOption(
        id: 'visual',
        title: 'Visual Insights',
        description: 'Charts, progress bars, and visual representations',
        icon: Icons.bar_chart,
      ),
      FeedbackOption(
        id: 'narrative',
        title: 'Story-Based',
        description: 'Detailed explanations with examples and context',
        icon: Icons.menu_book,
      ),
      FeedbackOption(
        id: 'quick',
        title: 'Quick Highlights',
        description: 'Concise bullet points and key takeaways',
        icon: Icons.flash_on,
      ),
    ];

    _frequencyOptions = [
      FeedbackOption(
        id: 'weekly',
        title: 'Weekly Check-ins',
        description: 'Regular guidance and progress updates',
        icon: Icons.calendar_today,
      ),
      FeedbackOption(
        id: 'biweekly',
        title: 'Bi-weekly Updates',
        description: 'Balanced approach with thoughtful insights',
        icon: Icons.calendar_month,
      ),
      FeedbackOption(
        id: 'monthly',
        title: 'Monthly Deep-Dives',
        description: 'Comprehensive monthly relationship analysis',
        icon: Icons.event,
      ),
      FeedbackOption(
        id: 'onDemand',
        title: 'On-Demand Only',
        description: 'Insights when you specifically request them',
        icon: Icons.pan_tool,
      ),
    ];
  }

  Widget _buildPersonaCard(
    MatchmakerPersona persona, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingL),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? LinearGradient(
                    colors: persona.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          color: isSelected ? null : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected
                    ? Colors.transparent
                    : AppColors.primarySageGreen.withValues(alpha: 0.2),
            width: isSelected ? 0 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
                      ? persona.gradientColors.first.withValues(alpha: 0.3)
                      : AppColors.primaryDarkBlue.withValues(alpha: 0.1),
              blurRadius: isSelected ? 20 : 8,
              offset: Offset(0, isSelected ? 8 : 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Colors.white.withValues(alpha: 0.2)
                              : persona.gradientColors.first.withValues(
                                alpha: 0.1,
                              ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isSelected
                                ? Colors.white.withValues(alpha: 0.3)
                                : persona.gradientColors.first.withValues(
                                  alpha: 0.3,
                                ),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      persona.icon,
                      color:
                          isSelected
                              ? Colors.white
                              : persona.gradientColors.first,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          persona.name,
                          style: AppTextStyles.heading3.copyWith(
                            color:
                                isSelected ? Colors.white : AppColors.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          persona.description,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color:
                                isSelected
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: persona.gradientColors.first,
                        size: 16,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Colors.white.withValues(alpha: 0.15)
                          : AppColors.primarySageGreen.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected
                            ? Colors.white.withValues(alpha: 0.3)
                            : AppColors.primarySageGreen.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sample Guidance:',
                      style: AppTextStyles.caption.copyWith(
                        color:
                            isSelected
                                ? Colors.white.withValues(alpha: 0.8)
                                : AppColors.textMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      persona.sampleText,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color:
                            isSelected
                                ? Colors.white.withValues(alpha: 0.95)
                                : AppColors.textDark,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String number) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Text(
        '$number. $title',
        style: AppTextStyles.heading3.copyWith(color: AppColors.textDark),
      ),
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
                  ? AppColors.primarySageGreen.withValues(alpha: 0.1)
                  : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color:
                isSelected
                    ? AppColors.primarySageGreen
                    : AppColors.primarySageGreen.withValues(alpha: 0.2),
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
                        ? AppColors.primarySageGreen
                        : AppColors.primarySageGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                option.icon,
                color:
                    isSelected
                        ? AppColors.primaryAccent
                        : AppColors.primarySageGreen,
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
                      color: AppColors.textDark,
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
              activeColor: AppColors.primarySageGreen,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePreferencesAndContinue(AppLocalizations l10n) async {
    if (_selectedPersona == null ||
        _selectedStyle == null ||
        _selectedFrequency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select all preferences'),
          backgroundColor: AppColors.error,
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
      await prefs.setString('matchmaker_persona', _selectedPersona!);
      await prefs.setString('insight_style', _selectedStyle!);
      await prefs.setString('checkin_frequency', _selectedFrequency!);
      await prefs.setBool(AppConstants.hasCompletedTourKey, true);

      final user = _authService.getCurrentUser();

      if (user != null) {
        // Save matchmaker preferences to user profile
        await _firebaseService.updateDocument('profiles', user.uid, {
          'matchmakerPreferences': {
            'persona': _selectedPersona,
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
            content: Text('Error saving preferences: $e'),
            backgroundColor: AppColors.error,
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
}

class MatchmakerPersona {
  final String id;
  final String name;
  final String description;
  final String sampleText;
  final IconData icon;
  final List<Color> gradientColors;

  MatchmakerPersona({
    required this.id,
    required this.name,
    required this.description,
    required this.sampleText,
    required this.icon,
    required this.gradientColors,
  });
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
