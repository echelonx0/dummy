// lib/features/profile/screens/profile_basic_info_screen.dart
import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:khedoo/generated/l10n.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/shared/widgets/custom_date_picker.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/shared/widgets/custom_button.dart';
import '../../../core/shared/widgets/custom_text_field.dart';
import '../../../app/locator.dart';
import '../widgets/profile_step_indicator.dart';
import 'profile_photo_upload_screen.dart';

class ProfileBasicInfoScreen extends StatefulWidget {
  const ProfileBasicInfoScreen({super.key});

  @override
  State<ProfileBasicInfoScreen> createState() => _ProfileBasicInfoScreenState();
}

class _ProfileBasicInfoScreenState extends State<ProfileBasicInfoScreen> {
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
  bool _dataLoaded = false;

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
        // Load basic user info from Firebase Auth
        if (user.displayName != null) {
          _nameController.text = user.displayName!;
        }

        if (user.phoneNumber != null) {
          _phoneController.text = user.phoneNumber!;
        }

        // Load profile data from Firestore if it exists
        final profileDoc = await _firebaseService.getDocumentById(
          'profiles',
          user.uid,
        );

        if (profileDoc.exists) {
          final data = profileDoc.data() as Map<String, dynamic>;

          // Fill form fields with existing data
          if (data['displayName'] != null) {
            _nameController.text = data['displayName'];
          }

          if (data['phoneNumber'] != null) {
            _phoneController.text = data['phoneNumber'];
          }

          if (data['cityOfResidence'] != null) {
            _cityController.text = data['cityOfResidence'];
          }

          if (data['nationality'] != null) {
            _nationalityController.text = data['nationality'];
          }

          if (data['dateOfBirth'] != null) {
            _dateOfBirth = (data['dateOfBirth'] as Timestamp).toDate();
          }

          if (data['gender'] != null) {
            _gender = data['gender'];
          }

          if (data['genderIdentity'] != null) {
            _genderIdentity = data['genderIdentity'];
          }

          if (data['sexualOrientation'] != null) {
            _sexualOrientation = data['sexualOrientation'];
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
          message: 'Failed to load user data: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dateOfBirth == null) {
      Helpers.showErrorModal(
        context,
        message: 'Please select your date of birth',
      );
      return;
    }

    if (_gender == null) {
      Helpers.showErrorModal(context, message: 'Please select your gender');
      return;
    }

    if (_sexualOrientation == null) {
      Helpers.showErrorModal(
        context,
        message: 'Please select your sexual orientation',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _authService.getCurrentUser();

      if (user != null) {
        // Update display name in Firebase Auth
        await _authService.updateUserProfile(displayName: _nameController.text);

        // Update profile data in Firestore
        await _firebaseService.updateDocument('profiles', user.uid, {
          'displayName': _nameController.text,
          'phoneNumber': _phoneController.text,
          'cityOfResidence': _cityController.text,
          'nationality': _nationalityController.text,
          'dateOfBirth': _dateOfBirth,
          'gender': _gender,
          'genderIdentity': _genderIdentity ?? _gender,
          'sexualOrientation': _sexualOrientation,
          'completionStatus.basicInfo': 'completed',
          'completionPercentage': FieldValue.increment(12.5),
          'lastUpdated': Timestamp.now(),
        });

        if (mounted) {
          // Navigate to next step
          // Use this:
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ProfilePhotoUploadScreenWrapper(),
            ),
          );
        }
      } else {
        print('No user is currently logged in.');
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

  Future<void> _selectDateOfBirth() async {
    final DateTime now = DateTime.now();
    final DateTime minimumDate = DateTime(now.year - 100, now.month, now.day);
    final DateTime maximumDate = DateTime(now.year - 18, now.month, now.day);
    final DateTime initialDate =
        _dateOfBirth ?? DateTime(now.year - 25, now.month, now.day);

    final DateTime? picked = await EnhancedDatePicker.show(
      context,
      initialDate: initialDate,
      firstDate: minimumDate,
      lastDate: maximumDate,
      title: 'Choose Your Date of Birth',
    );

    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.basicInfoTitle),
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
                    const ProfileStepIndicator(currentStep: 1, totalSteps: 8),

                    // Form Content
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
                                l10n.basicInfoTitle,
                                style: AppTextStyles.heading2,
                              ),
                            ),

                            const SizedBox(height: AppDimensions.paddingM),

