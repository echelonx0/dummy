// lib/features/profile/screens/profile_lifestyle_screen.dart
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
import 'profile_relationship_goals_screen.dart';

class ProfileLifestyleScreen extends StatefulWidget {
  const ProfileLifestyleScreen({super.key});

  @override
  State<ProfileLifestyleScreen> createState() => _ProfileLifestyleScreenState();
}

class _ProfileLifestyleScreenState extends State<ProfileLifestyleScreen> {
  final _authService = locator<AuthService>();
  final _firebaseService = locator<FirebaseService>();

  bool _isLoading = false;

  // Lifestyle preference sliders
  double _socialScale = 5.0; // 0 = Very Introverted, 10 = Very Extroverted
  double _activityScale = 5.0; // 0 = Very Relaxed, 10 = Very Active
  double _outdoorScale = 5.0; // 0 = Indoor Person, 10 = Outdoor Person
  double _travelScale = 5.0; // 0 = Homebody, 10 = World Traveler
  double _nightlifeScale = 5.0; // 0 = Early Bird, 10 = Night Owl

  // Selected hobbies and interests
  List<String> _selectedHobbies = [];

  // Typical weekend description
  final TextEditingController _weekendController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _weekendController.dispose();
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

          // Load lifestyle preferences if they exist
          if (data['lifestyle'] != null) {
            final lifestyle = data['lifestyle'] as Map<String, dynamic>;

            setState(() {
              _socialScale = lifestyle['socialScale'] ?? 5.0;
              _activityScale = lifestyle['activityScale'] ?? 5.0;
              _outdoorScale = lifestyle['outdoorScale'] ?? 5.0;
              _travelScale = lifestyle['travelScale'] ?? 5.0;
              _nightlifeScale = lifestyle['nightlifeScale'] ?? 5.0;

              if (lifestyle['idealWeekend'] != null) {
                _weekendController.text = lifestyle['idealWeekend'];
              }
            });
          }

