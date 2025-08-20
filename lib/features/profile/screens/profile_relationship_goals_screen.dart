// lib/features/profile/screens/profile_relationship_goals_screen.dart
import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khedoo/generated/l10n.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/shared/widgets/custom_button.dart';
import '../../../app/locator.dart';
import '../widgets/profile_step_indicator.dart';
import 'profile_deep_questions_screen.dart';

class ProfileRelationshipGoalsScreen extends StatefulWidget {
  const ProfileRelationshipGoalsScreen({super.key});

  @override
  State<ProfileRelationshipGoalsScreen> createState() =>
      _ProfileRelationshipGoalsScreenState();
}

class _ProfileRelationshipGoalsScreenState
    extends State<ProfileRelationshipGoalsScreen> {
  final _authService = locator<AuthService>();
  final _firebaseService = locator<FirebaseService>();

  bool _isLoading = false;

  // Relationship type
  String? _relationshipType;
  final List<String> _relationshipTypes = [
    'Long-term commitment',
    'Marriage and family',
    'Serious dating',
    'Casual dating',
    'Friendship first',
    'Still exploring options',
  ];

  // Partner qualities
  List<String> _selectedQualities = [];

  // Dealbreakers
  final TextEditingController _dealbreakersController = TextEditingController();

  // Family importance
  double _familyImportance = 5.0; // 0 = Not important, 10 = Very important

  // Religious importance
  double _religionImportance = 5.0; // 0 = Not important, 10 = Very important

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _dealbreakersController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    try {
      final user = _authService.getCurrentUser();

      if (user != null) {
        final profileDoc = await _firebaseService.getDocumentById(
          'profiles',
          user.uid,
        );

        if (profileDoc.exists) {
          final data = profileDoc.data() as Map<String, dynamic>;

          setState(() {
            // Load relationship type if exists
            _relationshipType = data['relationshipType'];

            // Load partner qualities if exist
            if (data['partnerCoreValues'] != null &&
                data['partnerCoreValues'] is List) {
              _selectedQualities = List<String>.from(data['partnerCoreValues']);
            }

            // Load dealbreakers if exist
            if (data['dealbreakers'] != null) {
              _dealbreakersController.text = data['dealbreakers'];
            }

            // Load importance values if exist
            _familyImportance = data['importanceOfFamily'] ?? 5.0;
            _religionImportance = data['importanceOfReligion'] ?? 5.0;
          });
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        Helpers.showErrorModal(
          context,
          message: 'Failed to load profile data: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _saveAndContinue() async {
    // Validate required fields
    if (_relationshipType == null) {
      Helpers.showErrorModal(
        context,
        message: 'Please select a relationship type',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _authService.getCurrentUser();

      if (user != null) {
        // Update profile data in Firestore
        await _firebaseService.updateDocument('profiles', user.uid, {
          'relationshipType': _relationshipType,
          'partnerCoreValues': _selectedQualities,
          'dealbreakers': _dealbreakersController.text.trim(),
          'importanceOfFamily': _familyImportance,
          'importanceOfReligion': _religionImportance,
          'completionStatus.relationshipGoals': 'completed',
          'completionPercentage': FieldValue.increment(12.5),
          'lastUpdated': Timestamp.now(),
        });

        if (mounted) {
          // Navigate to next step
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ProfileDeepQuestionsScreen(),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorModal(
          context,
          message: 'Failed to save profile data: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleQuality(String quality) {
    setState(() {
      if (_selectedQualities.contains(quality)) {
        _selectedQualities.remove(quality);
      } else {
        _selectedQualities.add(quality);
      }
    });
  }

  String _getImportanceLabel(double value) {
    if (value < 2) return 'Not Important';
    if (value < 4) return 'Somewhat Important';
    if (value < 6) return 'Moderately Important';
    if (value < 8) return 'Very Important';
    return 'Extremely Important';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Suggested partner qualities
    final List<String> partnerQualities = [
      'Honest',
      'Kind',
      'Intelligent',
      'Ambitious',
      'Loyal',
      'Funny',
      'Empathetic',
      'Adventurous',
      'Confident',
      'Patient',
      'Creative',
      'Spiritual',
      'Family-oriented',
      'Independent',
      'Reliable',
      'Supportive',
      'Passionate',
      'Optimistic',
      'Communicative',
      'Respectful',
      'Open-minded',
      'Affectionate',
      'Driven',
      'Thoughtful',
      'Humble',
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.relationshipGoalsTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Column(
                  children: [
                    // Step Indicator
                    const ProfileStepIndicator(currentStep: 5, totalSteps: 8),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppDimensions.paddingL),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and Description
                            DelayedDisplay(
                              delay: const Duration(milliseconds: 100),
                              child: Text(
                                l10n.relationshipGoalsTitle,
                                style: AppTextStyles.heading2,
                              ),
                            ),

                            const SizedBox(height: AppDimensions.paddingM),

                            DelayedDisplay(
                              delay: const Duration(milliseconds: 200),
                              child: Text(
                                l10n.relationshipGoalsDesc,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textOnDark,
                                ),
                              ),
                            ),

                            const SizedBox(height: AppDimensions.paddingXL),

                            // Relationship Type Section
                            DelayedDisplay(
                              delay: const Duration(milliseconds: 300),
                              child: Container(
                                padding: const EdgeInsets.all(
                                  AppDimensions.paddingL,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusL,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'What type of relationship are you seeking?',
                                      style: AppTextStyles.heading3.copyWith(
                                        fontSize: 18,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingM,
                                    ),
                                    const SizedBox(
                                      height: AppDimensions.paddingM,
                                    ),

                                    Text(
                                      'Select the option that best describes what you\'re looking for',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.backgroundDark,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingL,
                                    ),

                                    // Relationship Type options
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _relationshipTypes.length,
                                      itemBuilder: (context, index) {
                                        final type = _relationshipTypes[index];
                                        final isSelected =
                                            _relationshipType == type;

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: AppDimensions.paddingM,
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                _relationshipType = type;
                                              });
                                            },
                                            borderRadius: BorderRadius.circular(
                                              AppDimensions.radiusM,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(
                                                AppDimensions.paddingM,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    isSelected
                                                        ? AppColors
                                                            .primaryDarkBlue
                                                            .withOpacity(0.1)
                                                        : AppColors
                                                            .inputBackground,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppDimensions.radiusM,
                                                    ),
                                                border: Border.all(
                                                  color:
                                                      isSelected
                                                          ? AppColors
                                                              .primaryDarkBlue
                                                          : AppColors.divider,
                                                  width: isSelected ? 2 : 1,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    isSelected
                                                        ? Icons
                                                            .radio_button_checked
                                                        : Icons
                                                            .radio_button_unchecked,
                                                    color:
                                                        isSelected
                                                            ? AppColors
                                                                .primaryDarkBlue
                                                            : AppColors
                                                                .textMedium,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(
                                                    width:
                                                        AppDimensions.paddingM,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      type,
                                                      style: AppTextStyles
                                                          .bodyMedium
                                                          .copyWith(
                                                            fontWeight:
                                                                isSelected
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .normal,
                                                            color:
                                                                isSelected
                                                                    ? AppColors
                                                                        .primaryDarkBlue
                                                                    : AppColors
                                                                        .textDark,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: AppDimensions.paddingL),

                            // Partner Qualities Section
                            DelayedDisplay(
                              delay: const Duration(milliseconds: 400),
                              child: Container(
                                padding: const EdgeInsets.all(
                                  AppDimensions.paddingL,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusL,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'What qualities do you value in a partner?',
                                      style: AppTextStyles.heading3.copyWith(
                                        fontSize: 18,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingM,
                                    ),

                                    Text(
                                      'Select qualities that are important to you',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.backgroundDark,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingL,
                                    ),

                                    // Selected qualities
                                    if (_selectedQualities.isNotEmpty) ...[
                                      Text(
                                        'Your Selections:',
                                        style: AppTextStyles.label,
                                      ),

                                      const SizedBox(
                                        height: AppDimensions.paddingS,
                                      ),

                                      Wrap(
                                        spacing: AppDimensions.paddingS,
                                        runSpacing: AppDimensions.paddingS,
                                        children:
                                            _selectedQualities.map((quality) {
                                              return _buildQualityChip(
                                                quality,
                                                true,
                                                () => _toggleQuality(quality),
                                              );
                                            }).toList(),
                                      ),

                                      const SizedBox(
                                        height: AppDimensions.paddingL,
                                      ),
                                    ],

                                    // Suggested qualities
                                    Text(
                                      'Suggested Qualities:',
                                      style: AppTextStyles.label,
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingS,
                                    ),

                                    Wrap(
                                      spacing: AppDimensions.paddingS,
                                      runSpacing: AppDimensions.paddingS,
                                      children:
                                          partnerQualities.map((quality) {
                                            final isSelected =
                                                _selectedQualities.contains(
                                                  quality,
                                                );
                                            return _buildQualityChip(
                                              quality,
                                              isSelected,
                                              () => _toggleQuality(quality),
                                            );
                                          }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: AppDimensions.paddingL),

                            // Dealbreakers Section
                            DelayedDisplay(
                              delay: const Duration(milliseconds: 500),
                              child: Container(
                                padding: const EdgeInsets.all(
                                  AppDimensions.paddingL,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusL,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'What are your dealbreakers?',
                                      style: AppTextStyles.heading3.copyWith(
                                        fontSize: 18,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingM,
                                    ),

                                    Text(
                                      'List any absolute dealbreakers for a potential partner',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.backgroundDark,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingL,
                                    ),

                                    TextField(
                                      controller: _dealbreakersController,
                                      decoration: InputDecoration(
                                        hintText:
                                            'Examples: smoking, different political values, etc.',
                                        filled: true,
                                        fillColor: AppColors.inputBackground,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppDimensions.radiusM,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: const EdgeInsets.all(
                                          AppDimensions.paddingM,
                                        ),
                                      ),
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textDark,
                                      ),
                                      minLines: 3,
                                      maxLines: 5,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: AppDimensions.paddingL),

                            // Importance Sliders Section
                            DelayedDisplay(
                              delay: const Duration(milliseconds: 600),
                              child: Container(
                                padding: const EdgeInsets.all(
                                  AppDimensions.paddingL,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusL,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Importance Ratings',
                                      style: AppTextStyles.heading3.copyWith(
                                        fontSize: 18,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingM,
                                    ),

                                    Text(
                                      'Rate how important these factors are to you',
                                      style: AppTextStyles.bodySmall,
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingL,
                                    ),

                                    // Family Importance
                                    _buildImportanceSlider(
                                      'Family Importance',
                                      'How important is family in your life?',
                                      _familyImportance,
                                      (value) => setState(
                                        () => _familyImportance = value,
                                      ),
                                      _getImportanceLabel(_familyImportance),
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingL,
                                    ),

                                    // Religion Importance
                                    _buildImportanceSlider(
                                      'Religious/Spiritual Importance',
                                      'How important is religion or spirituality in your life?',
                                      _religionImportance,
                                      (value) => setState(
                                        () => _religionImportance = value,
                                      ),
                                      _getImportanceLabel(_religionImportance),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: AppDimensions.paddingXL),

                            // Info About Relationship Goals
                            DelayedDisplay(
                              delay: const Duration(milliseconds: 700),
                              child: Container(
                                padding: const EdgeInsets.all(
                                  AppDimensions.paddingL,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySageGreen.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusM,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.lightbulb_outline,
                                          color: AppColors.cream,
                                          size: 20,
                                        ),
                                        const SizedBox(
                                          width: AppDimensions.paddingS,
                                        ),
                                        Text(
                                          'Why Relationship Goals Matter',
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.cream,
                                              ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingM,
                                    ),

                                    Text(
                                      'Being clear about what you want in a relationship helps our AI find compatible matches who share your vision for the future. This alignment on fundamental relationship goals is crucial for long-term satisfaction.',
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Button Bar
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: DelayedDisplay(
                        delay: const Duration(milliseconds: 800),
                        child: CustomButton(
                          text: 'Save & Continue',
                          onPressed: _saveAndContinue,
                          isLoading: _isLoading,
                          type: ButtonType.primary,
                          icon: Icons.arrow_forward,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildQualityChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDarkBlue : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: isSelected ? AppColors.primaryDarkBlue : AppColors.divider,
            width: 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primaryDarkBlue.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? Colors.white : AppColors.backgroundDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingS),
            Icon(
              isSelected ? Icons.check : Icons.add,
              color: isSelected ? Colors.white : AppColors.textMedium,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportanceSlider(
    String title,
    String description,
    double value,
    ValueChanged<double> onChanged,
    String currentLabel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.label),

        const SizedBox(height: AppDimensions.paddingXS),

        Text(
          description,
          style: AppTextStyles.caption.copyWith(color: AppColors.textMedium),
        ),

        const SizedBox(height: AppDimensions.paddingM),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentLabel,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.cream,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.paddingS),

        Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                'Not Important',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMedium,
                ),
              ),
            ),

            Expanded(
              child: Slider(
                value: value,
                min: 0,
                max: 10,
                divisions: 10,
                activeColor: AppColors.primaryDarkBlue,
                inactiveColor: AppColors.divider,
                onChanged: onChanged,
              ),
            ),

            SizedBox(
              width: 80,
              child: Text(
                'Very Important',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMedium,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