                            DelayedDisplay(
                              delay: const Duration(milliseconds: 200),
                              child: Text(
                                l10n.basicInfoDesc,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),

                            const SizedBox(height: AppDimensions.paddingXL),

                            // Form
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Full Name
                                  DelayedDisplay(
                                    delay: const Duration(milliseconds: 300),
                                    child: CustomTextField(
                                      label: l10n.name,
                                      hint: 'Your full name',
                                      controller: _nameController,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      prefixIcon: Icons.person_outline,
                                      validator: Validators.validateName,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: AppDimensions.paddingL,
                                  ),

                                  // Date of Birth
                                  DelayedDisplay(
                                    delay: const Duration(milliseconds: 400),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.dateOfBirth,
                                          style: AppTextStyles.label.copyWith(
                                            color: AppColors.textDark,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: AppDimensions.paddingS,
                                        ),

                                        // Enhanced date picker button
                                        Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: AppColors.cardBackground,
                                            borderRadius: BorderRadius.circular(
                                              AppDimensions.radiusM,
                                            ),
                                            border: Border.all(
                                              color:
                                                  _dateOfBirth != null
                                                      ? AppColors
                                                          .primarySageGreen
                                                          .withValues(
                                                            alpha: 0.3,
                                                          )
                                                      : AppColors.borderPrimary,
                                              width: 1,
                                            ),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: _selectDateOfBirth,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppDimensions.radiusM,
                                                  ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  AppDimensions.paddingM,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            _dateOfBirth != null
                                                                ? AppColors
                                                                    .primarySageGreen
                                                                    .withValues(
                                                                      alpha:
                                                                          0.2,
                                                                    )
                                                                : AppColors
                                                                    .textMedium
                                                                    .withValues(
                                                                      alpha:
                                                                          0.1,
                                                                    ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .calendar_today_rounded,
                                                        color:
                                                            _dateOfBirth != null
                                                                ? AppColors
                                                                    .primarySageGreen
                                                                : AppColors
                                                                    .textMedium,
                                                        size: 18,
                                                      ),
                                                    ),

                                                    const SizedBox(
                                                      width:
                                                          AppDimensions
                                                              .paddingM,
                                                    ),

                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            _dateOfBirth != null
                                                                ? DateFormat(
                                                                  'EEEE, MMMM d, yyyy',
                                                                ).format(
                                                                  _dateOfBirth!,
                                                                )
                                                                : 'Select your date of birth',
                                                            style:
                                                                _dateOfBirth !=
                                                                        null
                                                                    ? AppTextStyles
                                                                        .bodyMedium
                                                                        .copyWith(
                                                                          color:
                                                                              AppColors.textDark,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        )
                                                                    : AppTextStyles
                                                                        .bodyMedium
                                                                        .copyWith(
                                                                          color:
                                                                              AppColors.textMedium,
                                                                        ),
                                                          ),

                                                          // Show age if date is selected
                                                          if (_dateOfBirth !=
                                                              null) ...[
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical: 4,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: AppColors
                                                                    .primaryAccent
                                                                    .withValues(
                                                                      alpha:
                                                                          0.2,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                              ),
                                                              child: Text(
                                                                'Age: ${Helpers.calculateAge(_dateOfBirth!)}',
                                                                style: AppTextStyles
                                                                    .caption
                                                                    .copyWith(
                                                                      color:
                                                                          AppColors
                                                                              .primarySageGreen,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                              ),
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                    ),

                                                    Icon(
                                                      Icons
                                                          .keyboard_arrow_down_rounded,
                                                      color:
                                                          _dateOfBirth != null
                                                              ? AppColors
                                                                  .primarySageGreen
                                                              : AppColors
                                                                  .textMedium,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppDimensions.paddingL,
                                  ),

                                  // Phone Number
                                  DelayedDisplay(
                                    delay: const Duration(milliseconds: 500),
                                    child: CustomTextField(
                                      label: l10n.phoneNumber,
                                      hint: '+1 (555) 123-4567',
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      prefixIcon: Icons.phone_outlined,
                                      validator: Validators.validatePhoneNumber,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: AppDimensions.paddingL,
                                  ),

                                  // Gender
                                  DelayedDisplay(
                                    delay: const Duration(milliseconds: 600),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.gender,
                                          style: AppTextStyles.label,
                                        ),

                                        const SizedBox(
                                          height: AppDimensions.paddingS,
                                        ),

                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.inputBackground,
                                            borderRadius: BorderRadius.circular(
                                              AppDimensions.radiusM,
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: _gender,
                                              isExpanded: true,
                                              hint: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal:
                                                          AppDimensions
                                                              .paddingM,
                                                    ),
                                                child: Text(
                                                  'Select your gender',
                                                  style: AppTextStyles
                                                      .bodyMedium
                                                      .copyWith(
                                                        color:
                                                            AppColors
                                                                .textMedium,
                                                      ),
                                                ),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal:
                                                        AppDimensions.paddingM,
                                                  ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppDimensions.radiusM,
                                                  ),
                                              items:
                                                  _genderOptions.map((
                                                    String gender,
                                                  ) {
                                                    return DropdownMenuItem<
                                                      String
                                                    >(
                                                      value: gender,
                                                      child: Text(gender),
                                                    );
                                                  }).toList(),
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  _gender = newValue;

                                                  // Default gender identity to match gender
                                                  // unless it's already set
                                                  _genderIdentity ??= newValue;
                                                });
                                              },
                                            ),
                                          ),
                                        ),

                                        // Gender Identity (only if different from gender)
                                        if (_gender == 'Other' ||
                                            _gender == 'Non-binary') ...[
                                          const SizedBox(
                                            height: AppDimensions.paddingM,
                                          ),
                                          CustomTextField(
                                            label: 'Gender Identity',
                                            hint: 'How you identify (optional)',
                                            initialValue:
                                                _genderIdentity != _gender
                                                    ? _genderIdentity
                                                    : null,
                                            onChanged: (value) {
                                              setState(() {
                                                _genderIdentity =
                                                    value.isEmpty
                                                        ? _gender
                                                        : value;
                                              });
                                            },
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  const SizedBox(
                                    height: AppDimensions.paddingL,
                                  ),

                                  // Sexual Orientation
                                  DelayedDisplay(
                                    delay: const Duration(milliseconds: 700),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Sexual Orientation',
                                          style: AppTextStyles.label,
                                        ),

                                        const SizedBox(
                                          height: AppDimensions.paddingS,
                                        ),

                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.inputBackground,
                                            borderRadius: BorderRadius.circular(
                                              AppDimensions.radiusM,
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: _sexualOrientation,
                                              isExpanded: true,
                                              hint: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal:
                                                          AppDimensions
                                                              .paddingM,
                                                    ),
                                                child: Text(
                                                  'Select your orientation',
                                                  style: AppTextStyles
                                                      .bodyMedium
                                                      .copyWith(
                                                        color:
                                                            AppColors
                                                                .textMedium,
                                                      ),
                                                ),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal:
                                                        AppDimensions.paddingM,
                                                  ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppDimensions.radiusM,
                                                  ),
                                              items:
                                                  _orientationOptions.map((
                                                    String orientation,
                                                  ) {
                                                    return DropdownMenuItem<
                                                      String
                                                    >(
                                                      value: orientation,
                                                      child: Text(orientation),
                                                    );
                                                  }).toList(),
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  _sexualOrientation = newValue;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(
                                    height: AppDimensions.paddingL,
                                  ),

                                  // City of Residence
                                  DelayedDisplay(
                                    delay: const Duration(milliseconds: 800),
                                    child: CustomTextField(
                                      label: l10n.location,
                                      hint: 'City where you live',
                                      controller: _cityController,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      prefixIcon: Icons.location_city_outlined,
                                      validator:
                                          (value) =>
                                              Validators.validateRequired(
                                                value,
                                                'City',
                                              ),
                                    ),
                                  ),

                                  const SizedBox(
                                    height: AppDimensions.paddingL,
                                  ),

                                  // Nationality
                                  DelayedDisplay(
                                    delay: const Duration(milliseconds: 900),
                                    child: CustomTextField(
                                      label: 'Nationality',
                                      hint: 'Your nationality',
                                      controller: _nationalityController,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      prefixIcon: Icons.public_outlined,
                                      validator:
                                          (value) =>
                                              Validators.validateRequired(
                                                value,
                                                'Nationality',
                                              ),
                                    ),
                                  ),

                                  const SizedBox(
                                    height: AppDimensions.paddingXXL,
                                  ),

                                  // Privacy Notice
                                  DelayedDisplay(
                                    delay: const Duration(milliseconds: 1000),
                                    child: Container(
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
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.privacy_tip_outlined,
                                            color: AppColors.textMedium,
                                            size: 20,
                                          ),
                                          const SizedBox(
                                            width: AppDimensions.paddingM,
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Your information is kept private and only shared with potential matches according to our privacy controls. You can always update your information later.',
                                              style: AppTextStyles.caption
                                                  .copyWith(
                                                    color: Colors.white,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
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
                        delay: const Duration(milliseconds: 1100),
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
