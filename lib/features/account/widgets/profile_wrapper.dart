// lib/features/profile/widgets/profile_wrappers.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../app/locator.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/shared/widgets/custom_button.dart';
import '../../../core/shared/widgets/custom_date_picker.dart';
import '../../../core/shared/widgets/custom_text_field.dart';
import '../../../core/utils/validators.dart';
import '../../profile/screens/profile_basic_info_screen.dart';
import '../../profile/screens/profile_relationship_goals_screen.dart';

/// Wrapper for ProfileBasicInfoScreen that handles both edit and onboarding modes
class ProfileBasicInfoWrapper extends StatelessWidget {
  final bool isEditMode;
  final VoidCallback? onSaved;

  const ProfileBasicInfoWrapper({
    super.key,
    this.isEditMode = true,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    if (isEditMode) {
      return _EditModeWrapper(
        title: 'Edit Basic Information',
        child: _ProfileBasicInfoEdit(onSaved: onSaved),
      );
    }

    return const ProfileBasicInfoScreen();
  }
}

/// Wrapper for ProfilePhotosScreen
class ProfilePhotosWrapper extends StatelessWidget {
  final bool isEditMode;
  final VoidCallback? onSaved;

  const ProfilePhotosWrapper({super.key, this.isEditMode = true, this.onSaved});

  @override
  Widget build(BuildContext context) {
    if (isEditMode) {
      return _EditModeWrapper(
        title: 'Edit Photos',
        child: _ProfilePhotosEdit(onSaved: onSaved),
      );
    }

    // For onboarding mode, you'd return your existing photos screen
    return const Placeholder(); // Replace with actual onboarding photos screen
  }
}

/// Wrapper for ProfileInterestsScreen
class ProfileInterestsWrapper extends StatelessWidget {
  final bool isEditMode;
  final VoidCallback? onSaved;

  const ProfileInterestsWrapper({
    super.key,
    this.isEditMode = true,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    if (isEditMode) {
      return _EditModeWrapper(
        title: 'Edit Interests',
        child: _ProfileInterestsEdit(onSaved: onSaved),
      );
    }

    // For onboarding mode, you'd return your existing interests screen
    return const Placeholder(); // Replace with actual onboarding interests screen
  }
}

class ProfileRelationshipGoalsWrapper extends StatelessWidget {
  final bool isEditMode;
  final VoidCallback? onSaved;

  const ProfileRelationshipGoalsWrapper({
    super.key,
    this.isEditMode = true,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    if (isEditMode) {
      return _EditModeWrapper(
        title: 'Edit Relationship Goals',
        child: _ProfileRelationshipGoalsEdit(onSaved: onSaved),
      );
    }

    return const ProfileRelationshipGoalsScreen();
  }
}

/// Common wrapper for edit mode with consistent styling
class _EditModeWrapper extends StatelessWidget {
  final String title;
  final Widget child;

  const _EditModeWrapper({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          title,
          style: AppTextStyles.heading2.copyWith(fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMedium,
              ),
            ),
          ),
        ],
      ),
      body: child,
    );
  }
}

/// Edit mode version of ProfileBasicInfoScreen
class _ProfileBasicInfoEdit extends StatefulWidget {
  final VoidCallback? onSaved;

  const _ProfileBasicInfoEdit({this.onSaved});

  @override
  State<_ProfileBasicInfoEdit> createState() => _ProfileBasicInfoEditState();
}

class _ProfileBasicInfoEditState extends State<_ProfileBasicInfoEdit> {
  // Essential form controllers and state
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _nationalityController = TextEditingController();

  final _authService = locator<AuthService>();
  final _firebaseService = locator<FirebaseService>();

