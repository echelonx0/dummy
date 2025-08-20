// lib/features/profile/screens/profile_core_values_screen.dart
import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/utils/helpers.dart';
import '../../../generated/l10n.dart';
import '../../../core/shared/widgets/custom_button.dart';
import '../../../app/locator.dart';
import '../widgets/profile_step_indicator.dart';

import '../widgets/voice_recorder_widget.dart';
import '../widgets/core_value_chip.dart';
import 'profile_lifestyle_screen.dart';

class ProfileCoreValuesScreen extends StatefulWidget {
  const ProfileCoreValuesScreen({super.key});

  @override
  State<ProfileCoreValuesScreen> createState() =>
      _ProfileCoreValuesScreenState();
}

class _ProfileCoreValuesScreenState extends State<ProfileCoreValuesScreen> {
  final _coreValuesController = TextEditingController();
  final _authService = locator<AuthService>();
  final _firebaseService = locator<FirebaseService>();

  bool _isLoading = false;
  bool _dataLoaded = false;
  List<String> _selectedValues = [];
  String? _transcribedText;

  // Suggested core values
  final List<String> _suggestedValues = [
    'Honesty',
    'Integrity',
    'Family',
    'Loyalty',
    'Adventure',
    'Creativity',
    'Independence',
    'Knowledge',
    'Spirituality',
    'Health',
    'Growth',
    'Balance',
    'Compassion',
    'Ambition',
    'Courage',
    'Humor',
    'Respect',
    'Trust',
    'Freedom',
    'Community',
    'Security',
    'Passion',
    'Optimism',
    'Reliability',
    'Empathy',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _coreValuesController.dispose();
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

          if (data['coreValues'] != null && data['coreValues'] is List) {
            setState(() {
              _selectedValues = List<String>.from(data['coreValues']);
            });
          }
        }
      }

      setState(() {
        _isLoading = false;
        _dataLoaded = true;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _dataLoaded = true;
        });

        Helpers.showErrorModal(
          context,
          message: 'Failed to load profile data: ${e.toString()}',
        );
      }
    }
  }

  void _addCustomValue() {
    final value = _coreValuesController.text.trim();

    if (value.isNotEmpty) {
      setState(() {
        // Add only if not already in the list
        if (!_selectedValues.contains(value)) {
          _selectedValues.add(value);
        }
        _coreValuesController.clear();
      });
    }
  }

  void _toggleValue(String value) {
    setState(() {
      if (_selectedValues.contains(value)) {
        _selectedValues.remove(value);
      } else {
        // Limit to 5 core values
        if (_selectedValues.length < 5) {
          _selectedValues.add(value);
        } else {
          Helpers.showInfoModal(
            context,
            message:
                'You can select up to 5 core values. Please remove one before adding another.',
          );
        }
      }
    });
  }

  void _handleTranscribedText(String text) {
    setState(() {
      _transcribedText = text;

      // Extract potential core values from transcription
      _processTranscription(text);
    });
  }

  void _processTranscription(String text) {
    // This is a simple implementation - in a real app,
    // you would use NLP to extract values from text

    final sentences = text.split(RegExp(r'[.!?]'));
    final potentialValues = <String>[];

    // Simple extraction of capitalized words and phrases
    for (var sentence in sentences) {
      final words = sentence.trim().split(' ');
      for (var word in words) {
        if (word.length > 3 &&
            word[0] == word[0].toUpperCase() &&
            !['I', 'My', 'The', 'And', 'But', 'For', 'With'].contains(word)) {
          potentialValues.add(Helpers.capitalizeWords(word));
        }
      }
    }

    // Match against suggested values
    for (var value in _suggestedValues) {
      if (text.toLowerCase().contains(value.toLowerCase()) &&
          !_selectedValues.contains(value) &&
          _selectedValues.length < 5) {
        setState(() {
          _selectedValues.add(value);
        });
      }
    }

    // Suggest the extracted values
    if (potentialValues.isNotEmpty && mounted) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Extracted Core Values'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'We found these potential core values in your recording:',
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        potentialValues.map((value) {
                          return ActionChip(
                            label: Text(value),
                            onPressed: () {
                              Navigator.of(context).pop();
                              if (_selectedValues.length < 5 &&
                                  !_selectedValues.contains(value)) {
                                setState(() {
                                  _selectedValues.add(value);
                                });
                              } else if (_selectedValues.contains(value)) {
                                Helpers.showInfoModal(
                                  context,
                                  message: 'This value is already selected.',
                                );
                              } else {
                                Helpers.showInfoModal(
                                  context,
                                  message:
                                      'You can select up to 5 core values. Please remove one before adding another.',
                                );
                              }
                            },
                          );
                        }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
      );
    }
  }

  Future<void> _saveAndContinue() async {
    if (_selectedValues.isEmpty) {
      Helpers.showErrorModal(
        context,
        message: 'Please select at least one core value',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _authService.getCurrentUser();

      if (user != null) {
        // Update profile data in Firestore
        await _firebaseService.updateDocument('profiles', user.uid, {
          'coreValues': _selectedValues,
          'completionStatus.coreValues': 'completed',
          'completionPercentage': FieldValue.increment(12.5),
          'lastUpdated': Timestamp.now(),
        });

        if (mounted) {
          // Navigate to next step
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ProfileLifestyleScreen(),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.coreValuesTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          _isLoading && !_dataLoaded
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Column(
                  children: [
                    // Step Indicator
                    const ProfileStepIndicator(currentStep: 3, totalSteps: 8),

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
                                l10n.coreValuesTitle,
                                style: AppTextStyles.heading2,
                              ),
                            ),

                            const SizedBox(height: AppDimensions.paddingM),

                            DelayedDisplay(
                              delay: const Duration(milliseconds: 200),
                              child: Text(
                                l10n.coreValuesDesc,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),

                            const SizedBox(height: AppDimensions.paddingXL),

                            // Voice Input Section
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
                                      'Speak About Your Core Values',
                                      style: AppTextStyles.heading3.copyWith(
                                        fontSize: 18,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingM,
                                    ),

                                    Text(
                                      'Tap the microphone to describe the principles and values that guide your life. We\'ll help extract the key values from your description.',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.backgroundDark,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingL,
                                    ),

                                    // Voice Recorder
                                    VoiceRecorderWidget(
                                      onTranscriptionComplete:
                                          _handleTranscribedText,
                                    ),

                                    // Show transcribed text if available
                                    if (_transcribedText != null &&
                                        _transcribedText!.isNotEmpty) ...[
                                      const SizedBox(
                                        height: AppDimensions.paddingM,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(
                                          AppDimensions.paddingM,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.inputBackground,
                                          borderRadius: BorderRadius.circular(
                                            AppDimensions.radiusM,
                                          ),
                                          border: Border.all(
                                            color: AppColors.divider,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Transcription:',
                                              style: AppTextStyles.label,
                                            ),
                                            const SizedBox(
                                              height: AppDimensions.paddingS,
                                            ),
                                            Text(
                                              _transcribedText!,
                                              style: AppTextStyles.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: AppDimensions.paddingL),

                            // Manual Input Section
                            DelayedDisplay(
                              delay: const Duration(milliseconds: 400),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selected Core Values (${_selectedValues.length}/5)',
                                    style: AppTextStyles.label,
                                  ),

                                  const SizedBox(
                                    height: AppDimensions.paddingS,
                                  ),

                                  // Selected Values
                                  Wrap(
                                    spacing: AppDimensions.paddingS,
                                    runSpacing: AppDimensions.paddingS,
                                    children:
                                        _selectedValues.map((value) {
                                          return CoreValueChip(
                                            label: value,
                                            isSelected: true,
                                            onTap: () => _toggleValue(value),
                                          );
                                        }).toList(),
                                  ),

                                  if (_selectedValues.isEmpty) ...[
                                    const SizedBox(
                                      height: AppDimensions.paddingM,
                                    ),
                                    Text(
                                      'Please select or add at least one core value',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textMedium,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],

                                  const SizedBox(
                                    height: AppDimensions.paddingL,
                                  ),

                                  // Custom Value Input
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _coreValuesController,
                                          decoration: InputDecoration(
                                            hintText: 'Add a custom value...',
                                            filled: true,
                                            fillColor:
                                                AppColors.inputBackground,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppDimensions.radiusM,
                                                  ),
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal:
                                                      AppDimensions.paddingM,
                                                  vertical:
                                                      AppDimensions.paddingM,
                                                ),
                                          ),
                                          textCapitalization:
                                              TextCapitalization.words,
                                          onSubmitted: (_) => _addCustomValue(),
                                        ),
                                      ),

                                      const SizedBox(
                                        width: AppDimensions.paddingM,
                                      ),

                                      IconButton(
                                        onPressed: _addCustomValue,
                                        icon: const Icon(Icons.add_circle),
                                        color: AppColors.primaryDarkBlue,
                                        tooltip: 'Add custom value',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: AppDimensions.paddingL),

                            // Suggested Values
                            DelayedDisplay(
                              delay: const Duration(milliseconds: 500),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Suggested Core Values',
                                    style: AppTextStyles.label,
                                  ),

                                  const SizedBox(
                                    height: AppDimensions.paddingS,
                                  ),

                                  Wrap(
                                    spacing: AppDimensions.paddingS,
                                    runSpacing: AppDimensions.paddingS,
                                    children:
                                        _suggestedValues.map((value) {
                                          final isSelected = _selectedValues
                                              .contains(value);
                                          return CoreValueChip(
                                            label: value,
                                            isSelected: isSelected,
                                            onTap: () => _toggleValue(value),
                                          );
                                        }).toList(),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: AppDimensions.paddingXL),

                            // Info About Core Values
                            DelayedDisplay(
                              delay: const Duration(milliseconds: 600),
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
                                          color: AppColors.primaryDarkBlue,
                                          size: 20,
                                        ),
                                        const SizedBox(
                                          width: AppDimensions.paddingS,
                                        ),
                                        Text(
                                          'Why Core Values Matter',
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
                                      'Your core values represent the fundamental beliefs that guide your decisions and actions. They are essential for finding a partner whose values align with or complement your own.',
                                      style: AppTextStyles.bodySmall,
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingM,
                                    ),

                                    Text(
                                      'Research shows that couples with aligned core values tend to have more satisfying and lasting relationships.',
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
                        delay: const Duration(milliseconds: 700),
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
}