          // Load hobbies if they exist
          if (data['hobbiesAndPassions'] != null &&
              data['hobbiesAndPassions'] is List) {
            setState(() {
              _selectedHobbies = List<String>.from(data['hobbiesAndPassions']);
            });
          }
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
    // Validate weekend description
    if (_weekendController.text.trim().isEmpty) {
      Helpers.showErrorModal(
        context,
        message: 'Please describe your ideal weekend',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _authService.getCurrentUser();

      if (user != null) {
        // Update profile data in Firestore
        await _firebaseService.updateDocument('profiles', user.uid, {
          'lifestyle': {
            'socialScale': _socialScale,
            'activityScale': _activityScale,
            'outdoorScale': _outdoorScale,
            'travelScale': _travelScale,
            'nightlifeScale': _nightlifeScale,
            'idealWeekend': _weekendController.text.trim(),
          },
          'hobbiesAndPassions': _selectedHobbies,
          'completionStatus.lifestyle': 'completed',
          'completionPercentage': FieldValue.increment(12.5),
          'lastUpdated': Timestamp.now(),
        });

        if (mounted) {
          // Navigate to next step
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ProfileRelationshipGoalsScreen(),
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

  void _toggleHobby(String hobby) {
    setState(() {
      if (_selectedHobbies.contains(hobby)) {
        _selectedHobbies.remove(hobby);
      } else {
        _selectedHobbies.add(hobby);
      }
    });
  }

  String _getLabelForScale(String type, double value) {
    switch (type) {
      case 'social':
        if (value < 3) return 'Very Introverted';
        if (value < 5) return 'Mostly Introverted';
        if (value < 7) return 'Balanced';
        if (value < 9) return 'Mostly Extroverted';
        return 'Very Extroverted';

      case 'activity':
        if (value < 3) return 'Very Relaxed';
        if (value < 5) return 'Mostly Relaxed';
        if (value < 7) return 'Balanced';
        if (value < 9) return 'Mostly Active';
        return 'Very Active';

      case 'outdoor':
        if (value < 3) return 'Prefer Indoors';
        if (value < 5) return 'Mostly Indoors';
        if (value < 7) return 'Balanced';
        if (value < 9) return 'Mostly Outdoors';
        return 'Outdoor Enthusiast';

      case 'travel':
        if (value < 3) return 'Homebody';
        if (value < 5) return 'Occasional Traveler';
        if (value < 7) return 'Regular Traveler';
        if (value < 9) return 'Frequent Traveler';
        return 'World Explorer';

      case 'nightlife':
        if (value < 3) return 'Early Bird';
        if (value < 5) return 'Mostly Early';
        if (value < 7) return 'Balanced';
        if (value < 9) return 'Mostly Night Owl';
        return 'Night Owl';

      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Categories of hobbies and interests
    final Map<String, List<String>> hobbyCategories = {
      'Physical Activities': [
        'Hiking',
        'Running',
        'Swimming',
        'Cycling',
        'Yoga',
        'Dance',
        'Gym',
        'Team Sports',
        'Martial Arts',
        'Rock Climbing',
      ],
      'Creative Pursuits': [
        'Painting',
        'Writing',
        'Photography',
        'Music',
        'Singing',
        'Crafting',
        'DIY Projects',
        'Cooking',
        'Baking',
        'Fashion',
      ],
      'Entertainment': [
        'Movies',
        'TV Shows',
        'Theater',
        'Concerts',
        'Board Games',
        'Video Games',
        'Reading',
        'Podcasts',
        'Comedy',
        'Museums',
      ],
      'Social Activities': [
        'Dining Out',
        'Coffee Shops',
        'Volunteering',
        'Travel',
        'Nightlife',
        'Festivals',
        'Wine Tasting',
        'Political Activism',
        'Community Service',
        'Social Clubs',
      ],
      'Intellectual Pursuits': [
        'Learning Languages',
        'Science',
        'History',
        'Philosophy',
        'Technology',
        'Investing',
        'Chess',
        'Debates',
        'Politics',
        'Puzzles',
      ],
      'Outdoor Activities': [
        'Gardening',
        'Camping',
        'Fishing',
        'Hunting',
        'Birdwatching',
        'Beach',
        'Nature Walks',
        'Stargazing',
        'Sailing',
        'Winter Sports',
      ],
    };

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.lifestyleTitle),
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
                    const ProfileStepIndicator(currentStep: 4, totalSteps: 8),

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
                                l10n.lifestyleTitle,
                                style: AppTextStyles.heading2,
                              ),
                            ),

                            const SizedBox(height: AppDimensions.paddingM),

                            DelayedDisplay(
                              delay: const Duration(milliseconds: 200),
                              child: Text(
                                l10n.lifestyleDesc,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),

                            const SizedBox(height: AppDimensions.paddingXL),

                            // Lifestyle Preferences Section
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
                                      'Lifestyle Preferences',
                                      style: AppTextStyles.heading3.copyWith(
                                        fontSize: 18,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingL,
                                    ),

                                    // Social Scale
                                    _buildPreferenceSlider(
                                      'Social Energy',
                                      'Introverted',
                                      'Extroverted',
                                      _socialScale,
                                      (value) =>
                                          setState(() => _socialScale = value),
                                      _getLabelForScale('social', _socialScale),
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingL,
                                    ),

                                    // Activity Scale
                                    _buildPreferenceSlider(
                                      'Activity Level',
                                      'Relaxed',
                                      'Active',
                                      _activityScale,
                                      (value) => setState(
                                        () => _activityScale = value,
                                      ),
                                      _getLabelForScale(
                                        'activity',
                                        _activityScale,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingL,
                                    ),

                                    // Outdoor Scale
                                    _buildPreferenceSlider(
                                      'Indoor vs Outdoor',
                                      'Indoor Person',
                                      'Outdoor Person',
                                      _outdoorScale,
                                      (value) =>
                                          setState(() => _outdoorScale = value),
                                      _getLabelForScale(
                                        'outdoor',
                                        _outdoorScale,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingL,
                                    ),

                                    // Travel Scale
                                    _buildPreferenceSlider(
                                      'Travel Enthusiasm',
                                      'Homebody',
                                      'World Traveler',
                                      _travelScale,
                                      (value) =>
                                          setState(() => _travelScale = value),
                                      _getLabelForScale('travel', _travelScale),
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingL,
                                    ),

                                    // Nightlife Scale
                                    _buildPreferenceSlider(
                                      'Daily Rhythm',
                                      'Early Bird',
                                      'Night Owl',
                                      _nightlifeScale,
                                      (value) => setState(
                                        () => _nightlifeScale = value,
                                      ),
                                      _getLabelForScale(
                                        'nightlife',
                                        _nightlifeScale,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: AppDimensions.paddingL),

                            // Hobbies and Interests Section
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Hobbies & Interests',
                                          style: AppTextStyles.heading3
                                              .copyWith(fontSize: 18),
                                        ),
                                        Text(
                                          'Selected: ${_selectedHobbies.length}',
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.textMedium,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingM,
                                    ),

                                    Text(
                                      'Select activities you enjoy regularly',
                                      style: AppTextStyles.bodySmall,
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingL,
                                    ),

                                    // Selected hobbies
                                    if (_selectedHobbies.isNotEmpty) ...[
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
                                            _selectedHobbies.map((hobby) {
                                              return _buildHobbyChip(
                                                hobby,
                                                true,
                                                () => _toggleHobby(hobby),
                                              );
                                            }).toList(),
                                      ),

                                      const SizedBox(
                                        height: AppDimensions.paddingL,
                                      ),
                                    ],

                                    // Hobby categories
                                    ...hobbyCategories.entries.map((entry) {
                                      return _buildHobbyCategory(
                                        entry.key,
                                        entry.value,
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: AppDimensions.paddingL),

                            // Ideal Weekend Section
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
                                      'Describe Your Ideal Weekend',
                                      style: AppTextStyles.heading3.copyWith(
                                        fontSize: 18,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingM,
                                    ),

                                    Text(
                                      'What does your perfect weekend look like?',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.backgroundLight,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingL,
                                    ),

                                    TextField(
                                      controller: _weekendController,
                                      decoration: InputDecoration(
                                        hintText: 'My ideal weekend ...',
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

                            const SizedBox(height: AppDimensions.paddingXL),
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
                        delay: const Duration(milliseconds: 600),
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

  Widget _buildPreferenceSlider(
    String title,
    String leftLabel,
    String rightLabel,
    double value,
    ValueChanged<double> onChanged,
    String currentLabel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.label),

        const SizedBox(height: AppDimensions.paddingS),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentLabel,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryDarkBlue,
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
                leftLabel,
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
                rightLabel,
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

  Widget _buildHobbyCategory(String category, List<String> hobbies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(category, style: AppTextStyles.label),

        const SizedBox(height: AppDimensions.paddingS),

        Wrap(
          spacing: AppDimensions.paddingS,
          runSpacing: AppDimensions.paddingS,
          children:
              hobbies.map((hobby) {
                final isSelected = _selectedHobbies.contains(hobby);
                return _buildHobbyChip(
                  hobby,
                  isSelected,
                  () => _toggleHobby(hobby),
                );
              }).toList(),
        ),

        const SizedBox(height: AppDimensions.paddingL),
      ],
    );
  }

  Widget _buildHobbyChip(String label, bool isSelected, VoidCallback onTap) {
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
                color: isSelected ? Colors.white : AppColors.primaryDarkBlue,
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
}