  DateTime? _dateOfBirth;
  String? _gender;
  String? _genderIdentity;
  String? _sexualOrientation;
  bool _isLoading = false;

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
    'Other',
  ];

  final List<String> _orientationOptions = [
    'Straight/Heterosexual',
    'Gay/Homosexual',
    'Bisexual',
    'Pansexual',
    'Asexual',
    'Queer',
    'Questioning',
    'Prefer not to say',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _nationalityController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = _authService.getCurrentUser();
      if (user != null) {
        // Load from Firebase Auth
        if (user.displayName != null) _nameController.text = user.displayName!;
        if (user.phoneNumber != null) _phoneController.text = user.phoneNumber!;

        // Load from Firestore
        final profileDoc = await _firebaseService.getDocumentById(
          'profiles',
          user.uid,
        );
        if (profileDoc.exists) {
          final data = profileDoc.data() as Map<String, dynamic>;

          _nameController.text = data['displayName'] ?? '';
          _phoneController.text = data['phoneNumber'] ?? '';
          _cityController.text = data['cityOfResidence'] ?? '';
          _nationalityController.text = data['nationality'] ?? '';

          if (data['dateOfBirth'] != null) {
            _dateOfBirth = (data['dateOfBirth'] as Timestamp).toDate();
          }
          _gender = data['gender'];
          _genderIdentity = data['genderIdentity'];
          _sexualOrientation = data['sexualOrientation'];
        }
      }
    } catch (e) {
      if (mounted) _showError('Failed to load data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      return _showError('Please select your date of birth');
    }
    if (_gender == null) return _showError('Please select your gender');
    if (_sexualOrientation == null) {
      return _showError('Please select your sexual orientation');
    }

    setState(() => _isLoading = true);
    try {
      final user = _authService.getCurrentUser();
      if (user != null) {
        await _authService.updateUserProfile(displayName: _nameController.text);
        await _firebaseService.updateDocument('profiles', user.uid, {
          'displayName': _nameController.text,
          'phoneNumber': _phoneController.text,
          'cityOfResidence': _cityController.text,
          'nationality': _nationalityController.text,
          'dateOfBirth': _dateOfBirth,
          'gender': _gender,
          'genderIdentity': _genderIdentity ?? _gender,
          'sexualOrientation': _sexualOrientation,
          'lastUpdated': Timestamp.now(),
        });

        if (mounted) {
          _showSuccess('Profile updated successfully');
          widget.onSaved?.call();
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) _showError('Failed to save: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.primarySageGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Name
                  CustomTextField(
                    label: 'Name',
                    hint: 'Your full name',
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: Icons.person_outline,
                    validator: Validators.validateName,
                  ),
                  const SizedBox(height: AppDimensions.paddingL),

                  // Date of Birth
                  _buildDatePicker(),
                  const SizedBox(height: AppDimensions.paddingL),

                  // Phone
                  CustomTextField(
                    label: 'Phone Number',
                    hint: '+1 (555) 123-4567',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    validator: Validators.validatePhoneNumber,
                  ),
                  const SizedBox(height: AppDimensions.paddingL),

                  // Gender
                  _buildGenderDropdown(),
                  const SizedBox(height: AppDimensions.paddingL),

                  // Sexual Orientation
                  _buildOrientationDropdown(),
                  const SizedBox(height: AppDimensions.paddingL),

                  // City
                  CustomTextField(
                    label: 'City',
                    hint: 'City where you live',
                    controller: _cityController,
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: Icons.location_city_outlined,
                    validator:
                        (value) => Validators.validateRequired(value, 'City'),
                  ),
                  const SizedBox(height: AppDimensions.paddingL),

                  // Nationality
                  CustomTextField(
                    label: 'Nationality',
                    hint: 'Your nationality',
                    controller: _nationalityController,
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: Icons.public_outlined,
                    validator:
                        (value) =>
                            Validators.validateRequired(value, 'Nationality'),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Edit mode bottom actions
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
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Cancel',
                  onPressed: () => Navigator.of(context).pop(),
                  type: ButtonType.secondary,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                flex: 2,
                child: CustomButton(
                  text: 'Save Changes',
                  onPressed: _saveChanges,
                  isLoading: _isLoading,
                  type: ButtonType.primary,
                  icon: Icons.check,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final DateTime now = DateTime.now();
        final DateTime? picked = await EnhancedDatePicker.show(
          context,
          initialDate: _dateOfBirth ?? DateTime(now.year - 25),
          firstDate: DateTime(now.year - 100),
          lastDate: DateTime(now.year - 18),
          title: 'Choose Your Date of Birth',
        );
        if (picked != null) setState(() => _dateOfBirth = picked);
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(color: AppColors.borderPrimary),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.textMedium),
            const SizedBox(width: AppDimensions.paddingM),
            Text(
              _dateOfBirth != null
                  ? DateFormat('MMMM d, yyyy').format(_dateOfBirth!)
                  : 'Select your date of birth',
              style: AppTextStyles.bodyMedium.copyWith(
                color:
                    _dateOfBirth != null
                        ? AppColors.textDark
                        : AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: const InputDecoration(
        labelText: 'Gender',
        prefixIcon: Icon(Icons.person_outline),
      ),
      items:
          _genderOptions
              .map(
                (gender) =>
                    DropdownMenuItem(value: gender, child: Text(gender)),
              )
              .toList(),
      onChanged: (value) => setState(() => _gender = value),
    );
  }

  Widget _buildOrientationDropdown() {
    return DropdownButtonFormField<String>(
      value: _sexualOrientation,
      decoration: const InputDecoration(
        labelText: 'Sexual Orientation',
        prefixIcon: Icon(Icons.favorite_outline),
      ),
      items:
          _orientationOptions
              .map(
                (orientation) => DropdownMenuItem(
                  value: orientation,
                  child: Text(orientation),
                ),
              )
              .toList(),
      onChanged: (value) => setState(() => _sexualOrientation = value),
    );
  }
}

/// Edit mode version of ProfileRelationshipGoalsScreen
class _ProfileRelationshipGoalsEdit extends StatefulWidget {
  final VoidCallback? onSaved;

  const _ProfileRelationshipGoalsEdit({this.onSaved});

  @override
  State<_ProfileRelationshipGoalsEdit> createState() =>
      _ProfileRelationshipGoalsEditState();
}

class _ProfileRelationshipGoalsEditState
    extends State<_ProfileRelationshipGoalsEdit> {
  final _authService = locator<AuthService>();
  final _firebaseService = locator<FirebaseService>();
  final _dealbreakersController = TextEditingController();

  bool _isLoading = false;
  String? _relationshipType;
  List<String> _selectedQualities = [];
  double _familyImportance = 5.0;
  double _religionImportance = 5.0;

  final List<String> _relationshipTypes = [
    'Long-term commitment',
    'Marriage and family',
    'Serious dating',
    'Casual dating',
    'Friendship first',
    'Still exploring options',
  ];

  final List<String> _partnerQualities = [
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
            _relationshipType = data['relationshipType'];
            if (data['partnerCoreValues'] != null &&
                data['partnerCoreValues'] is List) {
              _selectedQualities = List<String>.from(data['partnerCoreValues']);
            }
            if (data['dealbreakers'] != null) {
              _dealbreakersController.text = data['dealbreakers'];
            }
            _familyImportance = data['importanceOfFamily'] ?? 5.0;
            _religionImportance = data['importanceOfReligion'] ?? 5.0;
          });
        }
      }
    } catch (e) {
      if (mounted) _showError('Failed to load data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    if (_relationshipType == null) {
      return _showError('Please select a relationship type');
    }

    setState(() => _isLoading = true);
    try {
      final user = _authService.getCurrentUser();
      if (user != null) {
        await _firebaseService.updateDocument('profiles', user.uid, {
          'relationshipType': _relationshipType,
          'partnerCoreValues': _selectedQualities,
          'dealbreakers': _dealbreakersController.text.trim(),
          'importanceOfFamily': _familyImportance,
          'importanceOfReligion': _religionImportance,
          'lastUpdated': Timestamp.now(),
        });

        if (mounted) {
          _showSuccess('Relationship goals updated successfully');
          widget.onSaved?.call();
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) _showError('Failed to save: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.primarySageGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Relationship Type
                Text(
                  'What type of relationship are you seeking?',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: AppDimensions.paddingM),

                ...(_relationshipTypes.map(
                  (type) => RadioListTile<String>(
                    title: Text(type),
                    value: type,
                    groupValue: _relationshipType,
                    onChanged:
                        (value) => setState(() => _relationshipType = value),
                  ),
                )),

                const SizedBox(height: AppDimensions.paddingL),

                // Partner Qualities
                Text(
                  'What qualities do you value in a partner?',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: AppDimensions.paddingM),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _partnerQualities.map((quality) {
                        final isSelected = _selectedQualities.contains(quality);
                        return FilterChip(
                          label: Text(quality),
                          selected: isSelected,
                          onSelected: (_) => _toggleQuality(quality),
                          selectedColor: AppColors.primaryDarkBlue.withOpacity(
                            0.2,
                          ),
                          checkmarkColor: AppColors.primaryDarkBlue,
                        );
                      }).toList(),
                ),

                const SizedBox(height: AppDimensions.paddingL),

                // Dealbreakers
                Text(
                  'What are your dealbreakers?',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: AppDimensions.paddingM),

                TextField(
                  controller: _dealbreakersController,
                  decoration: const InputDecoration(
                    hintText:
                        'Examples: smoking, different political values, etc.',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: AppDimensions.paddingL),

                // Importance Sliders
                Text(
                  'Importance Ratings',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),

                _buildSlider(
                  'Family Importance',
                  _familyImportance,
                  (value) => setState(() => _familyImportance = value),
                ),

                const SizedBox(height: AppDimensions.paddingM),

                _buildSlider(
                  'Religious/Spiritual Importance',
                  _religionImportance,
                  (value) => setState(() => _religionImportance = value),
                ),
              ],
            ),
          ),
        ),

        // Bottom actions
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
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Cancel',
                  onPressed: () => Navigator.of(context).pop(),
                  type: ButtonType.secondary,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                flex: 2,
                child: CustomButton(
                  text: 'Save Changes',
                  onPressed: _saveChanges,
                  isLoading: _isLoading,
                  type: ButtonType.primary,
                  icon: Icons.check,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(
    String title,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),
        ),
        Slider(
          value: value,
          min: 0,
          max: 10,
          divisions: 10,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Edit mode version of ProfilePhotosScreen
class _ProfilePhotosEdit extends StatefulWidget {
  final VoidCallback? onSaved;

  const _ProfilePhotosEdit({this.onSaved});

  @override
  State<_ProfilePhotosEdit> createState() => _ProfilePhotosEditState();
}

class _ProfilePhotosEditState extends State<_ProfilePhotosEdit> {
  final _authService = locator<AuthService>();
  final _firebaseService = locator<FirebaseService>();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  List<String> _photoUrls = [];
  List<File> _pendingUploads = [];

  static const int maxPhotos = 6;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
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
          if (data['photos'] != null && data['photos'] is List) {
            setState(() {
              _photoUrls = List<String>.from(data['photos']);
            });
          }
        }
      }
    } catch (e) {
      if (mounted) _showError('Failed to load photos: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addPhoto() async {
    if (_photoUrls.length + _pendingUploads.length >= maxPhotos) {
      _showError('Maximum $maxPhotos photos allowed');
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _pendingUploads.add(File(image.path));
        });
      }
    } catch (e) {
      _showError('Failed to select photo: $e');
    }
  }

  Future<void> _removePhoto(int index, {bool isPending = false}) async {
    setState(() {
      if (isPending) {
        _pendingUploads.removeAt(index);
      } else {
        _photoUrls.removeAt(index);
      }
    });
  }

  // Future<void> _reorderPhotos(int oldIndex, int newIndex) async {
  //   if (newIndex > oldIndex) newIndex--;

  //   setState(() {
  //     final photo = _photoUrls.removeAt(oldIndex);
  //     _photoUrls.insert(newIndex, photo);
  //   });
  // }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      final user = _authService.getCurrentUser();
      if (user != null) {
        List<String> finalPhotoUrls = List.from(_photoUrls);

        // Upload pending photos
        for (File photo in _pendingUploads) {
          // TODO: Implement actual photo upload to Firebase Storage
          // For now, just add placeholder URL
          final photoUrl =
              'https://placeholder.com/uploaded_photo_${DateTime.now().millisecondsSinceEpoch}';
          finalPhotoUrls.add(photoUrl);
        }

        await _firebaseService.updateDocument('profiles', user.uid, {
          'photos': finalPhotoUrls,
          'lastUpdated': Timestamp.now(),
        });

        if (mounted) {
          _showSuccess('Photos updated successfully');
          widget.onSaved?.call();
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) _showError('Failed to save photos: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.primarySageGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress indicator
                Row(
                  children: [
                    Text(
                      '${_photoUrls.length + _pendingUploads.length}/$maxPhotos photos',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const Spacer(),
                    if (_photoUrls.length + _pendingUploads.length >= 4)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySageGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Great profile!',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primarySageGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: AppDimensions.paddingL),

                // Photo grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _photoUrls.length + _pendingUploads.length + 1,
                  itemBuilder: (context, index) {
                    // Existing photos
                    if (index < _photoUrls.length) {
                      return _buildPhotoItem(
                        photoUrl: _photoUrls[index],
                        index: index,
                        onRemove: () => _removePhoto(index),
                        isPrimary: index == 0,
                      );
                    }

                    // Pending uploads
                    final pendingIndex = index - _photoUrls.length;
                    if (pendingIndex < _pendingUploads.length) {
                      return _buildPhotoItem(
                        file: _pendingUploads[pendingIndex],
                        index: index,
                        onRemove:
                            () => _removePhoto(pendingIndex, isPending: true),
                        isPending: true,
                      );
                    }

                    // Add photo button
                    return _buildAddPhotoButton();
                  },
                ),

                const SizedBox(height: AppDimensions.paddingL),

                // Tips
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.primarySageGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Photo Tips',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primarySageGreen,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• First photo is your main profile picture\n'
                        '• Include variety: close-up, full body, activity shots\n'
                        '• Profiles with 4+ photos get 3x more matches\n'
                        '• Avoid group photos where you\'re hard to identify',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primarySageGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom actions
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
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Cancel',
                  onPressed: () => Navigator.of(context).pop(),
                  type: ButtonType.secondary,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                flex: 2,
                child: CustomButton(
                  text: 'Save Changes',
                  onPressed: _saveChanges,
                  isLoading: _isLoading,
                  type: ButtonType.primary,
                  icon: Icons.check,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoItem({
    String? photoUrl,
    File? file,
    required int index,
    required VoidCallback onRemove,
    bool isPrimary = false,
    bool isPending = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border:
            isPrimary
                ? Border.all(color: AppColors.primarySageGreen, width: 3)
                : null,
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              color: AppColors.inputBackground,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              child:
                  file != null
                      ? Image.file(file, fit: BoxFit.cover)
                      : photoUrl != null
                      ? Image.network(photoUrl, fit: BoxFit.cover)
                      : const Icon(
                        Icons.image,
                        size: 50,
                        color: AppColors.textMedium,
                      ),
            ),
          ),

          // Primary badge
          if (isPrimary)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySageGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Main',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Pending badge
          if (isPending)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'New',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Remove button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _addPhoto,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: AppColors.primarySageGreen,
            width: 2,
            style: BorderStyle.solid,
          ),
          color: AppColors.primarySageGreen.withOpacity(0.1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              size: 40,
              color: AppColors.primarySageGreen,
            ),
            const SizedBox(height: 8),
            Text(
              'Add Photo',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primarySageGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Edit mode version of ProfileInterestsScreen
class _ProfileInterestsEdit extends StatefulWidget {
  final VoidCallback? onSaved;

  const _ProfileInterestsEdit({this.onSaved});

  @override
  State<_ProfileInterestsEdit> createState() => _ProfileInterestsEditState();
}

class _ProfileInterestsEditState extends State<_ProfileInterestsEdit> {
  final _authService = locator<AuthService>();
  final _firebaseService = locator<FirebaseService>();

  bool _isLoading = false;
  List<String> _selectedInterests = [];

  final List<String> _availableInterests = [
    'Travel',
    'Photography',
    'Cooking',
    'Fitness',
    'Reading',
    'Music',
    'Movies',
    'Dancing',
    'Hiking',
    'Art',
    'Sports',
    'Gaming',
    'Yoga',
    'Wine Tasting',
    'Coffee',
    'Tech',
    'Fashion',
    'Pets',
    'Volunteering',
    'Writing',
    'Podcasts',
    'Meditation',
    'Concerts',
    'Theater',
    'Museums',
    'Beach',
    'Mountains',
    'Camping',
    'Running',
    'Cycling',
    'Swimming',
    'Tennis',
    'Basketball',
    'Soccer',
    'Golf',
  ];

  @override
  void initState() {
    super.initState();
    _loadInterests();
  }

  Future<void> _loadInterests() async {
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
          if (data['interests'] != null && data['interests'] is List) {
            setState(() {
              _selectedInterests = List<String>.from(data['interests']);
            });
          }
        }
      }
    } catch (e) {
      if (mounted) _showError('Failed to load interests: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    if (_selectedInterests.length < 3) {
      _showError('Please select at least 3 interests');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = _authService.getCurrentUser();
      if (user != null) {
        await _firebaseService.updateDocument('profiles', user.uid, {
          'interests': _selectedInterests,
          'lastUpdated': Timestamp.now(),
        });

        if (mounted) {
          _showSuccess('Interests updated successfully');
          widget.onSaved?.call();
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) _showError('Failed to save interests: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else if (_selectedInterests.length < 10) {
        _selectedInterests.add(interest);
      } else {
        _showError('Maximum 10 interests allowed');
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.primarySageGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress indicator
                Row(
                  children: [
                    Text(
                      '${_selectedInterests.length}/10 interests selected',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const Spacer(),
                    if (_selectedInterests.length >= 5)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySageGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Great variety!',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primarySageGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: AppDimensions.paddingL),

                Text(
                  'What are you passionate about?',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: AppDimensions.paddingM),

                Text(
                  'Select 3-10 interests that best represent you',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMedium,
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingL),

                // Selected interests
                if (_selectedInterests.isNotEmpty) ...[
                  Text(
                    'Your Interests:',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _selectedInterests
                            .map(
                              (interest) => Chip(
                                label: Text(interest),
                                onDeleted: () => _toggleInterest(interest),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                backgroundColor: AppColors.primaryDarkBlue
                                    .withOpacity(0.1),
                                labelStyle: TextStyle(
                                  color: AppColors.primaryDarkBlue,
                                ),
                                deleteIconColor: AppColors.primaryDarkBlue,
                              ),
                            )
                            .toList(),
                  ),

                  const SizedBox(height: AppDimensions.paddingL),
                ],

                // Available interests
                Text(
                  'Available Interests:',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _availableInterests
                          .where(
                            (interest) =>
                                !_selectedInterests.contains(interest),
                          )
                          .map(
                            (interest) => FilterChip(
                              label: Text(interest),
                              selected: false,
                              onSelected: (_) => _toggleInterest(interest),
                              backgroundColor: AppColors.inputBackground,
                              selectedColor: AppColors.primaryDarkBlue
                                  .withOpacity(0.2),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
        ),

        // Bottom actions
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
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Cancel',
                  onPressed: () => Navigator.of(context).pop(),
                  type: ButtonType.secondary,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                flex: 2,
                child: CustomButton(
                  text: 'Save Changes',
                  onPressed: _saveChanges,
                  isLoading: _isLoading,
                  type: ButtonType.primary,
                  icon: Icons.check,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
